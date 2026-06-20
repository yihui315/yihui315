<#
Skill: weekly-governance-feedback-report
Trigger: after weekly-governance-health-check completes.
Recommendation: run after each weekly health check and review before changing L1 rules or scripts.

Compliance reminder:
- Reads generated health JSON only.
- Writes structured feedback reports only.
- Does not change gate status, evidence status, project readiness, or revenue readiness.
#>

param(
  [string]$GovernanceRoot = "",
  [string]$WeeklyHealthJsonPath = "",
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

function Get-LatestHealthJson {
  param([string]$Root)

  $healthDir = Join-Path $Root "weekly_health_reports"
  if (-not (Test-Path -LiteralPath $healthDir)) {
    throw "weekly_health_reports directory not found: $healthDir"
  }

  $latest = Get-ChildItem -LiteralPath $healthDir -Filter "Weekly_Governance_Health_*.json" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if (-not $latest) {
    throw "No Weekly_Governance_Health_*.json file found in $healthDir"
  }

  return $latest.FullName
}

$root = Resolve-GovernanceRoot -InputRoot $GovernanceRoot
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $root "feedback_reports"
}

if (-not (Test-PathInsideRoot -Root $root -Path $OutputDirectory)) {
  throw "OutputDirectory must stay inside GovernanceRoot. output=$OutputDirectory root=$root"
}

if ([string]::IsNullOrWhiteSpace($WeeklyHealthJsonPath)) {
  $WeeklyHealthJsonPath = Get-LatestHealthJson -Root $root
}

$resolvedHealthJsonPath = (Resolve-Path -LiteralPath $WeeklyHealthJsonPath).Path
if (-not (Test-PathInsideRoot -Root $root -Path $resolvedHealthJsonPath)) {
  throw "WeeklyHealthJsonPath must stay inside GovernanceRoot. file=$resolvedHealthJsonPath root=$root"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$health = Get-Content -LiteralPath $resolvedHealthJsonPath -Raw | ConvertFrom-Json
$dateStamp = Get-Date -Format "yyyy-MM-dd"
$jsonOutputPath = Join-Path $OutputDirectory ("Weekly_Governance_Feedback_{0}.json" -f $dateStamp)
$markdownOutputPath = Join-Path $OutputDirectory ("Weekly_Governance_Feedback_{0}.md" -f $dateStamp)

$issues = @()
if ($null -ne $health.issues) {
  $issues = @(
    $health.issues |
      Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }
  )
}
$status = [string]$health.status
$score = [int]$health.score

$dimensionAssessment = @(
  [PSCustomObject]@{ dimension = "1. Repeated workflow"; rating = "Go"; evidence = "Weekly workflow and feedback generator create repeatable reports."; recommendation = "Track four consecutive weekly reports before claiming trend maturity." },
  [PSCustomObject]@{ dimension = "2. Skill trigger fit"; rating = "Conditional"; evidence = "AGENTS rules define triggers, but some skills remain proposed."; recommendation = "Promote only script-backed skills after verification." },
  [PSCustomObject]@{ dimension = "3. Sub-agent boundaries"; rating = "Conditional"; evidence = "Boundaries exist in L1 docs; active workflow does not spawn agents."; recommendation = "Keep Codex analysis manual until review prompts are stable." },
  [PSCustomObject]@{ dimension = "4. Worker parallelism"; rating = "Conditional"; evidence = "Workflow serializes health then feedback to preserve report causality."; recommendation = "Parallelize read-only scans only after report dependency graph is explicit." },
  [PSCustomObject]@{ dimension = "5. Output quality"; rating = "Go"; evidence = "Markdown and JSON reports are generated together."; recommendation = "Review report length and stale sections monthly." },
  [PSCustomObject]@{ dimension = "6. Feedback loop"; rating = "Go"; evidence = "Health result feeds structured feedback and Codex improvement process."; recommendation = "Require human confirmation before editing rules or scripts." },
  [PSCustomObject]@{ dimension = "7. Failure memory"; rating = "Go"; evidence = "Issues are preserved as machine-readable fields."; recommendation = "Convert repeated issues into failure cases." },
  [PSCustomObject]@{ dimension = "8. Project map"; rating = "Conditional"; evidence = "L1 project registry exists; only one pilot is connected."; recommendation = "Register each new project before it inherits L1 rules." },
  [PSCustomObject]@{ dimension = "9. Business priority"; rating = "Conditional"; evidence = "Audit readiness and no-go boundaries are clear."; recommendation = "Prioritize evidence unblock work over cosmetic governance changes." },
  [PSCustomObject]@{ dimension = "10. Automation"; rating = "Go"; evidence = "GitHub Actions schedule can run health and feedback reports."; recommendation = "Keep notification dry-run until webhook secret handling is reviewed." },
  [PSCustomObject]@{ dimension = "11. Codex mechanism fit"; rating = "Go"; evidence = "Workflow, scripts, AGENTS rules, and review packet are connected."; recommendation = "Use Codex for analysis, not automatic rule mutation." },
  [PSCustomObject]@{ dimension = "12. Governance"; rating = "Go"; evidence = "Reports record compliance boundaries and do not change gates."; recommendation = "Keep no-go states explicit in pilot records." }
)

$recommendations = New-Object System.Collections.Generic.List[object]
if ($status -ne "pass") {
  $recommendations.Add([PSCustomObject]@{
    priority = "P0"
    action = "Resolve weekly governance health blockers before claiming audit readiness."
    owner = "Codex + Human Reviewer"
    requires_human_confirmation = $true
  })
}
if ($issues.Count -gt 0) {
  $recommendations.Add([PSCustomObject]@{
    priority = "P1"
    action = "Convert repeated health issues into failure cases or explicit AGENTS rules."
    owner = "Codex"
    requires_human_confirmation = $true
  })
}
$recommendations.Add([PSCustomObject]@{
  priority = "P2"
  action = "Review this feedback report and approve any L1 rule or script changes manually."
  owner = "Human Reviewer"
  requires_human_confirmation = $true
})
$recommendations.Add([PSCustomObject]@{
  priority = "P2"
  action = "Preserve project no-go states when evidence remains missing."
  owner = "Codex"
  requires_human_confirmation = $false
})

$recommendationArray = @($recommendations | ForEach-Object { $_ })

$codexImprovementSuggestions = New-Object System.Collections.Generic.List[object]
foreach ($dimension in $dimensionAssessment) {
  if ($dimension.rating -eq "Conditional" -or $dimension.rating -eq "Needs Work") {
    $codexImprovementSuggestions.Add([PSCustomObject]@{
      source = "12D:{0}" -f $dimension.dimension
      suggested_action = $dimension.recommendation
      requires_human_confirmation = $true
      execution_boundary = "Codex may draft a patch or report only; Human confirmation is required before durable changes."
    })
  }
}
if ($issues.Count -gt 0) {
  $codexImprovementSuggestions.Add([PSCustomObject]@{
    source = "weekly_health_issues"
    suggested_action = "Inspect health issues and create the smallest safe governance fix or failure-case record."
    requires_human_confirmation = $true
    execution_boundary = "No gate, evidence, revenue, provider, payment, or production state may change automatically."
  })
}
$codexImprovementSuggestionArray = @($codexImprovementSuggestions.ToArray())

$feedback = [PSCustomObject]@{
  report_type = "weekly_governance_feedback"
  generated_at = (Get-Date).ToString("s")
  source_health_json = $resolvedHealthJsonPath
  health_summary = [PSCustomObject]@{
    status = $status
    score = $score
    round_closeout_status = $health.round_closeout.status
    artifact_hygiene_status = $health.artifact_hygiene.status
    secret_shape_hits = $health.secret_scan.secret_shape_hits
    env_like_files = $health.secret_scan.env_like_files
    issues = @($issues)
  }
  dimension_assessment = @($dimensionAssessment)
  improvement_recommendations = @($recommendationArray)
  codex_improvement_suggestions = @($codexImprovementSuggestionArray)
  codex_improvement_flow = [PSCustomObject]@{
    step_1 = "Health Check generates Markdown and JSON."
    step_2 = "Feedback generator converts health data into 12D assessment and recommendations."
    step_3 = "Codex reviews feedback and drafts changes."
    step_4 = "Human reviewer confirms before L1 rules, scripts, gates, or evidence files are changed."
  }
  auto_allowed = @(
    "Generate reports",
    "Open issues or recommendations in review documents",
    "Run read-only or dry-run validation"
  )
  human_approval_required = @(
    "Change gate decisions",
    "Mark evidence present=yes",
    "Enable real webhook sending",
    "Promote a skill to active",
    "Modify production, payment, provider, or secret-bearing configuration"
  )
  compliance_note = "Feedback is advisory. It does not change gate state or project readiness."
}

$feedback | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonOutputPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Weekly Governance Feedback $dateStamp")
$lines.Add("")
$lines.Add("## Summary")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Field", "Value")
Add-TableRow -Lines $lines -Cells @("---", "---")
Add-TableRow -Lines $lines -Cells @("source_health_json", (Format-InlineCode $resolvedHealthJsonPath))
Add-TableRow -Lines $lines -Cells @("status", (Format-InlineCode $status))
Add-TableRow -Lines $lines -Cells @("score", (Format-InlineCode $score))
Add-TableRow -Lines $lines -Cells @("secret_shape_hits", (Format-InlineCode $health.secret_scan.secret_shape_hits))
Add-TableRow -Lines $lines -Cells @("env_like_files", (Format-InlineCode $health.secret_scan.env_like_files))
$lines.Add("")
$lines.Add("## Issues")
$lines.Add("")
if ($issues.Count -gt 0) {
  foreach ($issue in $issues) {
    $lines.Add(("- {0}" -f (Format-InlineCode $issue)))
  }
} else {
  $lines.Add("- none")
}
$lines.Add("")
$lines.Add("## 12D Assessment")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Dimension", "Rating", "Evidence", "Recommendation")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---")
foreach ($dimension in $dimensionAssessment) {
  Add-TableRow -Lines $lines -Cells @($dimension.dimension, $dimension.rating, $dimension.evidence, $dimension.recommendation)
}
$lines.Add("")
$lines.Add("## Improvement Recommendations")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Priority", "Action", "Owner", "Human confirmation")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---")
foreach ($recommendation in $recommendations) {
  Add-TableRow -Lines $lines -Cells @($recommendation.priority, $recommendation.action, $recommendation.owner, [string]$recommendation.requires_human_confirmation)
}
$lines.Add("")
$lines.Add("## Codex Improvement Suggestions")
$lines.Add("")
Add-TableRow -Lines $lines -Cells @("Source", "Suggested action", "Human confirmation", "Boundary")
Add-TableRow -Lines $lines -Cells @("---", "---", "---", "---")
if ($codexImprovementSuggestions.Count -gt 0) {
  foreach ($suggestion in $codexImprovementSuggestions) {
    Add-TableRow -Lines $lines -Cells @($suggestion.source, $suggestion.suggested_action, [string]$suggestion.requires_human_confirmation, $suggestion.execution_boundary)
  }
} else {
  Add-TableRow -Lines $lines -Cells @("none", "No Codex improvement suggestion generated.", "true", "Continue observation.")
}
$lines.Add("")
$lines.Add("## Codex Improvement Flow")
$lines.Add("")
$lines.Add("1. Health Check generates Markdown and JSON.")
$lines.Add("2. Feedback generator converts health data into 12D assessment and recommendations.")
$lines.Add("3. Codex reviews feedback and drafts changes.")
$lines.Add("4. Human reviewer confirms before L1 rules, scripts, gates, or evidence files are changed.")
$lines.Add("")
$lines.Add("## Compliance Boundary")
$lines.Add("")
$lines.Add("- Feedback is advisory.")
$lines.Add("- This report does not change gate decisions.")
$lines.Add("- Evidence rows remain unchanged unless a real Human Operator submits masked evidence.")
$lines.Add("- Real notifications, production settings, provider/payment changes, and skill promotions require human approval.")

$lines | Set-Content -LiteralPath $markdownOutputPath -Encoding UTF8

$result = [ordered]@{
  status = "generated"
  generated_at = (Get-Date).ToString("s")
  source_health_json = $resolvedHealthJsonPath
  markdown_output_path = $markdownOutputPath
  json_output_path = $jsonOutputPath
  health_status = $status
  health_score = $score
  recommendation_count = $recommendationArray.Count
  compliance_note = "Advisory feedback only. No gate state changed."
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
} else {
  $result | Format-List
}

exit 0
