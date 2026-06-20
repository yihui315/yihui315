# Skill Trigger Rules

## Purpose

This file defines proposed L1 skill triggers. These are governance rules first; implementation as Codex skills can happen later.

## Trigger Table

| Skill name | Trigger condition | Required input | Required output | Related gate |
| --- | --- | --- | --- | --- |
| `Evidence_Validator` | Evidence Gate needs refresh or a Human Operator submission was added | filled `submitted_by`, `submitted_at`, evidence rows, masked artifact references | structured evidence validation report | Evidence |
| `Revenue_Gate_Checker` | Pricing, checkout, payment, webhook, or entitlement readiness is claimed | masked revenue artifacts, environment, provider mode | revenue gate readiness report | Revenue |
| `Gate_Decision_Refresh` | Any gate status, blocker count, or approval scope changes | latest gate state JSON and validation results | updated canonical decision JSON | All gates |
| `12D_Baseline_Scan` | New project onboarding, major governance review, or monthly baseline | project path, source list, current gate decision | 12D scorecard and improvement checklist | All gates |
| `Failure_Case_Recorder` | A blocker repeats, a gate cannot advance, or a compliance refusal occurs | incident summary, related files, attempted actions | failure case entry and index update | All gates |
| `Review_Packet_Scorer` | A review packet is created or refreshed | project review packet, gate decision, 12D scan | quantitative score section and trend notes | All gates |
| `Secret_Shape_Scan` | Evidence or revenue artifacts are added | target paths and masking policy | secret-shape result with hit count | Evidence, Revenue |
| `weekly-governance-health-check` | Weekly L1 governance cycle ends or audit readiness is claimed | L1 root, closeout script, artifact hygiene script | Markdown health report with score, closeout status, artifact plan, and secret-shape summary | Governance |
| `weekly-governance-feedback-report` | Weekly health JSON is generated | `Weekly_Governance_Health_YYYY-MM-DD.json` | Markdown and JSON feedback reports with 12D assessment and recommendations | Governance |
| `human-evidence-intake-check` | Human Operator masked evidence is submitted or updated | Evidence `.md` file and masked artifact references | validator summary, missing fields, readiness for orchestrator review | Evidence, Revenue |
| `orchestrator-decision-refresh` | Evidence, Revenue, Approval, Executor, or Environment gate changes | `ORCHESTRATOR_GATE_STATE.json` and validator outputs | refreshed decision JSON and Review Packet note | All gates |
| `tianji-revenue-gate` | Revenue, payment, checkout, webhook, entitlement, or monetization safety is in scope | final orchestrator decision and masked revenue evidence | Revenue Evidence verdict and missing evidence list | Revenue |
| `governance-artifact-hygiene` | Governance artifact directories grow or weekly health check detects sprawl | sanitized artifact listings, file counts, current review packet | keep/archive proposal and dry-run commands | Governance |
| `round-closeout-validator` | Orchestrator or Self-Distillation round ends | review packet, gate decision, validator summaries, changelog, failure index | round closeout report and next-round readiness | All gates |

## Trigger Rules

1. Prefer a specific gate skill over a generic review when a gate status may change.
2. Run `Secret_Shape_Scan` before treating evidence artifacts as reviewable.
3. Run `Gate_Decision_Refresh` after, not before, validators have produced results.
4. Run `Failure_Case_Recorder` whenever the correct outcome is blocked because of a compliance boundary.
5. Do not let a skill mark `go` unless the required gate evidence exists.
6. Run `human-evidence-intake-check` before any Human Operator evidence affects a gate decision.
7. Run `orchestrator-decision-refresh` after any gate status changes.
8. Bind `tianji-revenue-gate` to the final orchestrator decision; revenue work stops when the decision is missing, stale, `no_go`, or `plan-only`.
9. Run `governance-artifact-hygiene` in dry-run mode first; archive or delete actions require explicit approval.
10. Run `round-closeout-validator` before treating a governance round as complete.
11. Run `weekly-governance-health-check` before claiming weekly L1 audit readiness.
12. Run `weekly-governance-feedback-report` after weekly health JSON is generated; feedback is advisory and requires Human confirmation before changes.

## Post-Run Record Map

| Skill | Required record location | Minimum record |
| --- | --- | --- |
| `human-evidence-intake-check` | project Review Packet; L1 Master only if rule/template changed | validator summary, missing fields, secret-safety note |
| `orchestrator-decision-refresh` | project Review Packet and decision artifact | previous decision, new decision, blocker count, next action |
| `tianji-revenue-gate` | project Review Packet and revenue evidence report | Revenue Evidence verdict, missing evidence, safety status |
| `governance-artifact-hygiene` | Review Packet or artifact hygiene report | keep/archive plan, dry-run command, manual approval note |
| `round-closeout-validator` | Review Packet or closeout report | closeout status, missing records, next-round recommendation |
| `weekly-governance-health-check` | `weekly_health_reports/` and `REVIEW_PACKET_Master.md` | score, closeout status, artifact hygiene result, secret-shape result |
| `weekly-governance-feedback-report` | `feedback_reports/` and `REVIEW_PACKET_Master.md` when recommendations are acted on | 12D assessment, issues, recommendations, Human-confirmation boundary |
| `codex-system-governance-auditor` | `REVIEW_PACKET_Master.md` for L1-level audits | findings, assets updated, validation summary |
| `executor-preflight-check` | executor health report or Review Packet | executor availability JSON and recommendation |

## Open Implementation Notes

- These skills are proposed L1 governance skills, not proof that corresponding executable skills already exist.
- Before installing or invoking external skills, verify current Codex skill/plugin state using local truth sources.
- Keep installation Codex-first unless another toolchain is explicitly requested.
- The L1 binding files under `已有可复用/` summarize local skills that were read during integration; they are not a substitute for runtime skill verification.
