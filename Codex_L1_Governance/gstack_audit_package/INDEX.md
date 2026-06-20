# Codex L1 Governance - Navigation Index

> This directory is the shared Codex L1 governance layer. Projects can reference these rules, templates, and skill definitions, but L1 records do not grant project execution approval by themselves.

## Core Entry Points

| File | Purpose | Priority |
| --- | --- | --- |
| [AGENTS.md](./05_Agent_与_Worker_边界/AGENTS.md) | Mandatory L1 operating rules | Critical |
| [REVIEW_PACKET_Master.md](./REVIEW_PACKET_Master.md) | Master governance record and audit log | Critical |
| [CHANGELOG.md](./CHANGELOG.md) | L1 change history | High |
| [INDEX.md](./INDEX.md) | This navigation file | High |

## Skill System

### High Priority Skills

| Skill | File | Main role | Trigger |
| --- | --- | --- | --- |
| `human-evidence-intake-check` | [definition](./04_Skill_触发规则/新建高优先级/human-evidence-intake-check.md) | Validate Human Operator masked evidence intake | Human Operator submits or updates masked evidence |
| `orchestrator-decision-refresh` | [definition](./04_Skill_触发规则/新建高优先级/orchestrator-decision-refresh.md) | Refresh decision after gate state changes | Evidence, Revenue, Approval, Executor, or Environment changes |
| `tianji-revenue-gate` | [binding](./04_Skill_触发规则/已有可复用/tianji-revenue-gate.md) | Revenue safety gate bound to final decision | Revenue-related work |

Core chain:

`Human Evidence -> human-evidence-intake-check -> State Sync -> orchestrator-decision-refresh -> Review Packet`

### Medium Priority Skills

| Skill | File | Main role | Trigger |
| --- | --- | --- | --- |
| `governance-artifact-hygiene` | [definition](./04_Skill_触发规则/新建高优先级/governance-artifact-hygiene.md) | Governance artifact archive and cleanup planning | Artifact growth or weekly health check |
| `round-closeout-validator` | [definition](./04_Skill_触发规则/新建高优先级/round-closeout-validator.md) | Validate round closeout completeness | Decision refresh or Self-Distillation round end |

Supporting files:

- [Skill_Trigger_Rules.md](./04_Skill_触发规则/Skill_Trigger_Rules.md)
- [Skill_Registry.md](./04_Skill_触发规则/Skill_Registry.md)
- [High Priority integration report](./04_Skill_触发规则/SKILL_INTEGRATION_REPORT_2026-06-16.md)
- [Medium Priority integration report](./04_Skill_触发规则/MEDIUM_SKILL_INTEGRATION_REPORT_2026-06-17.md)

## Automation Examples

- [Active weekly governance workflow](../.github/workflows/weekly-governance-health-check.yml)
- [Inactive weekly GitHub Actions example](./automation_examples/github-actions-weekly-governance-health.yml)
- Webhook runtime configuration is documented in the gstack audit package as `webhook_config_example.md`.
- Automation examples are not active until a maintainer explicitly installs them in a scheduler path.

## Self-Run And Self-Evolution

- [Architecture and roadmap](./self_evolution/L1_Self_Run_Self_Evolution_Architecture.md)
- [Feedback Markdown template](./self_evolution/templates/Weekly_Governance_Feedback_Template.md)
- [Feedback JSON template](./self_evolution/templates/Weekly_Governance_Feedback_Template.json)
- [Feedback generator script](./scripts/generate-weekly-feedback-report.ps1)
- [Reflector script](./scripts/reflect-l1-governance-loop.ps1)
- [State updater script](./scripts/update-l1-loop-state.ps1)
- [Codex improvement script](./scripts/reflect-and-improve.ps1)
- [Observability dashboard script](./scripts/generate-l1-observability-dashboard.ps1)
- [Latest observability dashboard](./L1_Observability_Dashboard.md)
- [Latest Executor safe-auto verification](./executor_safe_auto_reports/Executor_Safe_Auto_Verification_2026-06-20.md)
- [L1 loop state](./L1_State.json)
- Generated feedback reports live under `feedback_reports/`.
- Generated reflection reports live under `reflection_reports/`.
- Executor safe-auto verification reports live under `executor_safe_auto_reports/`.

Sub-agent definitions:

- [HealthChecker](../.codex/agents/healthchecker.md)
- [Reflector](../.codex/agents/reflector.md)
- [Executor](../.codex/agents/executor.md)

## Gate System

- [Canonical gate decision JSON](./02_Gate_System/Gate_Decision_Canonical.json)
- [Evidence Gate](./02_Gate_System/Evidence_Gate/Evidence_Gate_Template.md)
- [Human Operator evidence template](./02_Gate_System/Evidence_Gate/Evidence_Human_Operator_填写模板.md)
- [Revenue Gate](./02_Gate_System/Revenue_Gate/Revenue_Gate_Template.md)
- [Approval Gate](./02_Gate_System/Approval_Gate/Approval_Gate_Template.md)

Important rules:

- Execution-oriented skills must respect the final `ORCHESTRATOR_GATE_DECISION.json` verdict.
- Evidence operations must not fabricate `submitted_by` or convert `present=no` to `present=yes`.
- `plan-only` approval is not execution approval.

## 12D Scans

- [12D framework](./01_12维扫描引擎/12维扫描框架_v1.md)
- [12D baseline template](./01_12维扫描引擎/12维扫描基线模板.md)
- [Latest L1 baseline report](./01_12维扫描引擎/12维扫描结果归档/2026-06-17_L1_Layer_Baseline_Scan_Report.md)
- [10/10 push scan report](./01_12维扫描引擎/12维扫描结果归档/2026-06-17_L1_Layer_10_10_Push_Scan_Report.md)
- [Scan archive](./01_12维扫描引擎/12维扫描结果归档/)

Current L1 baseline:

- score: 8.6/10 after the 2026-06-17 10/10 push scan
- date: 2026-06-17
- next recommendation: add read-only `governance-artifact-hygiene.ps1`

## Current Maturity

| Area | Current state | Target for 10/10 |
| --- | --- | --- |
| Governance structure | Strong, navigable L1 structure with index, gates, skills, and reports | Fully indexed and script-backed |
| Skill chain | Documented High and Medium skills | Verified executable support for critical skills |
| Compliance | Strong written boundaries and secret-safety rules | Automated checks recorded after each round |
| Feedback loop | Review packet, changelog, and scan reports exist | Closeout validator blocks incomplete rounds |
| Automation | Dry-run and read-only automation planned | Read-only validators implemented and routinely run |

## 10/10 Gap Analysis

| Gap | Current score impact | Required improvement |
| --- | --- | --- |
| Runtime skill verification | Skills remain mostly `proposed` or `observed-local` | Add script support and record verification results |
| Closeout enforcement | Rounds can still be closed manually | Run `round-closeout-validator` every round |
| Artifact hygiene | Cleanup is planned but not executable | Add dry-run inventory and archive-plan commands |
| Trend tracking | One L1 baseline exists | Keep multiple scans and compare score deltas |
| gstack audit readiness | Evidence is organized but not fully scripted | Provide scripts, reports, and clean status evidence |

## Failure Case Library

- [Failure case index](./03_失败案例库/00_案例索引.md)
- [Failure case template](./03_失败案例库/Failure_Case_Template.md)
- [Cases directory](./03_失败案例库/Cases/)

Principle: important failures and compliance refusals must be recorded as structured cases.

## Agent And Worker Boundaries

- [Agent collaboration protocol](./05_Agent_与_Worker_边界/Agent_Collaboration_Protocol.md)
- [Sub-Agent roles](./05_Agent_与_Worker_边界/Sub-Agent_Roles.md)
- [Worker parallel strategy](./05_Agent_与_Worker_边界/Worker_Parallel_Strategy.md)
- [Mandatory L1 rules](./05_Agent_与_Worker_边界/AGENTS.md)

## Feedback And Scoring

- [Feedback loop mechanism](./06_反馈闭环_与_评分/Feedback_Loop_机制.md)
- [Review packet scoring fields](./06_反馈闭环_与_评分/REVIEW_PACKET_量化评分字段.md)

## Usage Guide

1. New projects should first read [AGENTS.md](./05_Agent_与_Worker_边界/AGENTS.md).
2. Evidence or Revenue flows must go through `human-evidence-intake-check` and `orchestrator-decision-refresh`.
3. Revenue work must read the final decision before proceeding.
4. Each round should end with `round-closeout-validator`.
5. Artifact cleanup must start with `governance-artifact-hygiene` in dry-run mode.
6. Weekly loop automation runs Health -> Feedback -> Reflect -> State Update.
7. Executor must not run non-read-only work when `L1_State.json.should_stop=true`; when clear, it may safe-auto only low-risk governance docs/templates/indexes/reports/descriptive metadata.
8. Use `L1_Observability_Dashboard.md` as the quick handoff view before audit or project review.

## Multi-Project Governance

- [L1_Multi_Project_Governance_Framework.md](./L1_Multi_Project_Governance_Framework.md) defines how projects adopt shared L1 rules.
- Projects should reference L1 rules rather than copying them into divergent local rule sets.
- Project-specific Evidence, Revenue, and Execution gates remain fail-closed until real evidence exists.
- Current pilot: `Projects/ai占卜.ai/当前状态/`, status `connected_with_blockers`.

Additional registration rules:

- Project registration must record inherited L1 controls, local evidence ownership, and the current fail-closed decision before any execution claim.
- Weekly automation now uses the active `.github/workflows/weekly-governance-health-check.yml`; the inactive example remains reference-only.

Minimum project onboarding files:

1. `L1_规则引用.md`
2. `当前_Evidence_Gate_状态.md`
3. `当前_Gate_Decision_摘要.md`
4. `L1_试点接入报告_YYYY-MM-DD.md`
5. `Evidence_补齐指南.md`
6. `Weekly_Health_Check_调用记录.md`

## Quick Start Guide

1. Read [AGENTS.md](./05_Agent_与_Worker_边界/AGENTS.md) for mandatory rules.
2. Use [Skill_Trigger_Rules.md](./04_Skill_触发规则/Skill_Trigger_Rules.md) to choose the right skill.
3. Check [Skill_Registry.md](./04_Skill_触发规则/Skill_Registry.md) before assuming a skill is executable.
4. For evidence or revenue, start with `human-evidence-intake-check`.
5. After any decision refresh, run `round-closeout-validator`.
6. Record durable changes in [REVIEW_PACKET_Master.md](./REVIEW_PACKET_Master.md) and [CHANGELOG.md](./CHANGELOG.md).

## Maintenance Rules

- When adding or changing a skill, update [Skill_Trigger_Rules.md](./04_Skill_触发规则/Skill_Trigger_Rules.md) and [Skill_Registry.md](./04_Skill_触发规则/Skill_Registry.md).
- Important L1 changes must update [REVIEW_PACKET_Master.md](./REVIEW_PACKET_Master.md) and [CHANGELOG.md](./CHANGELOG.md).
- Run a 12D scan after major governance structure changes.
- Do not treat this index as evidence of project readiness.

## Version Status

- current maturity: L1 10/10 push estimate 8.6/10
- latest gstack package: v2.0
- last updated: 2026-06-20
- contributors: Codex and Human Operator
