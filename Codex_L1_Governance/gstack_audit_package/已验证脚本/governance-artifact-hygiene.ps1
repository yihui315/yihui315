<#
Skill: governance-artifact-hygiene
Trigger: artifact directories grow significantly, or a regular governance hygiene check is requested.
Recommendation: run dry-run first, review the generated Archive_Plan_YYYY-MM-DD.md, then execute any archive command manually only after explicit approval.

Compliance reminder:
- Only inspect governance-related artifact directories.
- Do not read raw secret contents, .env files, provider credentials, payment data, or business source code.
- This script generates an archive plan; it does not move, delete, compress, or archive files.
#>

param(
  [string]$RootPath = "",
  [string[]]$TargetDirectories = @("artifacts", "screenshots", "logs", "mcp"),
  [int]$OlderThanDays = 90,
  [bool]$DryRun = $true,
  [string]$OutputDirectory = "",
  [int]$MaxEntries = 500,
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Write-Log {
  param([string]$Message)
  if (-not $Json) {
    Write-Host ("[governance-artifact-hygiene] {0}" -f $Message)
  }
}

function Resolve-RootPath {
  param([string]$InputRoot)

  if ([string]::IsNullOrWhiteSpace($InputRoot)) {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
  }

  return (Resolve-Path -LiteralPath $InputRoot).Path
}

function Get-FullPathSafe {
  param([string]$Path)
  return [System.IO.Path]::GetFullPath($Path)
}

function Convert-ToPowerShellLiteral {
  param([string]$Value)
  return "'" + ($Value -replace "'", "''") + "'"
}

function Get-RelativeDisplayPath {
  param(
    [string]$Root,
    [string]$Path
  )

  $rootFull = Get-FullPathSafe -Path $Root
  $pathFull = Get-FullPathSafe -Path $Path
  $separator = [System.IO.Path]::DirectorySeparatorChar

  if (-not $rootFull.EndsWith([string]$separator)) {
    $rootFull = $rootFull + $separator
  }

  if ($pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $pathFull.Substring($rootFull.Length)
  }

  return $pathFull
}

function Format-Bytes {
  param([long]$Bytes)

  if ($Bytes -ge 1GB) { return ("{0:N2} GB" -f ($Bytes / 1GB)) }
  if ($Bytes -ge 1MB) { return ("{0:N2} MB" -f ($Bytes / 1MB)) }
  if ($Bytes -ge 1KB) { return ("{0:N2} KB" -f ($Bytes / 1KB)) }
  return ("{0} B" -f $Bytes)
}

function Test-PathInsideRoot {
  param(
    [string]$Root,
    [string]$Path
  )

  $rootFull = Get-FullPathSafe -Path $Root
  $pathFull = Get-FullPathSafe -Path $Path
  $separator = [System.IO.Path]::DirectorySeparatorChar

  if (-not $rootFull.EndsWith([string]$separator)) {
    $rootFull = $rootFull + $separator
  }

  return $pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-SensitivePathShape {
  param([string]$Path)

  $normalized = $Path -replace "\\", "/"
  return $normalized -match "(^|/)(\.env[^/]*|secrets?|tokens?|keys?|provider|payment)(/|$|[._-])"
}

function Resolve-TargetDirectory {
  param(
    [string]$Root,
    [string]$Target
  )

  if ([System.IO.Path]::IsPathRooted($Target)) {
    return Get-FullPathSafe -Path $Target
  }

  return Get-FullPathSafe -Path (Join-Path $Root $Target)
}

$root = Resolve-RootPath -InputRoot $RootPath
$cutoff = (Get-Date).AddDays(-1 * $OlderThanDays)
$dateStamp = Get-Date -Format "yyyy-MM-dd"

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $root "artifact_hygiene_reports"
}

$outputDirFull = Get-FullPathSafe -Path $OutputDirectory
if (-not (Test-PathInsideRoot -Root $root -Path $outputDirFull)) {
  throw "OutputDirectory must stay inside RootPath. output=$outputDirFull root=$root"
}

New-Item -ItemType Directory -Force -Path $outputDirFull | Out-Null
$outputPath = Join-Path $outputDirFull ("Archive_Plan_{0}.md" -f $dateStamp)

Write-Log ("root={0}" -f $root)
Write-Log ("targets={0}" -f ($TargetDirectories -join ", "))
Write-Log ("older_than_days={0}; cutoff={1}" -f $OlderThanDays, $cutoff.ToString("s"))
Write-Log ("dry_run={0}" -f $DryRun)

$targetSummaries = @()
$archiveCandidates = @()
$blockedTargets = @()
$sensitivePathHits = @()

foreach ($target in $TargetDirectories) {
  $targetPath = Resolve-TargetDirectory -Root $root -Target $target
  $relativeTarget = Get-RelativeDisplayPath -Root $root -Path $targetPath

  if (-not (Test-PathInsideRoot -Root $root -Path $targetPath)) {
    $blockedTargets += [PSCustomObject]@{
      target = $target
      path = $targetPath
      reason = "path_outside_root"
    }
    $targetSummaries += [PSCustomObject]@{
      target = $target
      path = $relativeTarget
      status = "blocked:path_outside_root"
      total_files = 0
      total_directories = 0
      candidate_files = 0
      candidate_directories = 0
      total_size_bytes = 0
    }
    continue
  }

  if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
    $targetSummaries += [PSCustomObject]@{
      target = $target
      path = $relativeTarget
      status = "missing"
      total_files = 0
      total_directories = 0
      candidate_files = 0
      candidate_directories = 0
      total_size_bytes = 0
    }
    continue
  }

  $files = @(
    Get-ChildItem -LiteralPath $targetPath -Recurse -Force -File -ErrorAction SilentlyContinue
  )
  $directories = @(
    Get-ChildItem -LiteralPath $targetPath -Recurse -Force -Directory -ErrorAction SilentlyContinue
  )

  $sensitiveInTarget = @(
    @($files) + @($directories) |
      Where-Object { Test-SensitivePathShape -Path $_.FullName } |
      Select-Object FullName, LastWriteTime
  )

  if ($sensitiveInTarget.Count -gt 0) {
    foreach ($hit in $sensitiveInTarget) {
      $sensitivePathHits += [PSCustomObject]@{
        target = $target
        path = Get-RelativeDisplayPath -Root $root -Path $hit.FullName
        last_write_time = $hit.LastWriteTime
      }
    }
  }

  $candidateFiles = @(
    $files |
      Where-Object {
        $_.LastWriteTime -lt $cutoff -and -not (Test-SensitivePathShape -Path $_.FullName)
      }
  )
  $candidateDirectories = @(
    $directories |
      Where-Object {
        $_.LastWriteTime -lt $cutoff -and -not (Test-SensitivePathShape -Path $_.FullName)
      }
  )

  foreach ($file in $candidateFiles) {
    $archiveCandidates += [PSCustomObject]@{
      type = "file"
      path = Get-RelativeDisplayPath -Root $root -Path $file.FullName
      full_path = $file.FullName
      last_write_time = $file.LastWriteTime
      size_bytes = [long]$file.Length
    }
  }

  foreach ($directory in $candidateDirectories) {
    $archiveCandidates += [PSCustomObject]@{
      type = "directory"
      path = Get-RelativeDisplayPath -Root $root -Path $directory.FullName
      full_path = $directory.FullName
      last_write_time = $directory.LastWriteTime
      size_bytes = $null
    }
  }

  $targetSummaries += [PSCustomObject]@{
    target = $target
    path = $relativeTarget
    status = "present"
    total_files = $files.Count
    total_directories = $directories.Count
    candidate_files = $candidateFiles.Count
    candidate_directories = $candidateDirectories.Count
    total_size_bytes = [long](($files | Measure-Object -Property Length -Sum).Sum)
  }
}

$archiveCandidates = @(
  $archiveCandidates |
    Sort-Object last_write_time, path |
    Select-Object -First $MaxEntries
)

$allCandidateCount = [int](($targetSummaries | Measure-Object -Property candidate_files -Sum).Sum) +
  [int](($targetSummaries | Measure-Object -Property candidate_directories -Sum).Sum)

$targetLiteralList = (($TargetDirectories | ForEach-Object { Convert-ToPowerShellLiteral -Value $_ }) -join ", ")
$scriptLiteral = Convert-ToPowerShellLiteral -Value $MyInvocation.MyCommand.Path
$rootLiteral = Convert-ToPowerShellLiteral -Value $root
$archiveRoot = Join-Path $root (Join-Path ".archive\governance-artifacts" $dateStamp)
$archiveRootLiteral = Convert-ToPowerShellLiteral -Value $archiveRoot

$status = "pass"
$issues = @()

if ($blockedTargets.Count -gt 0) {
  $status = "blocked"
  $issues += "target_path_outside_root"
}

if ($sensitivePathHits.Count -gt 0) {
  $status = "blocked"
  $issues += "sensitive_shaped_path_detected"
}

$plan = New-Object System.Collections.Generic.List[string]
$plan.Add("# Archive Plan $dateStamp")
$plan.Add("")
$plan.Add("## Metadata")
$plan.Add("")
$plan.Add("| Field | Value |")
$plan.Add("| --- | --- |")
$plan.Add("| skill | `governance-artifact-hygiene` |")
$plan.Add(('| generated_at | `{0}` |' -f (Get-Date -Format s)))
$plan.Add(('| root_path | `{0}` |' -f $root))
$plan.Add(('| older_than_days | `{0}` |' -f $OlderThanDays))
$plan.Add(('| cutoff | `{0}` |' -f $cutoff.ToString("s")))
$plan.Add(('| dry_run | `{0}` |' -f $DryRun))
$plan.Add(('| status | `{0}` |' -f $status))
$plan.Add("")
$plan.Add("## Compliance Reminder")
$plan.Add("")
$plan.Add("- This report is metadata-only and dry-run by default.")
$plan.Add("- The script does not move, delete, compress, or archive files.")
$plan.Add("- Review candidate paths manually before running any real command.")
$plan.Add("- Do not include `.env`, secrets, provider credentials, payment data, or business source code in hygiene operations.")
$plan.Add("")
$plan.Add("## Target Directory Inventory")
$plan.Add("")
$plan.Add("| Target | Resolved path | Status | Files | Directories | Candidate files | Candidate directories | Total size |")
$plan.Add("| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |")
foreach ($summary in $targetSummaries) {
  $plan.Add(('| `{0}` | `{1}` | `{2}` | {3} | {4} | {5} | {6} | {7} |' -f $summary.target, $summary.path, $summary.status, $summary.total_files, $summary.total_directories, $summary.candidate_files, $summary.candidate_directories, (Format-Bytes -Bytes $summary.total_size_bytes)))
}
$plan.Add("")
$plan.Add("## Archive Candidate Summary")
$plan.Add("")
$plan.Add(('- total_candidate_items: `{0}`' -f $allCandidateCount))
$plan.Add(('- displayed_candidate_items: `{0}`' -f $archiveCandidates.Count))
$plan.Add(('- max_entries: `{0}`' -f $MaxEntries))
$plan.Add("")

if ($archiveCandidates.Count -gt 0) {
  $plan.Add("| Type | Relative path | Last write time | Size |")
  $plan.Add("| --- | --- | --- | ---: |")
  foreach ($candidate in $archiveCandidates) {
    $size = if ($null -eq $candidate.size_bytes) { "-" } else { Format-Bytes -Bytes $candidate.size_bytes }
    $plan.Add(('| `{0}` | `{1}` | `{2}` | {3} |' -f $candidate.type, $candidate.path, $candidate.last_write_time.ToString("s"), $size))
  }
} else {
  $plan.Add("No archive candidates found for the configured threshold.")
}

$plan.Add("")
$plan.Add("## Sensitive-Shaped Path Checks")
$plan.Add("")
if ($sensitivePathHits.Count -gt 0) {
  $plan.Add("Blocked: one or more path names look sensitive. Do not archive these paths through this Skill.")
  $plan.Add("")
  $plan.Add("| Target | Relative path | Last write time |")
  $plan.Add("| --- | --- | --- |")
  foreach ($hit in $sensitivePathHits) {
    $plan.Add(('| `{0}` | `{1}` | `{2}` |' -f $hit.target, $hit.path, $hit.last_write_time.ToString("s")))
  }
} else {
  $plan.Add('- sensitive_shaped_path_hits: `0`')
}

$plan.Add("")
$plan.Add("## Dry-Run Command")
$plan.Add("")
$plan.Add('```powershell')
$plan.Add("& $scriptLiteral -RootPath $rootLiteral -TargetDirectories @($targetLiteralList) -OlderThanDays $OlderThanDays -DryRun:`$true")
$plan.Add('```')
$plan.Add("")
$plan.Add("## Real Execution Command Template")
$plan.Add("")
$plan.Add("Only run after manual review and explicit approval. Edit the candidate path list before execution.")
$plan.Add("")
$plan.Add('```powershell')
$plan.Add("`$archiveRoot = $archiveRootLiteral")
$plan.Add("New-Item -ItemType Directory -Force -Path `$archiveRoot | Out-Null")
$plan.Add("# For each approved candidate only:")
$plan.Add("Move-Item -LiteralPath '<approved-candidate-path>' -Destination `$archiveRoot")
$plan.Add('```')
$plan.Add("")
$plan.Add("## Issues")
$plan.Add("")
if ($issues.Count -gt 0) {
  foreach ($issue in $issues) {
    $plan.Add(('- `{0}`' -f $issue))
  }
} else {
  $plan.Add("- none")
}

$plan | Set-Content -LiteralPath $outputPath -Encoding UTF8
Write-Log ("wrote_plan={0}" -f $outputPath)

$result = [PSCustomObject]@{
  status = $status
  generated_at = (Get-Date).ToString("s")
  root_path = $root
  output_path = $outputPath
  dry_run = $DryRun
  older_than_days = $OlderThanDays
  target_directories = $TargetDirectories
  target_summaries = $targetSummaries
  candidate_items = $allCandidateCount
  displayed_candidate_items = $archiveCandidates.Count
  sensitive_shaped_path_hits = $sensitivePathHits.Count
  blocked_targets = $blockedTargets.Count
  issues = $issues
  compliance_note = "Plan-only. No files were moved, deleted, compressed, or archived."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  $result | Format-List
}

if ($status -eq "blocked") {
  exit 2
}

exit 0
