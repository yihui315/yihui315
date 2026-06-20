# Changelog

## 2026-06-20

- Added active `.github/workflows/weekly-governance-health-check.yml` for weekly L1 health and structured feedback report generation.
- Added `scripts/generate-weekly-feedback-report.ps1` with Markdown/JSON feedback output.
- Added `self_evolution/` architecture and feedback templates for the L1 self-run and self-evolution loop.
- Added `.codex/agents/healthchecker.md`, `.codex/agents/reflector.md`, and `.codex/agents/executor.md` for Loop Engineering sub-agent role boundaries.
- Added `Codex_L1_Governance/L1_State.json` as the controlled loop state and stopping-condition record.
- Added `scripts/reflect-l1-governance-loop.ps1` for advisory reflection JSON/Markdown reports.
- Added `scripts/update-l1-loop-state.ps1` for stop-condition state updates and scenario testing.
- Updated the weekly governance workflow to run Health -> Feedback -> Reflect -> State Update, then commit only generated reports/state.
- Updated `gstack_audit_package/` to v1.9 with Reflect, stopping conditions, sub-agent definitions, state schema, and script snapshots.
- Added `scripts/reflect-and-improve.ps1` and `scripts/generate-l1-observability-dashboard.ps1`.
- Enhanced weekly health, feedback, and state updater outputs with stop-state, Codex suggestions, repeated failure threshold, and manual reset support.
- Added `L1_Observability_Dashboard.md`, improvement reports, and observability reports.
- Updated `gstack_audit_package/` to v2.0 with final audit brief, observability, improvement suggestions, stop recovery, and script snapshots.
- Added ai占卜.ai closed-loop mechanism and run report while preserving `no_go`, `execution_go=false`, and blocked Evidence/Revenue status.
- Updated `gstack_audit_package/` to v1.8 with active automation and advisory feedback-loop materials.
- Updated `gstack_audit_package/` to v1.7 with a formal material list, gstack checklist, audit simulation Q&A, webhook config example, and inactive GitHub Actions weekly health example.
- Upgraded `weekly-governance-health-check.ps1` with Slack/generic webhook support, explicit `-EnableNotification`, dry-run default behavior, and host-only reporting.
- Expanded `L1_Multi_Project_Governance_Framework.md` with project registration flow and rule inheritance boundaries.
- Updated `AGENTS.md`, `Skill_Registry.md`, `INDEX.md`, and package snapshots for notification, scheduling, and multi-project audit readiness.
- Recorded ai占卜.ai Human Evidence intake invocation example while preserving `no_go`, `execution_go=false`, and blocked Evidence/Revenue status.

## 2026-06-16

- Created initial Codex L1 governance directory structure.
- Added 12D scan framework and baseline template.
- Added Evidence, Revenue, and Approval Gate templates.
- Added canonical gate decision JSON template.
- Added failure case template and first case: `FC-2026-06-15-001`.
- Added proposed Skill trigger rules and registry.
- Added Sub-Agent role definitions, Worker parallel strategy, and collaboration protocol.
- Added REVIEW_PACKET quantitative scoring fields and master review packet.
- Added reusable next-stage Codex execution prompt.
- Integrated ai占卜.ai as the first L1 pilot project with derived current-state files.
- Recorded missing historical source files for ai占卜.ai instead of fabricating migrated originals.
- Added first 12D baseline scan report for ai占卜.ai.
- Added L1 `AGENTS.md` mandatory gate-chain rules.
- Added high-priority `human-evidence-intake-check` and `orchestrator-decision-refresh` skill definitions.
- Added L1 reusable descriptions for `codex-system-governance-auditor`, `executor-preflight-check`, and `tianji-revenue-gate`.
- Bound `tianji-revenue-gate` to the final orchestrator decision before revenue work can proceed.
- Added Medium Priority `governance-artifact-hygiene` and `round-closeout-validator` skill definitions.
- Updated Skill trigger rules and registry for artifact hygiene and round closeout checks.
- Updated L1 `AGENTS.md` with periodic triggers for artifact hygiene and round closeout validation.
- Added L1 layer 12D baseline scan report for 2026-06-17.
- Recorded L1 baseline result in `REVIEW_PACKET_Master.md`.
- Added `INDEX.md` as the main L1 navigation entrypoint.
- Recorded L1 index creation in `REVIEW_PACKET_Master.md`.
- Standardized all L1 Skill files with inputs, outputs, error handling, compliance constraints, integration points, and post-run record locations.
- Added read-only `scripts/round-closeout-validator.ps1` and recorded a passing documentation-scope closeout result.
- Added L1 Health Dashboard template and latest secret-shape scan result to `REVIEW_PACKET_Master.md`.
- Updated `Skill_Registry.md` with current maturity and script support columns.
- Strengthened `AGENTS.md` with automation, validation-loop, and active-skill verification rules.
- Added 2026-06-17 L1 10/10 push scan report and execution summary.
- Updated `INDEX.md` and `REVIEW_PACKET_Master.md` with the 8.6/10 estimated maturity score and gstack audit readiness statement.
- Added `gstack_audit_package/` with an audit index, copied core L1 snapshots, a Skill status summary, the verified closeout script snapshot, and a governance-only readiness note.
- Reviewed and refined `gstack_audit_package/` with package version metadata, last-updated scope, a text architecture snapshot, a reviewer checklist, and an explicit audit readiness verdict.
- Added read-only `scripts/governance-artifact-hygiene.ps1`, generated `artifact_hygiene_reports/Archive_Plan_2026-06-17.md`, and promoted `governance-artifact-hygiene` to script-backed active status.
- Updated `gstack_audit_package/` to v1.2 with a `governance-artifact-hygiene.ps1` script snapshot and refreshed Skill/script coverage notes.
- Updated `gstack_audit_package/` to v1.3 with script usage examples, artifact hygiene dry-run guidance, and blocked protection documentation for both verified scripts.
- Added read-only `scripts/weekly-governance-health-check.ps1`, generated `weekly_health_reports/Weekly_Governance_Health_2026-06-19.md`, updated AGENTS weekly execution rules, and updated `gstack_audit_package/` to v1.4.
- Added read-only `scripts/human-evidence-intake-check.ps1`, generated `evidence_intake_reports/Evidence_Intake_Report_2026-06-19.md`, and updated `gstack_audit_package/` to v1.5 while preserving ai占卜.ai Evidence Gate as blocked.
- Added ai占卜.ai L1 pilot rule reference and adoption report, connecting the project to L1 controls while preserving `no_go` and blocked Evidence/Revenue gates.
- Updated `gstack_audit_package/` to v1.6 with L1 overview, core script manual, weekly report guide, maturity gap analysis, webhook dry-run documentation, and multi-project framework.
- Added 2026-06-20 ai占卜.ai pilot deepening records and Human Operator evidence completion guide while preserving blocked/no_go status.
