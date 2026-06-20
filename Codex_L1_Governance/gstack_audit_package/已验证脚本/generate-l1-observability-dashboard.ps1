<#
Skill: l1-observability-dashboard
Trigger: after weekly health or before gstack audit review.
Recommendation: run to create a single read-only dashboard of L1 health, stop state, evidence intake, and pilot status.

Compliance reminder:
- Read-only report generator.
- Does not change gate status, evidence status, project readiness, or revenue readiness.
#>

param(
  [string]$GovernanceRoot = "",
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

function Get-LatestFileOrNull {
  param([string]$Directory, [string]$Filter)
  if (-not (Test-Path -LiteralPath $Directory)) { return $null }
  $latest = Get-ChildItem -LiteralPath $Directory -Filter $Filter -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if ($latest) { return $latest.FullName }
  return $null
}

function Read-JsonOrNull {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) { return $null }
  try {
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
  } catch {
    return $null
  }
}

function Add-TableRow {
  param([System.Collections.Generic.List[string]]$Lines, [string[]]$Cells)
  $Lines.Add("| " + ($Cells -join " | ") + " |")
}

function Format-InlineCode {
  param([object]$Value)
  return "``{0}``" -f $Value
}

$root = Resolve-GovernanceRoot -InputRoot $GovernanceRoot
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $root "observability_reports"
}
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$dateStamp = Get-Date -Format "yyyy-MM-dd"
$healthPath = Get-LatestFileOrNull -Directory (Join-Path $root "weekly_health_reports") -Filter "Weekly_Governance_Health_*.json"
$feedbackPath = Get-LatestFileOrNull -Directory (Join-Path $root "feedback_reports") -Filter "Weekly_Governance_Feedback_*.json"
$reflectionPath = Get-LatestFileOrNull -Directory (Join-Path $root "reflection_reports") -Filter "L1_Reflection_*.json"
$improvementPath = Get-LatestFileOrNull -Directory (Join-Path $root "improvement_reports") -Filter "L1_Codex_Improvement_*.json"
$evidencePath = Get-LatestFileOrNull -Directory (Join-Path $root "evidence_intake_reports") -Filter "Evidence_Intake_Report_*.json"
$statePath = Join-Path $root "L1_State.json"
$projectDecisionPath = Join-Path $root "Projects/ai占卜.ai/当前状态/当前_Gate_Decision_摘要.md"

$health = Read-JsonOrNull -Path $healthPath
$feedback = Read-JsonOrNull -Path $feedbackPath
$reflection = Read-JsonOrNull -Path $reflectionPath
$improvement = Read-JsonOrNull -Path $improvementPath
$evidence = Read-JsonOrNull -Path $evidencePath
$state = Read-JsonOrNull -Path $statePath

$projectDecisionText = if (Test-Path -LiteralPath $projectDecisionPath) {
  Get-Content -LiteralPath $projectDecisionPath -Raw
} else {
  ""
}
$projectNoGo = $projectDecisionText -match "overall_decision \| ``no_go``"
$projectExecutionFalse = $projectDecisionText -match "execution_go \| ``false``"

$dashboard = [PSCustomObject]@{
  report_type = "l1_observability_dashboard"
  generated_at = (Get-Date).ToString("s")
  health = [PSCustomObject]@{
    source = $healthPath
    status = if ($health) { $health.status } else { "missing" }
    score = if ($health) { $health.score } else { $null }
    secret_shape_hits = if ($health) { $health.secret_scan.secret_shape_hits } else { $null }
    env_like_files = if ($health) { $health.secret_scan.env_like_files } else { $null }
  }
  loop_state = [PSCustomObject]@{
    source = $statePath
    iteration_count = if ($state) { $state.iteration_count } else { $null }
    should_stop = if ($state) { [bool]$state.should_stop } else { $null }
    stop_reason = if ($state) { $state.stop_reason } else { "" }
    current_failure_category = if ($state) { $state.current_failure_category } else { "" }
    current_execution_go = if ($state) { [bool]$state.current_execution_go } else { $false }
  }
  feedback = [PSCustomObject]@{
    source = $feedbackPath
    recommendation_count = if ($feedback) { @($feedback.improvement_recommendations).Count } else { 0 }
    codex_suggestion_count = if ($feedback -and $feedback.codex_improvement_suggestions) { @($feedback.codex_improvement_suggestions).Count } else { 0 }
  }
  reflection = [PSCustomObject]@{
    source = $reflectionPath
    failure_category = if ($reflection) { $reflection.failure_category } else { "" }
    should_continue = if ($reflection) { [bool]$reflection.should_continue } else { $false }
  }
  improvement = [PSCustomObject]@{
    source = $improvementPath
    suggestion_count = if ($improvement) { @($improvement.suggestions).Count } else { 0 }
    executor_allowed_now = if ($state) { -not [bool]$state.should_stop } else { $false }
  }
  evidence_intake = [PSCustomObject]@{
    source = $evidencePath
    status = if ($evidence) { $evidence.status } else { "missing" }
    present_yes = if ($evidence -and $evidence.row_summary) { $evidence.row_summary.present_yes } else { $null }
    present_no = if ($evidence -and $evidence.row_summary) { $evidence.row_summary.present_no } else { $null }
  }
  pilot = [PSCustomObject]@{
    project = "ai占卜.ai"
    no_go = $projectNoGo
    execution_go_false = $projectExecutionFalse
    compliance_note = "Pilot remains fail-closed unless real Human Operator evidence is submitted and reviewed."
  }
}

$jsonOutputPath = Join-Path $OutputDirectory ("L1_Observability_Dashboard_{0}.json" -f $dateStamp)
$markdownOutputPath = Join-Path $OutputDirectory ("L1_Observability_Dashboard_{0}.md" -f $dateStamp)
$dashboard | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonOutputPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# L1 Observability Dashboard $dateStamp")
$lines.Add("")
$lines.Add("## Summary")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Metric", "Value")
Add-TableRow -Lines $lines -Cells @("---", "---")
Add-TableRow -Lines $lines -Cells @("weekly_health_status", (Format-InlineCode $dashboard.health.status))
Add-TableRow -Lines $lines -Cells @("weekly_health_score", (Format-InlineCode $dashboard.health.score))
Add-TableRow -Lines $lines -Cells @("secret_shape_hits", (Format-InlineCode $dashboard.health.secret_shape_hits))
Add-TableRow -Lines $lines -Cells @("l1_should_stop", (Format-InlineCode $dashboard.loop_state.should_stop))
Add-TableRow -Lines $lines -Cells @("l1_stop_reason", (Format-InlineCode $dashboard.loop_state.stop_reason))
Add-TableRow -Lines $lines -Cells @("reflection_failure_category", (Format-InlineCode $dashboard.reflection.failure_category))
Add-TableRow -Lines $lines -Cells @("codex_suggestion_count", (Format-InlineCode $dashboard.feedback.codex_suggestion_count))
Add-TableRow -Lines $lines -Cells @("improvement_suggestion_count", (Format-InlineCode $dashboard.improvement.suggestion_count))
Add-TableRow -Lines $lines -Cells @("evidence_intake_status", (Format-InlineCode $dashboard.evidence_intake.status))
Add-TableRow -Lines $lines -Cells @("evidence_present_yes", (Format-InlineCode $dashboard.evidence_intake.present_yes))
Add-TableRow -Lines $lines -Cells @("evidence_present_no", (Format-InlineCode $dashboard.evidence_intake.present_no))
Add-TableRow -Lines $lines -Cells @("pilot_no_go", (Format-InlineCode $dashboard.pilot.no_go))
Add-TableRow -Lines $lines -Cells @("pilot_execution_go_false", (Format-InlineCode $dashboard.pilot.execution_go_false))
$lines.Add("")
$lines.Add("## Source Files")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Area", "Source")
Add-TableRow -Lines $lines -Cells @("---", "---")
Add-TableRow -Lines $lines -Cells @("health", (Format-InlineCode $healthPath))
Add-TableRow -Lines $lines -Cells @("feedback", (Format-InlineCode $feedbackPath))
Add-TableRow -Lines $lines -Cells @("reflection", (Format-InlineCode $reflectionPath))
Add-TableRow -Lines $lines -Cells @("improvement", (Format-InlineCode $improvementPath))
Add-TableRow -Lines $lines -Cells @("evidence_intake", (Format-InlineCode $evidencePath))
Add-TableRow -Lines $lines -Cells @("state", (Format-InlineCode $statePath))
$lines.Add("")
$lines.Add("## Compliance Boundary")
$lines.Add("")
$lines.Add("- Dashboard is read-only.")
$lines.Add("- Dashboard does not change Evidence, Revenue, Approval, Execution, payment, provider, or production readiness.")
$lines.Add("- ai占卜.ai remains fail-closed while Human Operator evidence is missing.")

$lines | Set-Content -LiteralPath $markdownOutputPath -Encoding UTF8
Copy-Item -LiteralPath $markdownOutputPath -Destination (Join-Path $root "L1_Observability_Dashboard.md") -Force

$result = [ordered]@{
  status = "generated"
  generated_at = (Get-Date).ToString("s")
  markdown_output_path = $markdownOutputPath
  json_output_path = $jsonOutputPath
  root_dashboard_path = (Join-Path $root "L1_Observability_Dashboard.md")
  health_status = $dashboard.health.status
  should_stop = $dashboard.loop_state.should_stop
  pilot_no_go = $dashboard.pilot.no_go
  compliance_note = "Read-only dashboard only. No gate state changed."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
} else {
  $result | Format-List
}

exit 0
