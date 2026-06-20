# Core Skill List For gstack Audit

## Summary

This file summarizes the L1 Skill chain currently documented for audit. Status is intentionally conservative and follows `Skill_Registry.md`.

## Reviewer Checklist

- Check whether each Skill status is supported by evidence, not assumption.
- Confirm script-backed claims point to an included or referenced script.
- Confirm `proposed` Skills are not described as runtime-active.
- Confirm revenue or execution work remains blocked unless final project-level gate evidence exists.

## High Priority Chain

| Skill | Current status | Maturity | Script support | Audit note |
| --- | --- | --- | --- | --- |
| `human-evidence-intake-check` | active | 8/10 | `scripts/human-evidence-intake-check.ps1` | Read-only intake validation verified; current ai占卜.ai evidence correctly remains blocked. |
| `orchestrator-decision-refresh` | proposed | 7/10 | no dedicated script | Decision refresh contract is documented and now requires round closeout after completion. |
| `tianji-revenue-gate` | observed-local | 8/10 | local skill file observed | Revenue work must read final orchestrator verdict before proceeding. |

## Medium Priority Chain

| Skill | Current status | Maturity | Script support | Audit note |
| --- | --- | --- | --- | --- |
| `governance-artifact-hygiene` | active | 8/10 | `scripts/governance-artifact-hygiene.ps1` | Read-only dry-run archive planner verified; no delete/archive execution by default. |
| `round-closeout-validator` | proposed | 8/10 | `scripts/round-closeout-validator.ps1` | Read-only script verified and included in this package. |
| `weekly-governance-health-check` | active | 9/10 | `scripts/weekly-governance-health-check.ps1` | Orchestrates closeout, artifact hygiene, secret-shape scan, and Slack/generic webhook notification with explicit enable switch. |
| `weekly-governance-feedback-report` | active | 8/10 | `scripts/generate-weekly-feedback-report.ps1` | Converts weekly health JSON into Markdown/JSON 12D feedback and improvement recommendations. |
| `l1-governance-reflector` | active | 9/10 | `scripts/reflect-l1-governance-loop.ps1` | Produces advisory reflection JSON/Markdown with recoverability and strategy fields. |
| `l1-loop-state-updater` | active | 9/10 | `scripts/update-l1-loop-state.ps1` | Applies stopping conditions, preserves extended state, and allows bounded auto-retry for recoverable failures. |
| `l1-reflect-and-improve` | active | 8/10 | `scripts/reflect-and-improve.ps1` | Produces advisory Codex improvement suggestions for Human review. |
| `l1-observability-dashboard` | active | 8/10 | `scripts/generate-l1-observability-dashboard.ps1` | Produces read-only dashboard across health, stop state, evidence intake, and pilot status. |
| `ai-divination-evidence-publication-sub-loop` | documented | 7/10 | project design document | Project-specific sub-loop for missing evidence detection, Human guidance, read-only intake validation, and escalation. |

## Supporting Reusable Skills

| Skill | Current status | Maturity | Script support | Audit note |
| --- | --- | --- | --- | --- |
| `codex-system-governance-auditor` | observed-local | 8/10 | local skill file observed | Used for governance audits, durable artifact design, and evidence-first review. |
| `executor-preflight-check` | observed-local | 7/10 | local skill file observed | Passing preflight is explicitly not Execution Go. |
| `HealthChecker` | documented | 7/10 | `.codex/agents/healthchecker.md` | Sub-agent role for health-only interpretation; no gate mutation. |
| `Reflector` | documented | 7/10 | `.codex/agents/reflector.md` | Sub-agent role for root-cause analysis and next-goal recommendation; advisory only. |
| `Executor` | documented | 8/10 | `.codex/agents/executor.md` | Sub-agent role for safe-auto low-risk governance updates and Human-confirmed higher-risk improvements; must check `should_stop=false`. |

## Current Execution Chain

`Human Evidence -> human-evidence-intake-check -> State Sync -> orchestrator-decision-refresh -> round-closeout-validator -> REVIEW_PACKET_Master`

Loop Engineering chain:

`HealthChecker -> weekly health -> feedback -> Reflector -> L1_State update -> safe-auto or Human-confirmed Executor`

v2.0 advisory and observability chain:

`Health/Feedback/Reflection/State -> reflect-and-improve -> Human review`

`Health/Feedback/Reflection/State/Evidence/Pilot -> L1_Observability_Dashboard`

Recoverable reflection chain:

`Health/Feedback/State -> Reflector(recoverable + strategy) -> State Updater(auto_retry_count or hard stop) -> Human review if budget exhausted`

ai占卜.ai evidence sub-loop:

`Detect -> Prepare -> Guide -> Collect & Verify -> Update descriptive tracking -> Escalate`

## Script-Backed Evidence

| Evidence | Location | Status |
| --- | --- | --- |
| Human evidence intake script | `已验证脚本/human-evidence-intake-check.ps1` | Included in audit package |
| Closeout validation script | `已验证脚本/round-closeout-validator.ps1` | Included in audit package |
| Artifact hygiene script | `已验证脚本/governance-artifact-hygiene.ps1` | Included in audit package |
| Weekly health script | `已验证脚本/weekly-governance-health-check.ps1` | Included in audit package |
| Reflector script | `已验证脚本/reflect-l1-governance-loop.ps1` | Included in audit package v2.0 |
| State updater script | `已验证脚本/update-l1-loop-state.ps1` | Included in audit package v2.0 |
| Improvement script | `已验证脚本/reflect-and-improve.ps1` | Included in audit package v2.0 |
| Observability script | `已验证脚本/generate-l1-observability-dashboard.ps1` | Included in audit package v2.0 |
| Artifact hygiene dry-run example | `00_审计材料索引.md` | Documented in v1.3 package |
| Blocked protection table | `00_审计材料索引.md` | Documented in v1.3 package |
| Closeout validation record | `REVIEW_PACKET_Master.md` in source L1 directory | Recorded as documentation-scope pass |
| Secret-shape scan result | `REVIEW_PACKET_Master.md` in source L1 directory | Recorded as `secret_shape_hits=0` |

## Additional v1.7 Evidence

| Evidence | Location | Status |
| --- | --- | --- |
| Webhook config example | `webhook_config_example.md` | Runtime-only URL pattern documented |
| Inactive schedule example | `automation_examples/github-actions-weekly-governance-health.yml` | Included but not enabled as CI |

## Additional v1.8 Evidence

| Evidence | Location | Status |
| --- | --- | --- |
| Active weekly workflow | `../.github/workflows/weekly-governance-health-check.yml` | Scheduled self-run path implemented |
| Feedback generator | `../scripts/generate-weekly-feedback-report.ps1` | Verified locally |
| Feedback reports | `../feedback_reports/` | Markdown and JSON reports generated |
| Self-evolution architecture | `../self_evolution/L1_Self_Run_Self_Evolution_Architecture.md` | Documented |

## Additional v1.9 Evidence

| Evidence | Location | Status |
| --- | --- | --- |
| Sub-agent definitions | `../../.codex/agents/` | Documented |
| Controlled loop state | `../L1_State.json` | Implemented |
| Reflection reports | `../reflection_reports/` | Generated by script |
| Stopping-condition workflow wiring | `../../.github/workflows/weekly-governance-health-check.yml` | Implemented |

## Additional v2.0 Evidence

| Evidence | Location | Status |
| --- | --- | --- |
| Codex improvement report | `../improvement_reports/` | Generated |
| Observability dashboard | `../L1_Observability_Dashboard.md` | Generated |
| Stop reset support | `../scripts/update-l1-loop-state.ps1` | Manual-only |

## Additional v2.1 Evidence

| Evidence | Location | Status |
| --- | --- | --- |
| Recoverable Reflector fields | `reflector.md` and `宸查獙璇佽剼鏈?reflect-l1-governance-loop.ps1` | Implemented |
| Bounded auto-retry state fields | `L1_State.json` and `宸查獙璇佽剼鏈?update-l1-loop-state.ps1` | Implemented with hard-stop priority preserved |
| ai占卜.ai evidence/publication sub-loop | `../Projects/ai占卜.ai/当前状态/AI_Divination_Evidence_Publication_Sub_Loop_Design_2026-06-20.md` | Documented |

## Audit Boundaries

- `proposed` means documented but not fully promoted as a runtime-active Skill.
- `observed-local` means a local Skill file was observed and summarized, but this package does not prove plugin/runtime invocation.
- `round-closeout-validator` has script support, but the Skill registry remains conservative until active promotion is formally recorded.
- Sub-agent definitions are documented role contracts; they do not prove autonomous execution.
- Executor is not wired to GitHub Actions; safe-auto is local and low-risk only, while higher-risk work requires Human confirmation plus `should_stop=false`.
- Improvement and dashboard scripts are report-only/read-only and do not authorize Executor.
- No Skill may fabricate evidence, secrets, payment readiness, or gate state.

## Recommended Next Promotion Steps

1. Promote `round-closeout-validator` only after the active promotion checklist is accepted by the maintainer.
2. Add read-only script support for secret-shape scan and decision refresh validation.
3. Add a repeatable local or CI job for secret-shape scan, artifact hygiene, and closeout validation.
4. Record every promotion in `Skill_Registry.md`, `REVIEW_PACKET_Master.md`, and `CHANGELOG.md`.
