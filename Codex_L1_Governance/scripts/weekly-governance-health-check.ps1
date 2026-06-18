<#
Skill: weekly-governance-health-check
Trigger: weekly L1 governance review, major gate refresh, or audit-readiness check.
Recommendation: run before closing a weekly governance cycle and record the generated Markdown report.

Compliance reminder:
- Read-only orchestration of existing validators.
- Does not change gate status, evidence status, project readiness, or revenue readiness.
- Does not read `.env` files; env-like paths are counted and treated as blockers.
#>

param(
  [string]$GovernanceRoot = "",
  [string[]]$ArtifactTargetDirectories = @("artifacts", "screenshots", "logs", "mcp"),
  [int]$OlderThanDays = 90,
  [string]$OutputDirectory = "",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Write-Log {
  param([string]$Message)
  if (-not $Json) {
    Write-Host ("[weekly-governance-health-check] {0}" -f $Message)
  }
}

function Resolve-GovernanceRoot {
  param([string]$InputRoot)

  if ([string]::IsNullOrWhiteSpace($InputRoot)) {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
  }

  return (Resolve-Path -LiteralPath $InputRoot).Path
}

function Convert-ToPowerShellLiteral {
  param([string]$Value)
  return "'" + ($Value -replace "'", "''") + "'"
}

function Test-PathInsideRoot {
  param(
    [string]$Root,
    [string]$Path
  )

  $rootFull = [System.IO.Path]::GetFullPath($Root)
  $pathFull = [System.IO.Path]::GetFullPath($Path)
  $separator = [System.IO.Path]::DirectorySeparatorChar

  if (-not $rootFull.EndsWith([string]$separator)) {
    $rootFull = $rootFull + $separator
  }

  return $pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)
}

function Convert-ScriptOutput {
  param(
    [string]$ScriptPath,
    [object[]]$Output,
    [int]$ExitCode
  )

  $text = ($Output | Out-String).Trim()
  $parsed = $null

  try {
    if (-not [string]::IsNullOrWhiteSpace($text)) {
      $parsed = $text | ConvertFrom-Json
    }
  } catch {
    $parsed = $null
  }

  [PSCustomObject]@{
    script = $ScriptPath
    exit_code = $ExitCode
    raw_output = $text
    json = $parsed
  }
}

function Invoke-SecretShapeScan {
  param([string]$Root)

  $patterns = @(
    "sk_live_[A-Za-z0-9]{10,}",
    "sk_test_[A-Za-z0-9]{10,}",
    "whsec_[A-Za-z0-9]{10,}",
    "eyJ[A-Za-z0-9_-]{20,}",
    "-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----"
  )
  $combined = [string]::Join("|", $patterns)

  $allFiles = @(
    Get-ChildItem -LiteralPath $Root -Recurse -Force -File -ErrorAction SilentlyContinue
  )
  $envLikeFiles = @(
    $allFiles | Where-Object { $_.Name -like ".env*" }
  )

  $scannableFiles = @(
    $allFiles |
      Where-Object {
        $_.Name -notlike ".env*" -and
        $_.Length -le 5MB -and
        $_.Extension -in @(".md", ".json", ".ps1", ".txt", "")
      }
  )

  $hits = New-Object System.Collections.Generic.List[object]
  foreach ($file in $scannableFiles) {
    try {
      $matches = Select-String -LiteralPath $file.FullName -Pattern $combined -AllMatches -ErrorAction Stop
      foreach ($match in $matches) {
        $hits.Add([PSCustomObject]@{
          path = $file.FullName
          line = $match.LineNumber
        })
      }
    } catch {
      $hits.Add([PSCustomObject]@{
        path = $file.FullName
        line = "scan_error"
      })
    }
  }

  [PSCustomObject]@{
    scanned_files = $scannableFiles.Count
    env_like_files = $envLikeFiles.Count
    secret_shape_hits = $hits.Count
    hit_locations = @($hits | Select-Object -First 20)
  }
}

function Add-TableRow {
  param(
    [System.Collections.Generic.List[string]]$Lines,
    [string[]]$Cells
  )

  $Lines.Add("| " + ($Cells -join " | ") + " |")
}

function Format-InlineCode {
  param([object]$Value)
  return "``{0}``" -f $Value
}

$root = Resolve-GovernanceRoot -InputRoot $GovernanceRoot
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $root "weekly_health_reports"
}

if (-not (Test-PathInsideRoot -Root $root -Path $OutputDirectory)) {
  throw "OutputDirectory must stay inside GovernanceRoot. output=$OutputDirectory root=$root"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$dateStamp = Get-Date -Format "yyyy-MM-dd"
$outputPath = Join-Path $OutputDirectory ("Weekly_Governance_Health_{0}.md" -f $dateStamp)

$roundScript = Join-Path $PSScriptRoot "round-closeout-validator.ps1"
$hygieneScript = Join-Path $PSScriptRoot "governance-artifact-hygiene.ps1"

Write-Log ("root={0}" -f $root)
Write-Log "running round-closeout-validator"
try {
  $roundOutput = @(& $roundScript -GovernanceRoot $root -Json 2>&1)
  $roundExitCode = $LASTEXITCODE
} catch {
  $roundOutput = @($_.Exception.Message)
  $roundExitCode = if ($LASTEXITCODE) { $LASTEXITCODE } else { 2 }
}
$roundResult = Convert-ScriptOutput -ScriptPath $roundScript -Output $roundOutput -ExitCode $roundExitCode

Write-Log "running governance-artifact-hygiene dry-run"
$targetLiteralList = (($ArtifactTargetDirectories | ForEach-Object { Convert-ToPowerShellLiteral -Value $_ }) -join ", ")
try {
  $hygieneOutput = @(& $hygieneScript -RootPath $root -TargetDirectories $ArtifactTargetDirectories -OlderThanDays $OlderThanDays -DryRun $true -Json 2>&1)
  $hygieneExitCode = $LASTEXITCODE
} catch {
  $hygieneOutput = @($_.Exception.Message)
  $hygieneExitCode = if ($LASTEXITCODE) { $LASTEXITCODE } else { 2 }
}
$hygieneResult = Convert-ScriptOutput -ScriptPath $hygieneScript -Output $hygieneOutput -ExitCode $hygieneExitCode

Write-Log "running L1 secret-shape scan"
$secretScan = Invoke-SecretShapeScan -Root $root

$issues = New-Object System.Collections.Generic.List[string]
$score = 100

$roundStatus = if ($roundResult.json -and $roundResult.json.closeout_status) { $roundResult.json.closeout_status } else { "unknown" }
if ($roundResult.exit_code -ne 0 -or $roundStatus -eq "blocked") {
  $score -= 35
  $issues.Add("round_closeout_blocked")
} elseif ($roundStatus -eq "conditional") {
  $score -= 15
  $issues.Add("round_closeout_conditional")
}

$hygieneStatus = if ($hygieneResult.json -and $hygieneResult.json.status) { $hygieneResult.json.status } else { "unknown" }
if ($hygieneResult.exit_code -ne 0 -or $hygieneStatus -eq "blocked") {
  $score -= 25
  $issues.Add("artifact_hygiene_blocked")
}

if ($secretScan.secret_shape_hits -gt 0) {
  $score -= 50
  $issues.Add("secret_shape_hits_present")
}

if ($secretScan.env_like_files -gt 0) {
  $score -= 25
  $issues.Add("env_like_files_present")
}

if ($score -lt 0) { $score = 0 }

$overallStatus = if ($issues.Count -eq 0 -and $score -ge 90) {
  "pass"
} elseif ($score -ge 70) {
  "conditional"
} else {
  "blocked"
}

$report = New-Object System.Collections.Generic.List[string]
$report.Add("# Weekly Governance Health $dateStamp")
$report.Add("")
$report.Add("## Summary")
$report.Add("")
Add-TableRow -Lines $report -Cells @("Field", "Value")
Add-TableRow -Lines $report -Cells @("---", "---")
Add-TableRow -Lines $report -Cells @("status", (Format-InlineCode $overallStatus))
Add-TableRow -Lines $report -Cells @("score", (Format-InlineCode ("{0}/100" -f $score)))
Add-TableRow -Lines $report -Cells @("generated_at", (Format-InlineCode (Get-Date -Format s)))
Add-TableRow -Lines $report -Cells @("governance_root", (Format-InlineCode $root))
$report.Add("")
$report.Add("## Round Closeout")
$report.Add("")
Add-TableRow -Lines $report -Cells @("Field", "Value")
Add-TableRow -Lines $report -Cells @("---", "---")
Add-TableRow -Lines $report -Cells @("exit_code", (Format-InlineCode $roundResult.exit_code))
Add-TableRow -Lines $report -Cells @("closeout_status", (Format-InlineCode $roundStatus))
if ($roundResult.json -and $roundResult.json.decision_summary) {
  Add-TableRow -Lines $report -Cells @("overall_decision", (Format-InlineCode $roundResult.json.decision_summary.overall_decision))
  Add-TableRow -Lines $report -Cells @("execution_go", (Format-InlineCode $roundResult.json.decision_summary.execution_go))
}
$report.Add("")
$report.Add("## Artifact Hygiene")
$report.Add("")
Add-TableRow -Lines $report -Cells @("Field", "Value")
Add-TableRow -Lines $report -Cells @("---", "---")
Add-TableRow -Lines $report -Cells @("exit_code", (Format-InlineCode $hygieneResult.exit_code))
Add-TableRow -Lines $report -Cells @("status", (Format-InlineCode $hygieneStatus))
if ($hygieneResult.json) {
  Add-TableRow -Lines $report -Cells @("candidate_items", (Format-InlineCode $hygieneResult.json.candidate_items))
  Add-TableRow -Lines $report -Cells @("sensitive_shaped_path_hits", (Format-InlineCode $hygieneResult.json.sensitive_shaped_path_hits))
  Add-TableRow -Lines $report -Cells @("archive_plan", (Format-InlineCode $hygieneResult.json.output_path))
}
$report.Add("")
$report.Add("## Secret And Env-Like Scan")
$report.Add("")
Add-TableRow -Lines $report -Cells @("Field", "Value")
Add-TableRow -Lines $report -Cells @("---", "---")
Add-TableRow -Lines $report -Cells @("scanned_files", (Format-InlineCode $secretScan.scanned_files))
Add-TableRow -Lines $report -Cells @("secret_shape_hits", (Format-InlineCode $secretScan.secret_shape_hits))
Add-TableRow -Lines $report -Cells @("env_like_files", (Format-InlineCode $secretScan.env_like_files))
$report.Add("")
$report.Add("## Commands")
$report.Add("")
$report.Add('```powershell')
$report.Add("& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 -Json")
$report.Add("& .\Codex_L1_Governance\scripts\round-closeout-validator.ps1 -Json")
$report.Add(("& .\Codex_L1_Governance\scripts\governance-artifact-hygiene.ps1 -TargetDirectories @({0}) -OlderThanDays {1} -DryRun:`$true -Json" -f $targetLiteralList, $OlderThanDays))
$report.Add('```')
$report.Add("")
$report.Add("## Issues")
$report.Add("")
if ($issues.Count -gt 0) {
  foreach ($issue in $issues) {
    $report.Add(("- {0}" -f (Format-InlineCode $issue)))
  }
} else {
  $report.Add("- none")
}
$report.Add("")
$report.Add("## Compliance Boundary")
$report.Add("")
$report.Add("- This report is L1 governance-only.")
$report.Add("- This report does not grant project execution, revenue, payment, or production readiness.")
$report.Add("- No files were moved, deleted, compressed, archived, or modified by the artifact hygiene step.")

$report | Set-Content -LiteralPath $outputPath -Encoding UTF8
Write-Log ("wrote_report={0}" -f $outputPath)

$result = [PSCustomObject]@{
  status = $overallStatus
  score = $score
  generated_at = (Get-Date).ToString("s")
  governance_root = $root
  output_path = $outputPath
  round_closeout = [PSCustomObject]@{
    exit_code = $roundResult.exit_code
    status = $roundStatus
  }
  artifact_hygiene = [PSCustomObject]@{
    exit_code = $hygieneResult.exit_code
    status = $hygieneStatus
    candidate_items = if ($hygieneResult.json) { $hygieneResult.json.candidate_items } else { $null }
    sensitive_shaped_path_hits = if ($hygieneResult.json) { $hygieneResult.json.sensitive_shaped_path_hits } else { $null }
  }
  secret_scan = $secretScan
  issues = @($issues)
  compliance_note = "L1 governance-only. No gate decision changed."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  $result | Format-List
}

if ($overallStatus -eq "blocked") {
  exit 2
}

if ($overallStatus -eq "conditional") {
  exit 1
}

exit 0
