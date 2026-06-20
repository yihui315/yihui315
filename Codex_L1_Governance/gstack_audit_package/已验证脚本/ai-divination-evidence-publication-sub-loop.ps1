<#
Skill: ai-divination-evidence-publication-sub-loop
Trigger: ai占卜.ai remains blocked while Human evidence and publication-proof templates exist.
Scope: Detect and Prepare stages only.

Compliance reminder:
- Reads sanitized governance Markdown only.
- Runs human-evidence-intake-check in read-only mode.
- Generates reports and Human task lists only.
- Does not publish content, change evidence rows, set execution_go, or claim revenue readiness.
#>

param(
  [string]$GovernanceRoot = "",
  [string]$EvidenceFile = "",
  [string]$GateDecisionFile = "",
  [string]$OutputDirectory = "",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Resolve-GovernanceRoot {
  param([string]$InputRoot)
  if ([string]::IsNullOrWhiteSpace($InputRoot)) {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
  }
  return (Resolve-Path -LiteralPath $InputRoot).Path
}

function Test-PathInsideRoot {
  param([string]$Root, [string]$Path)
  $rootFull = [System.IO.Path]::GetFullPath($Root)
  $pathFull = [System.IO.Path]::GetFullPath($Path)
  $separator = [System.IO.Path]::DirectorySeparatorChar
  if (-not $rootFull.EndsWith([string]$separator)) { $rootFull += $separator }
  return $pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-ProjectFile {
  param([string]$Root, [string]$NamePattern)
  $file = Get-ChildItem -LiteralPath (Join-Path $Root "Projects") -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like $NamePattern } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if (-not $file) { throw "Project file not found: $NamePattern" }
  return $file.FullName
}

function Get-MarkdownFieldValue {
  param([string]$Content, [string]$Field)
  $escaped = [regex]::Escape($Field)
  $match = [regex]::Match($Content, "\*\*$escaped\*\*:\s*([^\r\n]+)")
  if (-not $match.Success) { return "" }
  return $match.Groups[1].Value.Trim().Trim('`')
}

function Test-MissingValue {
  param([string]$Value)
  return [string]::IsNullOrWhiteSpace($Value) -or $Value -match "(?i)^todo" -or $Value -match "(?i)not yet provided"
}

function Add-TableRow {
  param([System.Collections.Generic.List[string]]$Lines, [string[]]$Cells)
  $Lines.Add("| " + ($Cells -join " | ") + " |")
}

$root = Resolve-GovernanceRoot -InputRoot $GovernanceRoot
if ([string]::IsNullOrWhiteSpace($EvidenceFile)) {
  $EvidenceFile = Get-ProjectFile -Root $root -NamePattern "*Evidence_Gate*.md"
}
if ([string]::IsNullOrWhiteSpace($GateDecisionFile)) {
  $GateDecisionFile = Get-ProjectFile -Root $root -NamePattern "*Gate_Decision*.md"
}

$resolvedEvidenceFile = (Resolve-Path -LiteralPath $EvidenceFile).Path
$resolvedGateDecisionFile = (Resolve-Path -LiteralPath $GateDecisionFile).Path
$projectStateDirectory = Split-Path -Parent $resolvedEvidenceFile
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $projectStateDirectory "sub_loop_reports"
}

foreach ($path in @($resolvedEvidenceFile, $resolvedGateDecisionFile, $OutputDirectory)) {
  if (-not (Test-PathInsideRoot -Root $root -Path $path)) {
    throw "Path must stay inside GovernanceRoot. path=$path root=$root"
  }
}

$packetTemplate = Join-Path $projectStateDirectory "Human_Operator_Evidence_Packet_Template_2026-06-20.md"
$fillingGuide = Join-Path $projectStateDirectory "Human_Operator_Evidence_Packet_Filling_Guide_2026-06-20.md"
$publicationChecklist = Join-Path $projectStateDirectory "Manual_Publication_Proof_Checklist_2026-06-20.md"
$publicationTemplate = Join-Path $projectStateDirectory "Post_Publication_Evidence_Collection_Template_2026-06-20.md"
$requiredFiles = @($packetTemplate, $fillingGuide, $publicationChecklist, $publicationTemplate)
foreach ($path in $requiredFiles) {
  if (-not (Test-Path -LiteralPath $path)) { throw "Required template not found: $path" }
}

$evidenceContent = Get-Content -LiteralPath $resolvedEvidenceFile -Raw
$decisionContent = Get-Content -LiteralPath $resolvedGateDecisionFile -Raw
$operatorFields = @("submitted_by", "role", "submitted_at", "verified_environment")
$missingOperatorFields = New-Object System.Collections.Generic.List[string]
foreach ($field in $operatorFields) {
  $value = Get-MarkdownFieldValue -Content $evidenceContent -Field $field
  if (Test-MissingValue -Value $value) { $missingOperatorFields.Add($field) }
}

$evidenceRows = New-Object System.Collections.Generic.List[object]
foreach ($line in ($evidenceContent -split "`r?`n")) {
  if ($line -match '^\|\s*EV-\d{3}\s*\|') {
    $cells = @($line.Trim('|') -split '\|' | ForEach-Object { $_.Trim().Trim('`') })
    if ($cells.Count -ge 4) {
      $evidenceRows.Add([PSCustomObject]@{
        row_id = $cells[0]
        required_claim = $cells[1]
        present = $cells[2]
        artifact_path = $cells[3]
        missing = ($cells[2] -ne "yes" -or (Test-MissingValue -Value $cells[3]))
      })
    }
  }
}
$missingEvidenceRows = @($evidenceRows | Where-Object { $_.missing })

$decisionNoGo = $decisionContent -match 'overall_decision\s*\|\s*`no_go`'
$executionGoFalse = $decisionContent -match 'execution_go\s*\|\s*`false`'

$intakeScript = Join-Path $root "scripts\human-evidence-intake-check.ps1"
$intakeOutput = @(& $intakeScript -EvidenceFile $resolvedEvidenceFile -Json 2>&1)
$intakeExitCode = $LASTEXITCODE
$intakeText = ($intakeOutput | Out-String).Trim()
$intake = $null
try { $intake = $intakeText | ConvertFrom-Json } catch { throw "Evidence intake output was not valid JSON." }

$tasks = @(
  [PSCustomObject]@{ id = "HUMAN-001"; owner = "Human Operator"; status = if ($missingOperatorFields.Count -gt 0) { "pending" } else { "complete" }; action = "Fill real submitted_by, role, submitted_at, and verified_environment fields."; source = $packetTemplate },
  [PSCustomObject]@{ id = "HUMAN-002"; owner = "Human Operator"; status = "pending"; action = "Select one approved pending_manual_review asset and publish it manually through an approved account/channel."; source = $publicationChecklist },
  [PSCustomObject]@{ id = "HUMAN-003"; owner = "Human Operator"; status = "pending"; action = "Capture public URL/channel proof, publish timestamp, masked account label, and masked screenshot/archive."; source = $publicationTemplate },
  [PSCustomObject]@{ id = "HUMAN-004"; owner = "Human Operator"; status = "pending"; action = "Add one timestamped KPI observation row; record masked demand/revenue signal only if real evidence exists."; source = $publicationTemplate },
  [PSCustomObject]@{ id = "CODEX-001"; owner = "Codex"; status = "ready"; action = "Rerun human-evidence-intake-check after the Human Operator updates the real evidence file."; source = $intakeScript }
)

$missingItems = New-Object System.Collections.Generic.List[object]
foreach ($field in $missingOperatorFields) {
  $missingItems.Add([PSCustomObject]@{ type = "operator_field"; id = $field; owner = "Human Operator"; blocking = $true })
}
foreach ($row in $missingEvidenceRows) {
  $missingItems.Add([PSCustomObject]@{ type = "evidence_row"; id = $row.row_id; owner = "Human Operator + Reviewer"; blocking = $true })
}
$missingItems.Add([PSCustomObject]@{ type = "publication_proof"; id = "manual_publication_proof"; owner = "Human Operator"; blocking = $true })
$missingItems.Add([PSCustomObject]@{ type = "kpi"; id = "timestamped_kpi_row"; owner = "Human Operator"; blocking = $true })
$missingItems.Add([PSCustomObject]@{ type = "demand_or_revenue"; id = "masked_signal_if_available"; owner = "Human Operator"; blocking = $true })

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$dateStamp = Get-Date -Format "yyyy-MM-dd"
$jsonOutputPath = Join-Path $OutputDirectory ("AI_Divination_Evidence_Sub_Loop_{0}.json" -f $dateStamp)
$markdownOutputPath = Join-Path $OutputDirectory ("AI_Divination_Evidence_Sub_Loop_{0}.md" -f $dateStamp)

$report = [PSCustomObject]@{
  report_type = "ai_divination_evidence_publication_sub_loop_detect_prepare"
  generated_at = (Get-Date).ToString("s")
  status = "blocked_human_action_required"
  current_phase = "prepare"
  source_evidence_file = $resolvedEvidenceFile
  source_gate_decision_file = $resolvedGateDecisionFile
  gate_snapshot = [PSCustomObject]@{
    overall_no_go = $decisionNoGo
    execution_go_false = $executionGoFalse
  }
  detect = [PSCustomObject]@{
    missing_operator_fields = @($missingOperatorFields)
    evidence_rows_total = $evidenceRows.Count
    evidence_rows_missing = $missingEvidenceRows.Count
    evidence_present_yes = @($evidenceRows | Where-Object { $_.present -eq "yes" }).Count
    evidence_present_no = @($evidenceRows | Where-Object { $_.present -eq "no" }).Count
    missing_items = @($missingItems.ToArray())
    intake_status = $intake.status
    intake_exit_code = $intakeExitCode
    secret_shape_hits = $intake.secret_shape_hits
  }
  prepare = [PSCustomObject]@{
    task_list = $tasks
    packet_template = $packetTemplate
    filling_guide = $fillingGuide
    publication_checklist = $publicationChecklist
    publication_evidence_template = $publicationTemplate
    next_human_action = "Fill the real Human Operator packet and one manual publication proof packet with masked artifacts."
  }
  safe_auto = @("detect_missing_items", "prepare_task_list", "run_read_only_intake", "generate_report")
  human_required = @("publish_content", "capture_real_masked_proof", "submit_real_operator_attestation", "review_candidate_present_yes")
  forbidden = @("set_execution_go_true", "fabricate_evidence", "claim_revenue_readiness_without_real_masked_evidence")
  compliance_note = "Detect and Prepare only. No gate, evidence, revenue, publication, payment, provider, or production state changed."
}

$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonOutputPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# ai占卜.ai Evidence & Publication Proof Sub-Loop $dateStamp")
$lines.Add("")
$lines.Add("## Detect Result")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Metric", "Value")
Add-TableRow -Lines $lines -Cells @("---", "---")
Add-TableRow -Lines $lines -Cells @("status", "``$($report.status)``")
Add-TableRow -Lines $lines -Cells @("current_phase", "``$($report.current_phase)``")
Add-TableRow -Lines $lines -Cells @("overall_no_go", "``$decisionNoGo``")
Add-TableRow -Lines $lines -Cells @("execution_go_false", "``$executionGoFalse``")
Add-TableRow -Lines $lines -Cells @("missing_operator_fields", "``$($missingOperatorFields.Count)``")
Add-TableRow -Lines $lines -Cells @("evidence_rows_missing", "``$($missingEvidenceRows.Count)``")
Add-TableRow -Lines $lines -Cells @("intake_status", "``$($intake.status)``")
Add-TableRow -Lines $lines -Cells @("secret_shape_hits", "``$($intake.secret_shape_hits)``")
$lines.Add("")
$lines.Add("## Missing Evidence Items")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Type", "ID", "Owner", "Blocking")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---")
foreach ($item in $missingItems) {
  Add-TableRow -Lines $lines -Cells @($item.type, $item.id, $item.owner, "``$($item.blocking)``")
}
$lines.Add("")
$lines.Add("## Prepare Task List")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Task", "Owner", "Status", "Action")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---")
foreach ($task in $tasks) {
  Add-TableRow -Lines $lines -Cells @($task.id, $task.owner, "``$($task.status)``", $task.action)
}
$lines.Add("")
$lines.Add("## Prepared Materials")
$lines.Add("")
$lines.Add("- Human Operator packet: ``$packetTemplate``")
$lines.Add("- Filling guide: ``$fillingGuide``")
$lines.Add("- Publication checklist: ``$publicationChecklist``")
$lines.Add("- Publication evidence template: ``$publicationTemplate``")
$lines.Add("")
$lines.Add("## Next Human Action")
$lines.Add("")
$lines.Add($report.prepare.next_human_action)
$lines.Add("")
$lines.Add("## Compliance Boundary")
$lines.Add("")
$lines.Add("- Detect and Prepare only.")
$lines.Add("- No content was published.")
$lines.Add("- No evidence row or gate state was changed.")
$lines.Add("- ai占卜.ai remains ``no_go`` and ``execution_go=false``.")
$lines | Set-Content -LiteralPath $markdownOutputPath -Encoding UTF8

$result = [PSCustomObject]@{
  status = $report.status
  current_phase = $report.current_phase
  markdown_output_path = $markdownOutputPath
  json_output_path = $jsonOutputPath
  missing_operator_fields = $missingOperatorFields.Count
  evidence_rows_missing = $missingEvidenceRows.Count
  intake_status = $intake.status
  secret_shape_hits = $intake.secret_shape_hits
  compliance_note = $report.compliance_note
}

if ($Json) { $result | ConvertTo-Json -Depth 8 } else { $result | Format-List }
exit 0
