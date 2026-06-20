# L1 Governance gstack Audit Material List

## Purpose

This document lists the materials that should be reviewed during a formal gstack audit of `Codex_L1_Governance`.

Audit scope:

- in scope: L1 governance system, documentation, scripts, review records, audit package, and pilot adoption records
- out of scope: project execution approval, payment/provider readiness, production launch readiness

## Required Materials

| Category | Material | Location | Review purpose |
| --- | --- | --- | --- |
| Entry point | Audit package index | `00_审计材料索引.md` | Confirm package version and review order |
| Architecture | L1 overview | `L1_Governance_Overview.md` | Understand governance control plane |
| Rules | Mandatory L1 rules | `AGENTS.md` | Check fail-closed and script rules |
| Navigation | L1 root index | `INDEX.md` | Confirm source layout and links |
| Skills | Skill list | `核心_Skill_列表.md` | Check status, maturity, and script support |
| Scripts | Core script manual | `核心脚本使用手册.md` | Verify commands and blocked behavior |
| Weekly health | Report guide | `Weekly_Health_Check_报告解读指南.md` | Interpret pass/blocked correctly |
| Maturity | Gap analysis | `L1_成熟度与差距分析.md` | Review strengths and remaining risks |
| Multi-project | Governance framework | `L1_Multi_Project_Governance_Framework.md` | Review project onboarding model |
| Evidence | ai占卜.ai pilot report | `../Projects/ai占卜.ai/当前状态/L1_试点接入报告_2026-06-20.md` | Confirm blocked-but-connected pilot state |
| Human Operator | Evidence completion guide | `../Projects/ai占卜.ai/当前状态/Evidence_补齐指南.md` | Check that missing evidence is handled honestly |
| Master log | L1 review packet | `../REVIEW_PACKET_Master.md` | Confirm durable audit trail |
| Changes | Changelog | `../CHANGELOG.md` | Confirm versioned changes |

## Additional v1.7 Materials

| Category | Material | Location | Review purpose |
| --- | --- | --- | --- |
| Notification | Webhook config example | `webhook_config_example.md` | Confirm runtime-only webhook secret handling |
| Automation | Inactive GitHub Actions example | `automation_examples/github-actions-weekly-governance-health.yml` | Confirm schedule path without enabling CI by default |

## Additional v1.8 Materials

| Category | Material | Location | Review purpose |
| --- | --- | --- | --- |
| Automation | Active weekly governance workflow | `../.github/workflows/weekly-governance-health-check.yml` | Confirm scheduled health and feedback generation |
| Self-evolution | Architecture and roadmap | `../self_evolution/L1_Self_Run_Self_Evolution_Architecture.md` | Review execution, feedback, and evolution boundaries |
| Feedback | Markdown template | `../self_evolution/templates/Weekly_Governance_Feedback_Template.md` | Check human-readable feedback shape |
| Feedback | JSON template | `../self_evolution/templates/Weekly_Governance_Feedback_Template.json` | Check machine-readable feedback shape |
| Feedback | Feedback generator | `../scripts/generate-weekly-feedback-report.ps1` | Confirm health-to-feedback conversion |
| Pilot | ai占卜.ai closed-loop report | `../Projects/ai占卜.ai/当前状态/AI_Divination_L1_Closed_Loop_Run_Report_2026-06-20.md` | Confirm project loop remains fail-closed |

## Verified Script Materials

| Script | Package copy | Source copy | Latest report |
| --- | --- | --- | --- |
| `human-evidence-intake-check.ps1` | `已验证脚本/human-evidence-intake-check.ps1` | `../scripts/human-evidence-intake-check.ps1` | `../evidence_intake_reports/Evidence_Intake_Report_2026-06-20.md` |
| `round-closeout-validator.ps1` | `已验证脚本/round-closeout-validator.ps1` | `../scripts/round-closeout-validator.ps1` | captured inside weekly report |
| `governance-artifact-hygiene.ps1` | `已验证脚本/governance-artifact-hygiene.ps1` | `../scripts/governance-artifact-hygiene.ps1` | `../artifact_hygiene_reports/Archive_Plan_2026-06-20.md` |
| `weekly-governance-health-check.ps1` | `已验证脚本/weekly-governance-health-check.ps1` | `../scripts/weekly-governance-health-check.ps1` | `../weekly_health_reports/Weekly_Governance_Health_2026-06-20.md` |

## Additional v1.8 Script Material

| Script | Source copy | Latest report |
| --- | --- | --- |
| `generate-weekly-feedback-report.ps1` | `../scripts/generate-weekly-feedback-report.ps1` | `../feedback_reports/Weekly_Governance_Feedback_2026-06-20.md` |

## Required Audit Checks

1. Confirm `gstack-audit-package-v1.8` is the current package version.
2. Confirm the package does not claim project `execution_go=true`.
3. Confirm ai占卜.ai remains `no_go` with Evidence and Revenue blocked.
4. Confirm scripts are read-only or dry-run by default.
5. Confirm webhook URLs are runtime-only and not committed.
6. Confirm evidence intake fails closed when Human Operator evidence is missing.
7. Confirm weekly health pass is not treated as project readiness.
8. Confirm multi-project governance requires project-specific evidence.

Additional v1.8 audit checks:

- Confirm the active GitHub Actions workflow commits generated reports only under `weekly_health_reports/` and `feedback_reports/`.
- Confirm structured feedback reports are advisory and require Human approval before L1 changes.

## Current Formal Audit Position

`Codex_L1_Governance` is ready for a formal governance-system audit. It is not claiming production or revenue readiness for downstream projects.
