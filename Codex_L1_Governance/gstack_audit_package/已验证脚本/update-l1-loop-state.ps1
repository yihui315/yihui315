<#
Skill: l1-loop-state-updater
Trigger: after reflection is generated.
Recommendation: run at the end of each L1 loop to apply stopping conditions.

Compliance reminder:
- Updates L1_State.json only.
- Does not change gate status, evidence status, project readiness, or revenue readiness.
- Cost values are caller-provided estimates only.
#>

param(
  [string]$GovernanceRoot = "",
  [string]$StatePath = "",
  [string]$WeeklyHealthJsonPath = "",
  [string]$FeedbackJsonPath = "",
  [string]$ReflectionJsonPath = "",
  [double]$LoopCostUsd = 0.0,
  [int]$MaxIterations = -1,
  [double]$MaxCostUsd = -1.0,
  [int]$NoProgressThreshold = -1,
  [int]$RepeatedFailureThreshold = -1,
  [switch]$ResetStop,
  [string]$ResetReason = "",
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

function Get-LatestFile {
  param(
    [string]$Directory,
    [string]$Filter
  )

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

function Convert-ToBool {
  param([object]$Value)
  if ($null -eq $Value) { return $false }
  if ($Value -is [bool]) { return $Value }
  return ([string]$Value).ToLowerInvariant() -eq "true"
}

function Get-ExecutionGo {
  param([object]$Health)

  if ($Health.execution_go -ne $null) { return Convert-ToBool $Health.execution_go }
  if ($Health.decision_summary -and $Health.decision_summary.execution_go -ne $null) { return Convert-ToBool $Health.decision_summary.execution_go }
  if ($Health.round_closeout -and $Health.round_closeout.execution_go -ne $null) { return Convert-ToBool $Health.round_closeout.execution_go }
  return $false
}

$root = Resolve-GovernanceRoot -InputRoot $GovernanceRoot
if ([string]::IsNullOrWhiteSpace($StatePath)) {
  $StatePath = Join-Path $root "L1_State.json"
}
$resolvedStatePath = if (Test-Path -LiteralPath $StatePath) { (Resolve-Path -LiteralPath $StatePath).Path } else { [System.IO.Path]::GetFullPath($StatePath) }
if (-not (Test-PathInsideRoot -Root $root -Path $resolvedStatePath)) {
  throw "StatePath must stay inside GovernanceRoot. path=$resolvedStatePath root=$root"
}

$state = Get-Content -LiteralPath $resolvedStatePath -Raw | ConvertFrom-Json

if ($ResetStop) {
  $resetState = [ordered]@{}
  foreach ($property in $state.PSObject.Properties) {
    $resetState[$property.Name] = $property.Value
  }
  $resetState.updated_at = (Get-Date).ToString("s")
  $resetState.should_stop = $false
  $resetState.stop_reason = ""
  $resetState.consecutive_no_progress = 0
  $resetState.repeated_failure_count = 0
  $resetState.last_failure_category = [string]$state.current_failure_category
  $resetState.reset_note = if ([string]::IsNullOrWhiteSpace($ResetReason)) {
    "Manual stop reset requested. Human confirmation is required before Executor runs."
  } else {
    $ResetReason
  }
  $resetState.compliance_note = "L1 governance state only. Reset does not change project Evidence, Revenue, or Execution gates."

  $tempResetPath = $resolvedStatePath + ".tmp"
  $resetState | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $tempResetPath -Encoding UTF8
  Get-Content -LiteralPath $tempResetPath -Raw | ConvertFrom-Json | Out-Null
  Move-Item -LiteralPath $tempResetPath -Destination $resolvedStatePath -Force

  $resetResult = [ordered]@{
    status = "reset"
    state_path = $resolvedStatePath
    should_stop = $false
    stop_reason = ""
    reset_note = $resetState.reset_note
    compliance_note = "Manual reset only. No gate state changed."
  }
  if ($Json) {
    $resetResult | ConvertTo-Json -Depth 6
  } else {
    $resetResult | Format-List
  }
  exit 0
}

if ([string]::IsNullOrWhiteSpace($WeeklyHealthJsonPath)) {
  $WeeklyHealthJsonPath = Get-LatestFile -Directory (Join-Path $root "weekly_health_reports") -Filter "Weekly_Governance_Health_*.json"
}
if ([string]::IsNullOrWhiteSpace($FeedbackJsonPath)) {
  $FeedbackJsonPath = Get-LatestFile -Directory (Join-Path $root "feedback_reports") -Filter "Weekly_Governance_Feedback_*.json"
}
if ([string]::IsNullOrWhiteSpace($ReflectionJsonPath)) {
  $ReflectionJsonPath = Get-LatestFile -Directory (Join-Path $root "reflection_reports") -Filter "L1_Reflection_*.json"
}

$resolvedHealthPath = (Resolve-Path -LiteralPath $WeeklyHealthJsonPath).Path
$resolvedFeedbackPath = (Resolve-Path -LiteralPath $FeedbackJsonPath).Path
$resolvedReflectionPath = (Resolve-Path -LiteralPath $ReflectionJsonPath).Path

foreach ($path in @($resolvedStatePath, $resolvedHealthPath, $resolvedFeedbackPath, $resolvedReflectionPath)) {
  if (-not (Test-PathInsideRoot -Root $root -Path $path)) {
    throw "Path must stay inside GovernanceRoot. path=$path root=$root"
  }
}

$health = Get-Content -LiteralPath $resolvedHealthPath -Raw | ConvertFrom-Json
$reflection = Get-Content -LiteralPath $resolvedReflectionPath -Raw | ConvertFrom-Json

$effectiveMaxIterations = if ($MaxIterations -ge 0) { $MaxIterations } elseif ($env:MAX_ITERATIONS) { [int]$env:MAX_ITERATIONS } else { [int]$state.max_iterations }
$effectiveMaxCostUsd = if ($MaxCostUsd -ge 0) { $MaxCostUsd } elseif ($env:MAX_COST_USD) { [double]$env:MAX_COST_USD } else { [double]$state.max_cost_usd }
$effectiveNoProgressThreshold = if ($NoProgressThreshold -ge 0) { $NoProgressThreshold } elseif ($env:NO_PROGRESS_THRESHOLD) { [int]$env:NO_PROGRESS_THRESHOLD } else { [int]$state.no_progress_threshold }
$effectiveRepeatedFailureThreshold = if ($RepeatedFailureThreshold -ge 0) {
  $RepeatedFailureThreshold
} elseif ($env:REPEATED_FAILURE_THRESHOLD) {
  [int]$env:REPEATED_FAILURE_THRESHOLD
} elseif ($state.repeated_failure_threshold -ne $null) {
  [int]$state.repeated_failure_threshold
} else {
  2
}
$effectiveLoopCostUsd = if ($LoopCostUsd -gt 0) { $LoopCostUsd } elseif ($env:LOOP_COST_USD) { [double]$env:LOOP_COST_USD } else { 0.0 }

$previousScore = $state.current_score
$previousExecutionGo = Convert-ToBool $state.current_execution_go
$currentScore = [int]$health.score
$currentExecutionGo = Get-ExecutionGo -Health $health
$iterationCount = [int]$state.iteration_count + 1
$totalCost = [double]$state.total_cost_usd + $effectiveLoopCostUsd

$hasBaseline = $null -ne $previousScore
$scoreImproved = $false
if ($hasBaseline) {
  $scoreImproved = $currentScore -gt [int]$previousScore
}
$executionImproved = (-not $previousExecutionGo) -and $currentExecutionGo
$hasProgress = (-not $hasBaseline) -or $scoreImproved -or $executionImproved
$consecutiveNoProgress = if ($hasProgress) { 0 } else { [int]$state.consecutive_no_progress + 1 }

$currentFailureCategory = [string]$reflection.failure_category
$lastFailureCategory = [string]$state.current_failure_category
$repeatedFailureCount = if (-not [string]::IsNullOrWhiteSpace($lastFailureCategory) -and $lastFailureCategory -eq $currentFailureCategory) {
  [int]$state.repeated_failure_count + 1
} else {
  1
}

$shouldStop = $false
$stopReason = ""
if ($totalCost -ge $effectiveMaxCostUsd) {
  $shouldStop = $true
  $stopReason = "cost_limit_reached"
} elseif ($iterationCount -ge $effectiveMaxIterations) {
  $shouldStop = $true
  $stopReason = "max_iterations_reached"
} elseif ($consecutiveNoProgress -ge $effectiveNoProgressThreshold) {
  $shouldStop = $true
  $stopReason = "no_progress"
} elseif ($repeatedFailureCount -ge $effectiveRepeatedFailureThreshold) {
  $shouldStop = $true
  $stopReason = "repeated_failure_category"
}

$newState = [ordered]@{
  schema_version = "1.0"
  updated_at = (Get-Date).ToString("s")
  iteration_count = $iterationCount
  max_iterations = $effectiveMaxIterations
  total_cost_usd = [Math]::Round($totalCost, 4)
  max_cost_usd = $effectiveMaxCostUsd
  no_progress_threshold = $effectiveNoProgressThreshold
  repeated_failure_threshold = $effectiveRepeatedFailureThreshold
  last_score = $previousScore
  current_score = $currentScore
  last_execution_go = $previousExecutionGo
  current_execution_go = $currentExecutionGo
  consecutive_no_progress = $consecutiveNoProgress
  last_failure_category = $lastFailureCategory
  current_failure_category = $currentFailureCategory
  repeated_failure_count = $repeatedFailureCount
  should_stop = $shouldStop
  stop_reason = $stopReason
  latest_health_report = $resolvedHealthPath
  latest_feedback_report = $resolvedFeedbackPath
  latest_reflection_report = $resolvedReflectionPath
  cost_model_note = "Estimated loop cost only. This file does not read or claim real API billing."
  compliance_note = "L1 governance state only. This file does not change project Evidence, Revenue, or Execution gates."
}

$tempPath = $resolvedStatePath + ".tmp"
$newState | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $tempPath -Encoding UTF8
Get-Content -LiteralPath $tempPath -Raw | ConvertFrom-Json | Out-Null
Move-Item -LiteralPath $tempPath -Destination $resolvedStatePath -Force

$result = [ordered]@{
  status = "updated"
  state_path = $resolvedStatePath
  iteration_count = $iterationCount
  current_score = $currentScore
  current_execution_go = $currentExecutionGo
  consecutive_no_progress = $consecutiveNoProgress
  current_failure_category = $currentFailureCategory
  repeated_failure_count = $repeatedFailureCount
  should_stop = $shouldStop
  stop_reason = $stopReason
  compliance_note = "State update only. No gate state changed."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
} else {
  $result | Format-List
}

exit 0
