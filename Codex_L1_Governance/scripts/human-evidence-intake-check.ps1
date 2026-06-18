<#
Skill: human-evidence-intake-check
Trigger: Human Operator submits or updates masked evidence.
Recommendation: run after evidence intake and before using evidence in an orchestrator decision refresh.

Compliance reminder:
- Read-only evidence intake validation.
- Does not change `submitted_by`, `present`, evidence rows, or gate decisions.
- Does not read `.env`, raw secret files, provider credentials, payment data, or production credentials.
#>

param(
  [string]$GovernanceRoot = "",
  [string]$EvidenceFile = "",
  [int]$MinRequiredRows = 5,
  [bool]$DryRun = $true,
  [string]$OutputDirectory = "",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Write-Log {
  param([string]$Message)
  if (-not $Json) {
    Write-Host ("[human-evidence-intake-check] {0}" -f $Message)
  }
}

function Resolve-GovernanceRoot {
  param([string]$InputRoot)

  if ([string]::IsNullOrWhiteSpace($InputRoot)) {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
  }

  return (Resolve-Path -LiteralPath $InputRoot).Path
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

function Get-DefaultEvidenceFile {
  param([string]$Root)

  $projectEvidence = Get-ChildItem -LiteralPath (Join-Path $Root "Projects") -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like "*Evidence_Gate*.md" } |
    Select-Object -First 1
  if ($projectEvidence) {
    return $projectEvidence.FullName
  }

  $templateEvidence = Get-ChildItem -LiteralPath (Join-Path $Root "02_Gate_System\Evidence_Gate") -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like "Evidence_Human_Operator_*.md" } |
    Select-Object -First 1
  if ($templateEvidence) {
    return $templateEvidence.FullName
  }

  return (Join-Path $Root "02_Gate_System\Evidence_Gate\Evidence_Human_Operator_Template.md")
}

function Test-SensitivePathShape {
  param([string]$Path)

  $normalized = $Path -replace "\\", "/"
  return $normalized -match "(^|/)(\.env[^/]*|secrets?|tokens?|keys?|provider|payment)(/|$|[._-])"
}

function Test-MissingValue {
  param([string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) { return $true }
  $trimmed = $Value.Trim()
  return $trimmed -match "^(todo|tbd|unknown|placeholder|synthetic|fake|n/a|\(.*\))$"
}

function Get-FieldValue {
  param(
    [string]$Content,
    [string]$FieldName
  )

  $escaped = [regex]::Escape($FieldName)
  $match = [regex]::Match($Content, "\*\*$escaped\*\*:\s*(?<value>[^\r\n]*)")
  if ($match.Success) {
    return $match.Groups["value"].Value.Trim()
  }

  return ""
}

function Invoke-SecretShapeScan {
  param([string]$Content)

  $patterns = @(
    "sk_live_[A-Za-z0-9]{10,}",
    "sk_test_[A-Za-z0-9]{10,}",
    "whsec_[A-Za-z0-9]{10,}",
    "eyJ[A-Za-z0-9_-]{20,}",
    "-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----"
  )
  $combined = [string]::Join("|", $patterns)
  return ([regex]::Matches($Content, $combined)).Count
}

function Parse-EvidenceRows {
  param([string[]]$Lines)

  $rows = New-Object System.Collections.Generic.List[object]
  foreach ($line in $Lines) {
    if ($line -notmatch "^\|\s*EV-[^|]+\|") { continue }
    if ($line -match "^\|\s*---") { continue }

    $cells = @($line.Trim().Trim("|").Split("|") | ForEach-Object { $_.Trim() })
    if ($cells.Count -lt 5) { continue }

    $rows.Add([PSCustomObject]@{
      row_id = $cells[0]
      required_claim = $cells[1]
      present = $cells[2].ToLowerInvariant()
      evidence_path = $cells[3]
      notes = $cells[4]
    })
  }

  return $rows.ToArray()
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
if ([string]::IsNullOrWhiteSpace($EvidenceFile)) {
  $EvidenceFile = Get-DefaultEvidenceFile -Root $root
}

$evidencePath = [System.IO.Path]::GetFullPath($EvidenceFile)
if (-not (Test-PathInsideRoot -Root $root -Path $evidencePath)) {
  throw "EvidenceFile must stay inside GovernanceRoot. evidence=$evidencePath root=$root"
}

if (Test-SensitivePathShape -Path $evidencePath) {
  throw "EvidenceFile path looks sensitive. evidence=$evidencePath"
}

if (-not (Test-Path -LiteralPath $evidencePath -PathType Leaf)) {
  throw "EvidenceFile not found. evidence=$evidencePath"
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $root "evidence_intake_reports"
}

if (-not (Test-PathInsideRoot -Root $root -Path $OutputDirectory)) {
  throw "OutputDirectory must stay inside GovernanceRoot. output=$OutputDirectory root=$root"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$dateStamp = Get-Date -Format "yyyy-MM-dd"
$outputPath = Join-Path $OutputDirectory ("Evidence_Intake_Report_{0}.md" -f $dateStamp)

Write-Log ("evidence_file={0}" -f $evidencePath)
Write-Log ("dry_run={0}" -f $DryRun)

$content = Get-Content -Raw -LiteralPath $evidencePath
$lines = @($content -split "\r?\n")

$fields = [ordered]@{
  submitted_by = Get-FieldValue -Content $content -FieldName "submitted_by"
  role = Get-FieldValue -Content $content -FieldName "role"
  submitted_at = Get-FieldValue -Content $content -FieldName "submitted_at"
  verified_environment = Get-FieldValue -Content $content -FieldName "verified_environment"
  verification_scope = Get-FieldValue -Content $content -FieldName "verification_scope"
}

$missingFields = New-Object System.Collections.Generic.List[string]
foreach ($fieldName in $fields.Keys) {
  if (Test-MissingValue -Value $fields[$fieldName]) {
    $missingFields.Add($fieldName)
  }
}

$rows = @(Parse-EvidenceRows -Lines $lines)
$presentYesRows = @($rows | Where-Object { $_.present -eq "yes" })
$presentNoRows = @($rows | Where-Object { $_.present -eq "no" })
$invalidPresentRows = @($rows | Where-Object { $_.present -notin @("yes", "no") })
$yesRowsMissingEvidence = @(
  $presentYesRows |
    Where-Object {
      Test-MissingValue -Value $_.evidence_path -or $_.evidence_path -eq "todo"
    }
)

$secretShapeHits = Invoke-SecretShapeScan -Content $content

$issues = New-Object System.Collections.Generic.List[string]
if ($missingFields.Contains("submitted_by")) { $issues.Add("submitted_by_missing") }
if ($missingFields.Contains("submitted_at")) { $issues.Add("submitted_at_missing") }
if ($missingFields.Contains("verified_environment")) { $issues.Add("verified_environment_missing") }
if ($rows.Count -lt $MinRequiredRows) { $issues.Add("evidence_rows_incomplete") }
if ($invalidPresentRows.Count -gt 0) { $issues.Add("invalid_present_values") }
if ($yesRowsMissingEvidence.Count -gt 0) { $issues.Add("present_yes_without_evidence_path") }
if ($secretShapeHits -gt 0) { $issues.Add("possible_secret_exposure") }

$status = if ($secretShapeHits -gt 0) {
  "blocked"
} elseif ($issues.Count -gt 0) {
  "blocked"
} elseif ($presentYesRows.Count -eq 0) {
  "blocked"
} else {
  "pass_for_orchestrator_review"
}

$recommendation = if ($status -eq "pass_for_orchestrator_review") {
  "Evidence intake can enter orchestrator-decision-refresh as masked evidence input. This is not a final gate pass."
} else {
  "Do not treat evidence as ready. Preserve blocked state until a real Human Operator submission exists."
}

$report = New-Object System.Collections.Generic.List[string]
$report.Add("# Evidence Intake Report $dateStamp")
$report.Add("")
$report.Add("## Summary")
$report.Add("")
Add-TableRow -Lines $report -Cells @("Field", "Value")
Add-TableRow -Lines $report -Cells @("---", "---")
Add-TableRow -Lines $report -Cells @("status", (Format-InlineCode $status))
Add-TableRow -Lines $report -Cells @("generated_at", (Format-InlineCode (Get-Date -Format s)))
Add-TableRow -Lines $report -Cells @("evidence_file", (Format-InlineCode $evidencePath))
Add-TableRow -Lines $report -Cells @("dry_run", (Format-InlineCode $DryRun))
$report.Add("")
$report.Add("## Required Fields")
$report.Add("")
Add-TableRow -Lines $report -Cells @("Field", "Value", "Missing")
Add-TableRow -Lines $report -Cells @("---", "---", "---")
foreach ($fieldName in $fields.Keys) {
  $value = if ([string]::IsNullOrWhiteSpace($fields[$fieldName])) { "" } else { $fields[$fieldName] }
  Add-TableRow -Lines $report -Cells @($fieldName, (Format-InlineCode $value), (Format-InlineCode (Test-MissingValue -Value $value)))
}
$report.Add("")
$report.Add("## Row Summary")
$report.Add("")
Add-TableRow -Lines $report -Cells @("Metric", "Value")
Add-TableRow -Lines $report -Cells @("---", "---")
Add-TableRow -Lines $report -Cells @("total_rows", (Format-InlineCode $rows.Count))
Add-TableRow -Lines $report -Cells @("present_yes", (Format-InlineCode $presentYesRows.Count))
Add-TableRow -Lines $report -Cells @("present_no", (Format-InlineCode $presentNoRows.Count))
Add-TableRow -Lines $report -Cells @("invalid_present", (Format-InlineCode $invalidPresentRows.Count))
Add-TableRow -Lines $report -Cells @("present_yes_without_evidence_path", (Format-InlineCode $yesRowsMissingEvidence.Count))
$report.Add("")
$report.Add("## Secret-Shape Safety")
$report.Add("")
$report.Add(("- secret_shape_hits: {0}" -f (Format-InlineCode $secretShapeHits)))
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
$report.Add("## Recommendation")
$report.Add("")
$report.Add($recommendation)
$report.Add("")
$report.Add("## Compliance Boundary")
$report.Add("")
$report.Add("- This script is read-only.")
$report.Add("- This script does not change submitted_by, present values, evidence rows, or gate decisions.")
$report.Add("- This script does not make the final real_go decision.")

$report | Set-Content -LiteralPath $outputPath -Encoding UTF8
Write-Log ("wrote_report={0}" -f $outputPath)

$result = [PSCustomObject]@{
  status = $status
  generated_at = (Get-Date).ToString("s")
  evidence_file = $evidencePath
  output_path = $outputPath
  dry_run = $DryRun
  missing_fields = @($missingFields)
  row_summary = [PSCustomObject]@{
    total_rows = $rows.Count
    present_yes = $presentYesRows.Count
    present_no = $presentNoRows.Count
    invalid_present = $invalidPresentRows.Count
    present_yes_without_evidence_path = $yesRowsMissingEvidence.Count
  }
  secret_shape_hits = $secretShapeHits
  issues = @($issues)
  recommendation = $recommendation
  compliance_note = "Read-only intake validation. No evidence or gate state was changed."
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
