<#
Skill: l1-observability-dashboard
Trigger: after weekly health or before gstack audit review.
Recommendation: run to create a single read-only dashboard of L1 health, stop state, evidence intake, pilot status, and trends.

Compliance reminder:
- Read-only report generator.
- Does not change gate status, evidence status, project readiness, or revenue readiness.
#>

param(
  [string]$GovernanceRoot = "",
  [string]$OutputDirectory = "",
  [int]$TrendLimit = 8,
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

function Get-DateLabel {
  param([System.IO.FileInfo]$File)
  if ($File.Name -match "(\d{4}-\d{2}-\d{2})") { return $Matches[1] }
  return $File.LastWriteTime.ToString("yyyy-MM-dd")
}

function Get-JsonHistory {
  param([string]$Directory, [string]$Filter, [int]$Limit)
  if (-not (Test-Path -LiteralPath $Directory)) { return @() }
  $files = @(Get-ChildItem -LiteralPath $Directory -Filter $Filter -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First $Limit |
    Sort-Object LastWriteTime)
  $items = New-Object System.Collections.Generic.List[object]
  foreach ($file in $files) {
    $data = Read-JsonOrNull -Path $file.FullName
    if ($null -ne $data) {
      $items.Add([PSCustomObject]@{
        date = Get-DateLabel -File $file
        path = $file.FullName
        data = $data
      })
    }
  }
  return @($items.ToArray())
}

function Add-TableRow {
  param([System.Collections.Generic.List[string]]$Lines, [string[]]$Cells)
  $Lines.Add("| " + ($Cells -join " | ") + " |")
}

function Format-InlineCode {
  param([object]$Value)
  if ($null -eq $Value) { return "````" }
  if ($Value -is [string] -and [string]::IsNullOrWhiteSpace($Value)) { return "````" }
  return "``{0}``" -f $Value
}

function Get-ObjectCount {
  param([object]$Value)
  if ($null -eq $Value) { return 0 }
  return @($Value).Count
}

function Get-ProjectFileOrNull {
  param([string]$Root, [string]$NamePattern)
  $projectsDir = Join-Path $Root "Projects"
  if (-not (Test-Path -LiteralPath $projectsDir)) { return $null }
  $file = Get-ChildItem -LiteralPath $projectsDir -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like $NamePattern } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if ($file) { return $file.FullName }
  return $null
}

function Get-EvidenceSnapshot {
  param([string]$Root, [string]$LatestEvidenceJsonPath)

  $jsonEvidence = Read-JsonOrNull -Path $LatestEvidenceJsonPath
  if ($jsonEvidence) {
    return [PSCustomObject]@{
      source = $LatestEvidenceJsonPath
      status = $jsonEvidence.status
      present_yes = if ($jsonEvidence.row_summary) { $jsonEvidence.row_summary.present_yes } else { $null }
      present_no = if ($jsonEvidence.row_summary) { $jsonEvidence.row_summary.present_no } else { $null }
      total_rows = if ($jsonEvidence.row_summary) { $jsonEvidence.row_summary.total_rows } else { $null }
    }
  }

  $latestEvidenceMd = Get-LatestFileOrNull -Directory (Join-Path $Root "evidence_intake_reports") -Filter "Evidence_Intake_Report_*.md"
  if ($latestEvidenceMd) {
    $content = Get-Content -LiteralPath $latestEvidenceMd -Raw
    $status = if ($content -match 'status \| `([^`]+)`') { $Matches[1] } else { "unknown" }
    $presentYes = if ($content -match 'present_yes \| `(\d+)`') { [int]$Matches[1] } else { $null }
    $presentNo = if ($content -match 'present_no \| `(\d+)`') { [int]$Matches[1] } else { $null }
    $totalRows = if ($content -match 'total_rows \| `(\d+)`') { [int]$Matches[1] } else { $null }
    return [PSCustomObject]@{
      source = $latestEvidenceMd
      status = $status
      present_yes = $presentYes
      present_no = $presentNo
      total_rows = $totalRows
    }
  }

  $projectEvidenceFile = Get-ProjectFileOrNull -Root $Root -NamePattern "*Evidence_Gate*.md"
  if ($projectEvidenceFile) {
    $content = Get-Content -LiteralPath $projectEvidenceFile -Raw
    $presentYes = ([regex]::Matches($content, "\| EV-\d{3} \|[^\r\n]+\| yes \|")).Count
    $presentNo = ([regex]::Matches($content, "\| EV-\d{3} \|[^\r\n]+\| no \|")).Count
    return [PSCustomObject]@{
      source = $projectEvidenceFile
      status = if ($presentYes -eq 0) { "blocked" } else { "needs_validator_review" }
      present_yes = $presentYes
      present_no = $presentNo
      total_rows = $presentYes + $presentNo
    }
  }

  return [PSCustomObject]@{
    source = ""
    status = "missing"
    present_yes = $null
    present_no = $null
    total_rows = $null
  }
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
$projectDecisionPath = Get-ProjectFileOrNull -Root $root -NamePattern "*Gate_Decision*.md"

$health = Read-JsonOrNull -Path $healthPath
$feedback = Read-JsonOrNull -Path $feedbackPath
$reflection = Read-JsonOrNull -Path $reflectionPath
$improvement = Read-JsonOrNull -Path $improvementPath
$state = Read-JsonOrNull -Path $statePath
$evidenceSnapshot = Get-EvidenceSnapshot -Root $root -LatestEvidenceJsonPath $evidencePath

$projectDecisionText = if ($projectDecisionPath -and (Test-Path -LiteralPath $projectDecisionPath)) {
  Get-Content -LiteralPath $projectDecisionPath -Raw
} else {
  ""
}
$projectNoGo = $projectDecisionText -match "overall_decision \| ``no_go``"
$projectExecutionFalse = $projectDecisionText -match "execution_go \| ``false``"

$healthHistory = @(Get-JsonHistory -Directory (Join-Path $root "weekly_health_reports") -Filter "Weekly_Governance_Health_*.json" -Limit $TrendLimit)
$feedbackHistory = @(Get-JsonHistory -Directory (Join-Path $root "feedback_reports") -Filter "Weekly_Governance_Feedback_*.json" -Limit $TrendLimit)
$reflectionHistory = @(Get-JsonHistory -Directory (Join-Path $root "reflection_reports") -Filter "L1_Reflection_*.json" -Limit $TrendLimit)
$improvementHistory = @(Get-JsonHistory -Directory (Join-Path $root "improvement_reports") -Filter "L1_Codex_Improvement_*.json" -Limit $TrendLimit)
$observabilityHistory = @(Get-JsonHistory -Directory (Join-Path $root "observability_reports") -Filter "L1_Observability_Dashboard_*.json" -Limit $TrendLimit)

$healthScoreTrend = New-Object System.Collections.Generic.List[object]
$previousScore = $null
foreach ($entry in $healthHistory) {
  $score = if ($entry.data.score -ne $null) { [int]$entry.data.score } elseif ($entry.data.health -and $entry.data.health.score -ne $null) { [int]$entry.data.health.score } else { $null }
  $delta = if ($null -ne $previousScore -and $null -ne $score) { $score - $previousScore } else { $null }
  $healthScoreTrend.Add([PSCustomObject]@{
    date = $entry.date
    status = if ($entry.data.status) { $entry.data.status } elseif ($entry.data.health) { $entry.data.health.status } else { "unknown" }
    score = $score
    delta = $delta
  })
  if ($null -ne $score) { $previousScore = $score }
}

$improvementSuggestionTrend = New-Object System.Collections.Generic.List[object]
foreach ($entry in $improvementHistory) {
  $improvementSuggestionTrend.Add([PSCustomObject]@{
    date = $entry.date
    suggestion_count = Get-ObjectCount $entry.data.suggestions
    failure_category = if ($entry.data.failure_category) { $entry.data.failure_category } else { "" }
  })
}

$stopReasons = @()
foreach ($entry in $observabilityHistory) {
  if ($entry.data.loop_state) {
    $reason = [string]$entry.data.loop_state.stop_reason
    if ([string]::IsNullOrWhiteSpace($reason)) { $reason = "none" }
    $stopReasons += $reason
  }
}
if ($state) {
  $currentReason = [string]$state.stop_reason
  if ([string]::IsNullOrWhiteSpace($currentReason)) { $currentReason = "none" }
  $stopReasons += $currentReason
}
$stopReasonDistribution = @($stopReasons | Group-Object | ForEach-Object {
  [PSCustomObject]@{ stop_reason = $_.Name; count = $_.Count }
})

$feedbackSuggestionTrend = New-Object System.Collections.Generic.List[object]
foreach ($entry in $feedbackHistory) {
  $feedbackSuggestionTrend.Add([PSCustomObject]@{
    date = $entry.date
    recommendation_count = Get-ObjectCount $entry.data.improvement_recommendations
    codex_suggestion_count = Get-ObjectCount $entry.data.codex_improvement_suggestions
  })
}

$allImprovementSuggestions = @()
foreach ($entry in $improvementHistory) {
  $allImprovementSuggestions += @($entry.data.suggestions)
}
$acceptedSuggestions = @($allImprovementSuggestions | Where-Object {
  $_.status -in @("accepted", "applied", "completed", "adopted") -or
  $_.adoption_status -in @("accepted", "applied", "completed", "adopted")
})
$adoptionRate = if ($allImprovementSuggestions.Count -gt 0 -and $acceptedSuggestions.Count -gt 0) {
  [Math]::Round(($acceptedSuggestions.Count / $allImprovementSuggestions.Count) * 100, 2)
} elseif ($allImprovementSuggestions.Count -gt 0) {
  $null
} else {
  $null
}

$loopHistory = if ($state -and $state.loop_history) { @($state.loop_history) } else { @() }
$loopIterationTrend = New-Object System.Collections.Generic.List[object]
foreach ($entry in @($loopHistory | Select-Object -Last $TrendLimit)) {
  $reason = [string]$entry.stop_reason
  if ([string]::IsNullOrWhiteSpace($reason)) { $reason = [string]$entry.soft_stop_reason }
  if ([string]::IsNullOrWhiteSpace($reason)) { $reason = "none" }
  $loopIterationTrend.Add([PSCustomObject]@{
    recorded_at = $entry.recorded_at
    iteration_count = $entry.iteration_count
    health_score = $entry.health_score
    execution_go = $entry.execution_go
    failure_category = $entry.failure_category
    recoverable = if ($entry.recoverable -ne $null) { [bool]$entry.recoverable } else { $false }
    auto_retry_count = if ($entry.auto_retry_count -ne $null) { [int]$entry.auto_retry_count } else { 0 }
    auto_recovery_status = if ($entry.auto_recovery_status -ne $null) { $entry.auto_recovery_status } else { "" }
    stop_or_soft_reason = $reason
    should_stop = $entry.should_stop
  })
}
$averageIterationCount = if ($loopHistory.Count -gt 0) {
  [Math]::Round((($loopHistory | Measure-Object -Property iteration_count -Average).Average), 2)
} elseif ($state -and $state.iteration_count -ne $null) {
  [double]$state.iteration_count
} else {
  $null
}
$repeatedFailureFrequency = if ($loopHistory.Count -gt 0) {
  $repeatEvents = @($loopHistory | Where-Object { $_.stop_reason -eq "repeated_failure_category" -or $_.repeated_failure_count -ge $_.repeated_failure_threshold })
  [Math]::Round(($repeatEvents.Count / $loopHistory.Count) * 100, 2)
} elseif ($state -and $state.repeated_failure_count -ne $null -and $state.repeated_failure_threshold -ne $null) {
  if ([int]$state.repeated_failure_count -ge [int]$state.repeated_failure_threshold) { 100.0 } else { 0.0 }
} else {
  $null
}

$dashboard = [PSCustomObject]@{
  report_type = "l1_observability_dashboard"
  generated_at = (Get-Date).ToString("s")
  trend_limit = $TrendLimit
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
    auto_retry_count = if ($state -and $state.auto_retry_count -ne $null) { [int]$state.auto_retry_count } else { 0 }
    max_auto_retries = if ($state -and $state.max_auto_retries -ne $null) { [int]$state.max_auto_retries } else { 2 }
    auto_recovery_status = if ($state -and $state.auto_recovery_status -ne $null) { $state.auto_recovery_status } else { "" }
    last_soft_stop_reason = if ($state -and $state.last_soft_stop_reason -ne $null) { $state.last_soft_stop_reason } else { "" }
  }
  feedback = [PSCustomObject]@{
    source = $feedbackPath
    recommendation_count = if ($feedback) { Get-ObjectCount $feedback.improvement_recommendations } else { 0 }
    codex_suggestion_count = if ($feedback) { Get-ObjectCount $feedback.codex_improvement_suggestions } else { 0 }
  }
  reflection = [PSCustomObject]@{
    source = $reflectionPath
    failure_category = if ($reflection) { $reflection.failure_category } else { "" }
    recoverable = if ($reflection -and $reflection.recoverable -ne $null) { [bool]$reflection.recoverable } else { $false }
    recommended_strategy = if ($reflection -and $reflection.recommended_strategy -ne $null) { $reflection.recommended_strategy } else { "" }
    should_continue = if ($reflection) { [bool]$reflection.should_continue } else { $false }
  }
  improvement = [PSCustomObject]@{
    source = $improvementPath
    suggestion_count = if ($improvement) { Get-ObjectCount $improvement.suggestions } else { 0 }
    executor_allowed_now = if ($state) { -not [bool]$state.should_stop } else { $false }
  }
  evidence_intake = $evidenceSnapshot
  pilot = [PSCustomObject]@{
    project = "ai占卜.ai"
    source = $projectDecisionPath
    no_go = $projectNoGo
    execution_go_false = $projectExecutionFalse
    compliance_note = "Pilot remains fail-closed unless real Human Operator evidence is submitted and reviewed."
  }
  trends = [PSCustomObject]@{
    health_score_trend = @($healthScoreTrend.ToArray())
    loop_iteration_trend = @($loopIterationTrend.ToArray())
    feedback_suggestion_trend = @($feedbackSuggestionTrend.ToArray())
    improvement_suggestion_trend = @($improvementSuggestionTrend.ToArray())
    stop_reason_distribution = @($stopReasonDistribution)
  }
  key_metrics = [PSCustomObject]@{
    improvement_suggestion_total = $allImprovementSuggestions.Count
    improvement_suggestion_adopted = $acceptedSuggestions.Count
    improvement_adoption_rate_percent = $adoptionRate
    improvement_adoption_note = if ($null -eq $adoptionRate) { "not_tracked_until_suggestions_gain_status_fields" } else { "tracked_from_status_fields" }
    average_iteration_count = $averageIterationCount
    repeated_failure_frequency_percent = $repeatedFailureFrequency
  }
  ai_divination_monitoring = [PSCustomObject]@{
    execution_go_current = if ($state) { [bool]$state.current_execution_go } else { $false }
    execution_go_trend = if ($projectExecutionFalse) { "stable_false" } else { "unknown" }
    evidence_present_yes_current = $evidenceSnapshot.present_yes
    evidence_present_no_current = $evidenceSnapshot.present_no
    evidence_status_current = $evidenceSnapshot.status
    status_note = "No project gate upgrade is implied by dashboard generation."
  }
}

$jsonOutputPath = Join-Path $OutputDirectory ("L1_Observability_Dashboard_{0}.json" -f $dateStamp)
$markdownOutputPath = Join-Path $OutputDirectory ("L1_Observability_Dashboard_{0}.md" -f $dateStamp)
$dashboard | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $jsonOutputPath -Encoding UTF8

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
Add-TableRow -Lines $lines -Cells @("reflection_recoverable", (Format-InlineCode $dashboard.reflection.recoverable))
Add-TableRow -Lines $lines -Cells @("recommended_strategy", (Format-InlineCode $dashboard.reflection.recommended_strategy))
Add-TableRow -Lines $lines -Cells @("auto_retry_count", (Format-InlineCode $dashboard.loop_state.auto_retry_count))
Add-TableRow -Lines $lines -Cells @("max_auto_retries", (Format-InlineCode $dashboard.loop_state.max_auto_retries))
Add-TableRow -Lines $lines -Cells @("auto_recovery_status", (Format-InlineCode $dashboard.loop_state.auto_recovery_status))
Add-TableRow -Lines $lines -Cells @("codex_suggestion_count", (Format-InlineCode $dashboard.feedback.codex_suggestion_count))
Add-TableRow -Lines $lines -Cells @("improvement_suggestion_count", (Format-InlineCode $dashboard.improvement.suggestion_count))
Add-TableRow -Lines $lines -Cells @("evidence_intake_status", (Format-InlineCode $dashboard.evidence_intake.status))
Add-TableRow -Lines $lines -Cells @("evidence_present_yes", (Format-InlineCode $dashboard.evidence_intake.present_yes))
Add-TableRow -Lines $lines -Cells @("evidence_present_no", (Format-InlineCode $dashboard.evidence_intake.present_no))
Add-TableRow -Lines $lines -Cells @("pilot_no_go", (Format-InlineCode $dashboard.pilot.no_go))
Add-TableRow -Lines $lines -Cells @("pilot_execution_go_false", (Format-InlineCode $dashboard.pilot.execution_go_false))
Add-TableRow -Lines $lines -Cells @("loop_trend_points", (Format-InlineCode $dashboard.trends.loop_iteration_trend.Count))

$lines.Add("")
$lines.Add("## Trend Analysis")
$lines.Add("")
$lines.Add("### Loop Iteration Trend")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Recorded at", "Iteration", "Score", "Failure", "Recoverable", "Auto retry", "Recovery status", "Stop/soft reason", "Hard stop")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---", "---", "---", "---", "---", "---")
foreach ($item in $dashboard.trends.loop_iteration_trend) {
  Add-TableRow -Lines $lines -Cells @($item.recorded_at, (Format-InlineCode $item.iteration_count), (Format-InlineCode $item.health_score), (Format-InlineCode $item.failure_category), (Format-InlineCode $item.recoverable), (Format-InlineCode $item.auto_retry_count), (Format-InlineCode $item.auto_recovery_status), (Format-InlineCode $item.stop_or_soft_reason), (Format-InlineCode $item.should_stop))
}
if ($dashboard.trends.loop_iteration_trend.Count -eq 0) {
  Add-TableRow -Lines $lines -Cells @("none", (Format-InlineCode ""), (Format-InlineCode ""), (Format-InlineCode ""), (Format-InlineCode ""), (Format-InlineCode ""), (Format-InlineCode ""), (Format-InlineCode ""), (Format-InlineCode ""))
}
$lines.Add("")
$lines.Add("### Health Score Trend")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Date", "Status", "Score", "Delta")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---")
foreach ($item in $dashboard.trends.health_score_trend) {
  Add-TableRow -Lines $lines -Cells @($item.date, (Format-InlineCode $item.status), (Format-InlineCode $item.score), (Format-InlineCode $item.delta))
}
if ($dashboard.trends.health_score_trend.Count -eq 0) {
  Add-TableRow -Lines $lines -Cells @("none", (Format-InlineCode "missing"), (Format-InlineCode ""), (Format-InlineCode ""))
}

$lines.Add("")
$lines.Add("### Stop Reason Distribution")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Stop reason", "Count")
Add-TableRow -Lines $lines -Cells @("---", "---")
foreach ($item in $dashboard.trends.stop_reason_distribution) {
  Add-TableRow -Lines $lines -Cells @((Format-InlineCode $item.stop_reason), (Format-InlineCode $item.count))
}

$lines.Add("")
$lines.Add("### Improvement Suggestion Trend")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Date", "Suggestion count", "Failure category")
Add-TableRow -Lines $lines -Cells @("---", "---", "---")
foreach ($item in $dashboard.trends.improvement_suggestion_trend) {
  Add-TableRow -Lines $lines -Cells @($item.date, (Format-InlineCode $item.suggestion_count), (Format-InlineCode $item.failure_category))
}
if ($dashboard.trends.improvement_suggestion_trend.Count -eq 0) {
  Add-TableRow -Lines $lines -Cells @("none", (Format-InlineCode 0), (Format-InlineCode "missing"))
}

$lines.Add("")
$lines.Add("## Key Metrics")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Metric", "Value", "Note")
Add-TableRow -Lines $lines -Cells @("---", "---", "---")
Add-TableRow -Lines $lines -Cells @("improvement_suggestion_total", (Format-InlineCode $dashboard.key_metrics.improvement_suggestion_total), "Counted from improvement report history")
Add-TableRow -Lines $lines -Cells @("improvement_adoption_rate_percent", (Format-InlineCode $dashboard.key_metrics.improvement_adoption_rate_percent), $dashboard.key_metrics.improvement_adoption_note)
Add-TableRow -Lines $lines -Cells @("average_iteration_count", (Format-InlineCode $dashboard.key_metrics.average_iteration_count), "Uses loop_history when present, otherwise current state")
Add-TableRow -Lines $lines -Cells @("repeated_failure_frequency_percent", (Format-InlineCode $dashboard.key_metrics.repeated_failure_frequency_percent), "Uses loop_history when present, otherwise current repeated-failure state")

$lines.Add("")
$lines.Add("## ai-divination Pilot Monitoring")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Metric", "Value")
Add-TableRow -Lines $lines -Cells @("---", "---")
Add-TableRow -Lines $lines -Cells @("execution_go_current", (Format-InlineCode $dashboard.ai_divination_monitoring.execution_go_current))
Add-TableRow -Lines $lines -Cells @("execution_go_trend", (Format-InlineCode $dashboard.ai_divination_monitoring.execution_go_trend))
Add-TableRow -Lines $lines -Cells @("evidence_status_current", (Format-InlineCode $dashboard.ai_divination_monitoring.evidence_status_current))
Add-TableRow -Lines $lines -Cells @("evidence_present_yes_current", (Format-InlineCode $dashboard.ai_divination_monitoring.evidence_present_yes_current))
Add-TableRow -Lines $lines -Cells @("evidence_present_no_current", (Format-InlineCode $dashboard.ai_divination_monitoring.evidence_present_no_current))

$lines.Add("")
$lines.Add("## Source Files")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Area", "Source")
Add-TableRow -Lines $lines -Cells @("---", "---")
Add-TableRow -Lines $lines -Cells @("health", (Format-InlineCode $healthPath))
Add-TableRow -Lines $lines -Cells @("feedback", (Format-InlineCode $feedbackPath))
Add-TableRow -Lines $lines -Cells @("reflection", (Format-InlineCode $reflectionPath))
Add-TableRow -Lines $lines -Cells @("improvement", (Format-InlineCode $improvementPath))
Add-TableRow -Lines $lines -Cells @("evidence_intake", (Format-InlineCode $dashboard.evidence_intake.source))
Add-TableRow -Lines $lines -Cells @("state", (Format-InlineCode $statePath))
Add-TableRow -Lines $lines -Cells @("pilot_decision", (Format-InlineCode $projectDecisionPath))

$lines.Add("")
$lines.Add("## Compliance Boundary")
$lines.Add("")
$lines.Add("- Dashboard is read-only.")
$lines.Add("- Dashboard does not change Evidence, Revenue, Approval, Execution, payment, provider, or production readiness.")
$lines.Add("- ai-divination pilot remains fail-closed while Human Operator evidence is missing.")

$lines | Set-Content -LiteralPath $markdownOutputPath -Encoding UTF8
Copy-Item -LiteralPath $markdownOutputPath -Destination (Join-Path $root "L1_Observability_Dashboard.md") -Force

$result = [ordered]@{
  status = "generated"
  generated_at = (Get-Date).ToString("s")
  markdown_output_path = $markdownOutputPath
  json_output_path = $jsonOutputPath
  root_dashboard_path = (Join-Path $root "L1_Observability_Dashboard.md")
  health_status = $dashboard.health.status
  health_score = $dashboard.health.score
  should_stop = $dashboard.loop_state.should_stop
  pilot_no_go = $dashboard.pilot.no_go
  trend_points = $dashboard.trends.loop_iteration_trend.Count
  health_file_trend_points = $dashboard.trends.health_score_trend.Count
  compliance_note = "Read-only dashboard only. No gate state changed."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
} else {
  $result | Format-List
}

exit 0
