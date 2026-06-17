param(
  [string]$GovernanceRoot = "",
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

function Test-RequiredFile {
  param(
    [string]$Root,
    [string]$RelativePath
  )

  $path = Join-Path $Root $RelativePath
  [PSCustomObject]@{
    path = $RelativePath
    present = Test-Path -LiteralPath $path -PathType Leaf
  }
}

function Find-RequiredLeafFile {
  param(
    [string]$Root,
    [string]$LeafName,
    [string]$Label
  )

  $match = $script:AllFiles |
    Where-Object { $_.Name -eq $LeafName } |
    Select-Object -First 1

  [PSCustomObject]@{
    path = $Label
    present = $null -ne $match
  }
}

function Find-RequiredPatternFile {
  param(
    [string]$Root,
    [string]$NamePattern,
    [string]$PathPattern,
    [string]$Label
  )

  $match = $script:AllFiles |
    Where-Object { $_.Name -like $NamePattern -and $_.FullName -like $PathPattern } |
    Select-Object -First 1

  [PSCustomObject]@{
    path = $Label
    present = $null -ne $match
  }
}

$root = Resolve-GovernanceRoot -InputRoot $GovernanceRoot
$script:AllFiles = @(
  Get-ChildItem -LiteralPath $root -Recurse -Force -File -ErrorAction SilentlyContinue
)

$requiredLiteralFiles = @(
  "INDEX.md",
  "REVIEW_PACKET_Master.md",
  "CHANGELOG.md",
  "02_Gate_System\Gate_Decision_Canonical.json"
)

$fileResults = foreach ($relativePath in $requiredLiteralFiles) {
  Test-RequiredFile -Root $root -RelativePath $relativePath
}

$requiredLeafFiles = @(
  @{ LeafName = "Skill_Registry.md"; Label = "Skill_Registry.md" },
  @{ LeafName = "Skill_Trigger_Rules.md"; Label = "Skill_Trigger_Rules.md" },
  @{ LeafName = "2026-06-17_L1_Layer_Baseline_Scan_Report.md"; Label = "L1 baseline scan report" }
)

$leafResults = foreach ($item in $requiredLeafFiles) {
  Find-RequiredLeafFile -Root $root -LeafName $item.LeafName -Label $item.Label
}

$patternResults = @(
  Find-RequiredPatternFile -Root $root -NamePattern "00_*.md" -PathPattern "*03_*" -Label "failure case index"
)

$fileResults = @($fileResults) + @($leafResults) + @($patternResults)

$missingFiles = @($fileResults | Where-Object { -not $_.present } | Select-Object -ExpandProperty path)

$decisionPath = Join-Path $root "02_Gate_System\Gate_Decision_Canonical.json"
$decisionParseOk = $false
$decisionSummary = $null
if (Test-Path -LiteralPath $decisionPath -PathType Leaf) {
  try {
    $decision = Get-Content -Raw -LiteralPath $decisionPath | ConvertFrom-Json
    $decisionParseOk = $true
    $decisionSummary = [PSCustomObject]@{
      schema_version = $decision.schema_version
      overall_decision = $decision.overall_decision
      execution_go = $decision.execution_go
      approved_scope = $decision.approved_scope
    }
  } catch {
    $decisionParseOk = $false
  }
}

$reviewPacketPath = Join-Path $root "REVIEW_PACKET_Master.md"
$reviewPacketChecks = [ordered]@{
  has_skill_integration_record = $false
  has_l1_baseline_record = $false
  has_index_creation_record = $false
}
if (Test-Path -LiteralPath $reviewPacketPath -PathType Leaf) {
  $reviewText = Get-Content -Raw -LiteralPath $reviewPacketPath
  $reviewPacketChecks.has_skill_integration_record = $reviewText -match "Skill Integration Record"
  $reviewPacketChecks.has_l1_baseline_record = $reviewText -match "L1 Layer Baseline Scan Record"
  $reviewPacketChecks.has_index_creation_record = $reviewText -match "L1 Index Creation"
}

$changelogPath = Join-Path $root "CHANGELOG.md"
$changelogChecks = [ordered]@{
  has_l1_baseline_entry = $false
  has_index_entry = $false
}
if (Test-Path -LiteralPath $changelogPath -PathType Leaf) {
  $changelogText = Get-Content -Raw -LiteralPath $changelogPath
  $changelogChecks.has_l1_baseline_entry = $changelogText -match "L1 layer 12D baseline scan report"
  $changelogChecks.has_index_entry = $changelogText -match "INDEX.md"
}

$envLikeFiles = @(
  $script:AllFiles |
    Where-Object { $_.Name -like ".env*" } |
    Select-Object -ExpandProperty FullName
)

$status = "pass"
$issues = @()

if ($missingFiles.Count -gt 0) {
  $status = "blocked"
  $issues += "missing_required_files"
}

if (-not $decisionParseOk) {
  $status = "blocked"
  $issues += "decision_json_parse_failed"
}

if ($reviewPacketChecks.Values -contains $false) {
  if ($status -ne "blocked") { $status = "conditional" }
  $issues += "review_packet_record_incomplete"
}

if ($changelogChecks.Values -contains $false) {
  if ($status -ne "blocked") { $status = "conditional" }
  $issues += "changelog_record_incomplete"
}

if ($envLikeFiles.Count -gt 0) {
  $status = "blocked"
  $issues += "env_like_files_present"
}

$result = [PSCustomObject]@{
  closeout_status = $status
  checked_at = (Get-Date).ToString("s")
  governance_root = $root
  missing_files = $missingFiles
  decision_json_parse_ok = $decisionParseOk
  decision_summary = $decisionSummary
  review_packet_checks = $reviewPacketChecks
  changelog_checks = $changelogChecks
  env_like_files_present = $envLikeFiles.Count
  issues = $issues
  recommendation = if ($status -eq "pass") {
    "Round closeout can proceed for documentation scope. This does not grant execution approval."
  } elseif ($status -eq "conditional") {
    "Resolve incomplete records before treating the round as fully closed."
  } else {
    "Do not close the round until blocked checks are fixed."
  }
}

if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  $result | Format-List
}

if ($status -eq "blocked") {
  exit 2
}

if ($status -eq "conditional") {
  exit 1
}

exit 0
