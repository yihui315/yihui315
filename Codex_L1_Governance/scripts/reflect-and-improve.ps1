<#
Skill: l1-reflect-and-improve
Trigger: after weekly health, feedback, reflection, and state update complete.
Recommendation: run before a Human review session to prepare Codex improvement suggestions.

Compliance reminder:
- Report-only script.
- Does not call external AI APIs.
- Does not modify gates, evidence, revenue, provider, payment, production, or project readiness state.
- Executor may act only after Human confirmation and only when L1_State.json should_stop=false.
#>

param(
  [string]$GovernanceRoot = "",
  [string]$WeeklyHealthJsonPath = "",
  [string]$FeedbackJsonPath = "",
  [string]$ReflectionJsonPath = "",
  [string]$StatePath = "",
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
  if (-not $rootFull.EndsWith([string]$separator)) {
    $rootFull = $rootFull + $separator
  }
  return $pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-LatestFile {
  param([string]$Directory, [string]$Filter)
  if (-not (Test-Path -LiteralPath $Directory)) {
    throw "Directory not found: $Directory"
  }
  $latest = Get-ChildItem -LiteralPath $Directory -Filter $Filter -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if (-not $latest) {
    throw "No file matching $Filter found in $Directory"
  }
  return $latest.FullName
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
if ([string]::IsNullOrWhiteSpace($WeeklyHealthJsonPath)) {
  $WeeklyHealthJsonPath = Get-LatestFile -Directory (Join-Path $root "weekly_health_reports") -Filter "Weekly_Governance_Health_*.json"
}
if ([string]::IsNullOrWhiteSpace($FeedbackJsonPath)) {
  $FeedbackJsonPath = Get-LatestFile -Directory (Join-Path $root "feedback_reports") -Filter "Weekly_Governance_Feedback_*.json"
}
if ([string]::IsNullOrWhiteSpace($ReflectionJsonPath)) {
  $ReflectionJsonPath = Get-LatestFile -Directory (Join-Path $root "reflection_reports") -Filter "L1_Reflection_*.json"
}
if ([string]::IsNullOrWhiteSpace($StatePath)) {
  $StatePath = Join-Path $root "L1_State.json"
}
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $root "improvement_reports"
}

$resolvedHealthPath = (Resolve-Path -LiteralPath $WeeklyHealthJsonPath).Path
$resolvedFeedbackPath = (Resolve-Path -LiteralPath $FeedbackJsonPath).Path
$resolvedReflectionPath = (Resolve-Path -LiteralPath $ReflectionJsonPath).Path
$resolvedStatePath = (Resolve-Path -LiteralPath $StatePath).Path
foreach ($path in @($resolvedHealthPath, $resolvedFeedbackPath, $resolvedReflectionPath, $resolvedStatePath, $OutputDirectory)) {
  if (-not (Test-PathInsideRoot -Root $root -Path $path)) {
    throw "Path must stay inside GovernanceRoot. path=$path root=$root"
  }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$health = Get-Content -LiteralPath $resolvedHealthPath -Raw | ConvertFrom-Json
$feedback = Get-Content -LiteralPath $resolvedFeedbackPath -Raw | ConvertFrom-Json
$reflection = Get-Content -LiteralPath $resolvedReflectionPath -Raw | ConvertFrom-Json
$state = Get-Content -LiteralPath $resolvedStatePath -Raw | ConvertFrom-Json

$suggestions = New-Object System.Collections.Generic.List[object]

foreach ($item in @($feedback.codex_improvement_suggestions)) {
  if ($item -and -not [string]::IsNullOrWhiteSpace([string]$item.suggested_action)) {
    $suggestions.Add([PSCustomObject]@{
      source = [string]$item.source
      action = [string]$item.suggested_action
      priority = "medium"
      requires_human_confirmation = $true
      executor_allowed_now = (-not [bool]$state.should_stop)
    })
  }
}

foreach ($item in @($reflection.evolution_suggestions)) {
  if ($item -and -not [string]::IsNullOrWhiteSpace([string]$item.action)) {
    $suggestions.Add([PSCustomObject]@{
      source = "reflection:{0}" -f $reflection.failure_category
      action = [string]$item.action
      priority = [string]$item.priority
      requires_human_confirmation = $true
      executor_allowed_now = (-not [bool]$state.should_stop)
    })
  }
}

if ($reflection.recoverable -eq $true -and -not [string]::IsNullOrWhiteSpace([string]$reflection.suggested_auto_action)) {
  $suggestions.Add([PSCustomObject]@{
    source = "reflection:auto_recovery"
    action = [string]$reflection.suggested_auto_action
    priority = "medium"
    requires_human_confirmation = $false
    executor_allowed_now = ((-not [bool]$state.should_stop) -or ([string]$state.auto_recovery_status -eq "retry_allowed"))
    strategy = [string]$reflection.recommended_strategy
  })
}

if ([bool]$state.should_stop) {
  $suggestions.Add([PSCustomObject]@{
    source = "L1_State"
    action = "Pause Executor and request Human review of stop_reason before applying any improvement."
    priority = "high"
    requires_human_confirmation = $true
    executor_allowed_now = $false
  })
}

if ($suggestions.Count -eq 0) {
  $suggestions.Add([PSCustomObject]@{
    source = "system"
    action = "Continue observation and accumulate another weekly report before changing L1 rules."
    priority = "low"
    requires_human_confirmation = $true
    executor_allowed_now = (-not [bool]$state.should_stop)
  })
}
$suggestionArray = @($suggestions.ToArray())

$dateStamp = Get-Date -Format "yyyy-MM-dd"
$jsonOutputPath = Join-Path $OutputDirectory ("L1_Codex_Improvement_{0}.json" -f $dateStamp)
$markdownOutputPath = Join-Path $OutputDirectory ("L1_Codex_Improvement_{0}.md" -f $dateStamp)

$reportObject = [PSCustomObject]@{
  report_type = "l1_codex_improvement_suggestions"
  generated_at = (Get-Date).ToString("s")
  source_health_json = $resolvedHealthPath
  source_feedback_json = $resolvedFeedbackPath
  source_reflection_json = $resolvedReflectionPath
  source_state_json = $resolvedStatePath
  health_status = $health.status
  health_score = $health.score
  should_stop = [bool]$state.should_stop
  stop_reason = [string]$state.stop_reason
  failure_category = [string]$reflection.failure_category
  recoverable = if ($reflection.recoverable -ne $null) { [bool]$reflection.recoverable } else { $false }
  suggested_auto_action = if ($reflection.suggested_auto_action -ne $null) { [string]$reflection.suggested_auto_action } else { "" }
  recommended_strategy = if ($reflection.recommended_strategy -ne $null) { [string]$reflection.recommended_strategy } else { "" }
  auto_retry_count = if ($state.auto_retry_count -ne $null) { [int]$state.auto_retry_count } else { 0 }
  max_auto_retries = if ($state.max_auto_retries -ne $null) { [int]$state.max_auto_retries } else { 2 }
  auto_recovery_status = if ($state.auto_recovery_status -ne $null) { [string]$state.auto_recovery_status } else { "" }
  suggestions = @($suggestionArray)
  executor_boundary = "Executor may act only after Human confirmation and only when L1_State.json should_stop=false."
  compliance_note = "Report-only. No gate, evidence, revenue, provider, payment, production, or readiness state changed."
}

$reportObject | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonOutputPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# L1 Codex Improvement Suggestions $dateStamp")
$lines.Add("")
$lines.Add("## Summary")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Field", "Value")
Add-TableRow -Lines $lines -Cells @("---", "---")
Add-TableRow -Lines $lines -Cells @("health_status", (Format-InlineCode $health.status))
Add-TableRow -Lines $lines -Cells @("health_score", (Format-InlineCode $health.score))
Add-TableRow -Lines $lines -Cells @("should_stop", (Format-InlineCode $state.should_stop))
Add-TableRow -Lines $lines -Cells @("stop_reason", (Format-InlineCode $state.stop_reason))
Add-TableRow -Lines $lines -Cells @("failure_category", (Format-InlineCode $reflection.failure_category))
Add-TableRow -Lines $lines -Cells @("recoverable", (Format-InlineCode $reportObject.recoverable))
Add-TableRow -Lines $lines -Cells @("recommended_strategy", (Format-InlineCode $reportObject.recommended_strategy))
Add-TableRow -Lines $lines -Cells @("auto_retry_count", (Format-InlineCode $reportObject.auto_retry_count))
Add-TableRow -Lines $lines -Cells @("max_auto_retries", (Format-InlineCode $reportObject.max_auto_retries))
Add-TableRow -Lines $lines -Cells @("auto_recovery_status", (Format-InlineCode $reportObject.auto_recovery_status))
$lines.Add("")
$lines.Add("## Suggestions")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Priority", "Source", "Action", "Executor allowed now")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---")
foreach ($suggestion in $suggestionArray) {
  Add-TableRow -Lines $lines -Cells @($suggestion.priority, $suggestion.source, $suggestion.action, [string]$suggestion.executor_allowed_now)
}
$lines.Add("")
$lines.Add("## Human Review Gate")
$lines.Add("")
$lines.Add("- Suggestions are not approvals.")
$lines.Add("- Executor must verify `L1_State.json.should_stop=false` before acting.")
$lines.Add("- Human confirmation is required before changing rules, scripts, records, automations, or project files.")
$lines.Add("- Project gates and evidence remain unchanged by this report.")

$lines | Set-Content -LiteralPath $markdownOutputPath -Encoding UTF8

$result = [ordered]@{
  status = "generated"
  generated_at = (Get-Date).ToString("s")
  markdown_output_path = $markdownOutputPath
  json_output_path = $jsonOutputPath
  suggestion_count = $suggestionArray.Count
  should_stop = [bool]$state.should_stop
  compliance_note = "Advisory improvement report only. No gate state changed."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
} else {
  $result | Format-List
}

exit 0
