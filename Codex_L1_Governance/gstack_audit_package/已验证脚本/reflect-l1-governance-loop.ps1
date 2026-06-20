<#
Skill: l1-governance-reflector
Trigger: after weekly health and feedback reports are generated.
Recommendation: run before updating L1_State.json so stopping conditions can use the latest failure category.

Compliance reminder:
- Writes reflection reports only.
- Does not change gate status, evidence status, project readiness, or revenue readiness.
- Uses estimated state/cost data only; does not read real billing.
#>

param(
  [string]$GovernanceRoot = "",
  [string]$WeeklyHealthJsonPath = "",
  [string]$FeedbackJsonPath = "",
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

function Get-FailureCategory {
  param(
    [object]$Health,
    [object]$Feedback,
    [object]$State
  )

  if ($State.total_cost_usd -ge $State.max_cost_usd) { return "cost" }
  if ($Health.secret_scan.secret_shape_hits -gt 0 -or $Health.secret_scan.env_like_files -gt 0) { return "data" }
  if ($Health.round_closeout.status -eq "blocked" -or $Health.artifact_hygiene.status -eq "blocked") { return "logic" }
  if ($Health.status -eq "blocked" -or $Health.status -eq "conditional") { return "environment" }

  $conditionalDimensions = @(
    $Feedback.dimension_assessment |
      Where-Object { $_.rating -eq "Conditional" -or $_.rating -eq "Needs Work" }
  )
  if ($conditionalDimensions.Count -gt 0) { return "prompt" }

  return "external_block"
}

function Get-IssueList {
  param(
    [object]$Health,
    [object]$Feedback,
    [string]$FailureCategory
  )

  $items = New-Object System.Collections.Generic.List[string]
  foreach ($issue in @($Health.issues)) {
    if (-not [string]::IsNullOrWhiteSpace([string]$issue)) {
      $items.Add([string]$issue)
    }
  }

  foreach ($dimension in @($Feedback.dimension_assessment)) {
    if ($dimension.rating -eq "Conditional" -or $dimension.rating -eq "Needs Work") {
      $items.Add(("{0}: {1}" -f $dimension.dimension, $dimension.recommendation))
    }
  }

  if ($items.Count -eq 0) {
    $items.Add("No health blockers were detected; continue accumulating trend evidence before claiming stronger maturity.")
  }

  if ($FailureCategory -eq "external_block") {
    $items.Add("Project-level execution remains externally blocked by missing Human Operator evidence.")
  }

  return @($items | Select-Object -Unique)
}

function Get-Suggestions {
  param(
    [string]$FailureCategory,
    [object[]]$Issues,
    [object]$State
  )

  $suggestions = New-Object System.Collections.Generic.List[object]

  switch ($FailureCategory) {
    "cost" {
      $suggestions.Add([PSCustomObject]@{
        action = "Pause the loop and review estimated cost inputs before the next run."
        priority = "high"
        estimated_effort = "low"
        expected_impact = "Prevents runaway loop cost; no direct execution_go impact."
      })
    }
    "logic" {
      $suggestions.Add([PSCustomObject]@{
        action = "Inspect blocked closeout or artifact hygiene records and create a targeted fix plan."
        priority = "high"
        estimated_effort = "medium"
        expected_impact = "Can improve score by clearing L1 logic blockers."
      })
    }
    "data" {
      $suggestions.Add([PSCustomObject]@{
        action = "Resolve secret-shape or env-like findings before any further audit readiness claim."
        priority = "high"
        estimated_effort = "medium"
        expected_impact = "Can restore score and audit readiness; no direct execution_go impact."
      })
    }
    "environment" {
      $suggestions.Add([PSCustomObject]@{
        action = "Review workflow/runtime environment failures and rerun read-only validators after correction."
        priority = "high"
        estimated_effort = "medium"
        expected_impact = "Can restore weekly health pass status."
      })
    }
    "prompt" {
      $suggestions.Add([PSCustomObject]@{
        action = "Tighten AGENTS or Skill trigger wording for recurring conditional dimensions."
        priority = "medium"
        estimated_effort = "low"
        expected_impact = "Can improve governance quality and reduce repeated conditional findings."
      })
    }
    default {
      $suggestions.Add([PSCustomObject]@{
        action = "Keep L1 running and prioritize real Human Operator evidence for project-level progress."
        priority = "medium"
        estimated_effort = "medium"
        expected_impact = "Required before project execution_go can improve."
      })
    }
  }

  if ($State.repeated_failure_count -ge 1 -and $State.current_failure_category -eq $FailureCategory) {
    $suggestions.Add([PSCustomObject]@{
      action = "Lower the next loop goal or pause for Human review because the same failure category repeated."
      priority = "high"
      estimated_effort = "low"
      expected_impact = "Prevents repeated low-value loops; no direct execution_go impact."
    })
  }

  return $suggestions.ToArray()
}

$root = Resolve-GovernanceRoot -InputRoot $GovernanceRoot

if ([string]::IsNullOrWhiteSpace($WeeklyHealthJsonPath)) {
  $WeeklyHealthJsonPath = Get-LatestFile -Directory (Join-Path $root "weekly_health_reports") -Filter "Weekly_Governance_Health_*.json"
}
if ([string]::IsNullOrWhiteSpace($FeedbackJsonPath)) {
  $FeedbackJsonPath = Get-LatestFile -Directory (Join-Path $root "feedback_reports") -Filter "Weekly_Governance_Feedback_*.json"
}
if ([string]::IsNullOrWhiteSpace($StatePath)) {
  $StatePath = Join-Path $root "L1_State.json"
}
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $root "reflection_reports"
}

$resolvedHealthPath = (Resolve-Path -LiteralPath $WeeklyHealthJsonPath).Path
$resolvedFeedbackPath = (Resolve-Path -LiteralPath $FeedbackJsonPath).Path
$resolvedStatePath = (Resolve-Path -LiteralPath $StatePath).Path

foreach ($path in @($resolvedHealthPath, $resolvedFeedbackPath, $resolvedStatePath, $OutputDirectory)) {
  if (-not (Test-PathInsideRoot -Root $root -Path $path)) {
    throw "Path must stay inside GovernanceRoot. path=$path root=$root"
  }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$health = Get-Content -LiteralPath $resolvedHealthPath -Raw | ConvertFrom-Json
$feedback = Get-Content -LiteralPath $resolvedFeedbackPath -Raw | ConvertFrom-Json
$state = Get-Content -LiteralPath $resolvedStatePath -Raw | ConvertFrom-Json

$failureCategory = Get-FailureCategory -Health $health -Feedback $feedback -State $state
$issues = @(Get-IssueList -Health $health -Feedback $feedback -FailureCategory $failureCategory)
$suggestions = @(Get-Suggestions -FailureCategory $failureCategory -Issues $issues -State $state)
$shouldContinue = -not [bool]$state.should_stop
if ($state.repeated_failure_count -ge 1 -and $state.current_failure_category -eq $failureCategory) {
  $shouldContinue = $false
}

$rootCause = switch ($failureCategory) {
  "cost" { "The loop is constrained by the configured estimated cost ceiling rather than missing engineering work." }
  "logic" { "The loop is blocked by L1 validation or closeout logic that must be resolved before stronger readiness claims." }
  "data" { "The loop is blocked by data hygiene or secret-shape safety findings." }
  "environment" { "The loop is blocked by runtime or environment health conditions." }
  "prompt" { "The loop is healthy but still has conditional governance quality dimensions that need clearer instructions or triggers." }
  default { "The L1 loop is healthy; project progress remains blocked by external Human Operator evidence rather than L1 automation." }
}

$nextGoal = if ($shouldContinue) {
  "Review the top Reflector suggestion and apply it only after Human confirmation."
} else {
  "Pause or lower the next loop goal and request Human review."
}

$dateStamp = Get-Date -Format "yyyy-MM-dd"
$jsonOutputPath = Join-Path $OutputDirectory ("L1_Reflection_{0}.json" -f $dateStamp)
$markdownOutputPath = Join-Path $OutputDirectory ("L1_Reflection_{0}.md" -f $dateStamp)

$reflection = [PSCustomObject]@{
  root_cause_analysis = $rootCause
  failure_category = $failureCategory
  key_issues = @($issues)
  evolution_suggestions = @($suggestions)
  should_continue = $shouldContinue
  recommended_next_goal = $nextGoal
  source_health_json = $resolvedHealthPath
  source_feedback_json = $resolvedFeedbackPath
  source_state_json = $resolvedStatePath
  compliance_note = "Reflection is advisory. No gate, evidence, revenue, payment, provider, or production state changed."
}

$reflection | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonOutputPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# L1 Reflection $dateStamp")
$lines.Add("")
$lines.Add("## Summary")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Field", "Value")
Add-TableRow -Lines $lines -Cells @("---", "---")
Add-TableRow -Lines $lines -Cells @("failure_category", (Format-InlineCode $failureCategory))
Add-TableRow -Lines $lines -Cells @("should_continue", (Format-InlineCode $shouldContinue))
Add-TableRow -Lines $lines -Cells @("recommended_next_goal", $nextGoal)
$lines.Add("")
$lines.Add("## Root Cause")
$lines.Add("")
$lines.Add($rootCause)
$lines.Add("")
$lines.Add("## Key Issues")
$lines.Add("")
foreach ($issue in $issues) {
  $lines.Add("- " + $issue)
}
$lines.Add("")
$lines.Add("## Evolution Suggestions")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Priority", "Effort", "Action", "Expected impact")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---")
foreach ($suggestion in $suggestions) {
  Add-TableRow -Lines $lines -Cells @($suggestion.priority, $suggestion.estimated_effort, $suggestion.action, $suggestion.expected_impact)
}
$lines.Add("")
$lines.Add("## Compliance Boundary")
$lines.Add("")
$lines.Add("- Reflection is advisory.")
$lines.Add("- Executor may act only after Human confirmation.")
$lines.Add("- No gate, evidence, revenue, payment, provider, or production state changed.")

$lines | Set-Content -LiteralPath $markdownOutputPath -Encoding UTF8

$result = [ordered]@{
  status = "reflected"
  generated_at = (Get-Date).ToString("s")
  markdown_output_path = $markdownOutputPath
  json_output_path = $jsonOutputPath
  failure_category = $failureCategory
  should_continue = $shouldContinue
  compliance_note = "Advisory reflection only. No gate state changed."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
} else {
  $result | Format-List
}

exit 0
