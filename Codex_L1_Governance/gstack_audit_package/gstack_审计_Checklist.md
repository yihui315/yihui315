# gstack Audit Checklist

## Document Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| Audit package has a current version | `gstack-audit-package-v2.0` | pending auditor review |
| Package index lists all core materials | overview, scripts, checklist, Q&A, maturity, multi-project framework | pending auditor review |
| L1 overview explains control-plane boundary | L1 does not grant project execution approval | pending auditor review |
| Maturity analysis lists strengths and risks | 10/10 is not claimed | pending auditor review |
| Multi-project framework exists | onboarding and inheritance rules are documented | pending auditor review |

## Script Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| `human-evidence-intake-check.ps1` exists | read-only intake validation | verified locally |
| `round-closeout-validator.ps1` exists | read-only closeout validation | verified locally |
| `governance-artifact-hygiene.ps1` exists | dry-run archive planning | verified locally |
| `weekly-governance-health-check.ps1` exists | combined weekly report | verified locally |
| `generate-weekly-feedback-report.ps1` exists | structured feedback Markdown/JSON generation | verified locally |
| `reflect-l1-governance-loop.ps1` exists | strict advisory reflection JSON/Markdown generation | verified locally |
| `update-l1-loop-state.ps1` exists | stopping-condition state update for `L1_State.json` | verified locally |
| `reflect-and-improve.ps1` exists | advisory Codex improvement suggestions | verified locally |
| `generate-l1-observability-dashboard.ps1` exists | unified read-only observability dashboard | verified locally |
| Weekly script supports notification | Slack/generic webhook, disabled or dry-run by default | verified locally |
| Webhook secrets are not committed | only placeholders and host names are recorded | verified locally |

## Pilot Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| ai占卜.ai has L1 rule reference | `L1_规则引用.md` exists | verified locally |
| ai占卜.ai has pilot report | current report exists | verified locally |
| Evidence completion guide exists | Human Operator instructions exist | verified locally |
| Evidence intake remains honest | current result is `blocked` | verified locally |
| Project decision remains fail-closed | `no_go`, `execution_go=false` | verified locally |

## Compliance Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| No Human Operator evidence is fabricated | `submitted_by` remains missing until real submission | verified locally |
| No `present=no` rows are converted without evidence | 10 rows remain no until real artifacts exist | verified locally |
| No raw secrets are included | secret-shape scan result is `0` | verified locally |
| `.env` files are not read or committed | scripts treat env-like files as blockers | verified locally |
| Approval remains plan-only | no project execution approval claimed | verified locally |

## Automation Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| Weekly report exists | `Weekly_Governance_Health_2026-06-20.md` | verified locally |
| Active GitHub Actions workflow exists | weekly workflow runs health, feedback, and report commit steps | YAML parse ok locally; pending first GitHub run |
| GitHub Actions or cron example exists | inactive example remains available for reference | implemented as inactive example |
| Notification support exists | real send requires explicit switch and URL at runtime | verified locally |
| Automation output is recorded | `REVIEW_PACKET_Master.md` and generated reports | verified locally |
| Reflector reports are generated | `reflection_reports/L1_Reflection_YYYY-MM-DD.md/.json` | verified locally |
| Improvement reports are generated | `improvement_reports/L1_Codex_Improvement_YYYY-MM-DD.md/.json` | verified locally |
| Observability dashboard exists | `L1_Observability_Dashboard.md` and `observability_reports/` | verified locally |
| L1 state is controlled | `L1_State.json` tracks iterations, score, execution_go, estimated cost, and stop reason | verified locally |
| Executor is not workflow-automatic | no workflow step triggers Executor after reflection; safe-auto remains local, scoped, and blocked by `should_stop=true` | verified locally |

## Sub-Agent Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| HealthChecker definition exists | `.codex/agents/healthchecker.md` | verified locally |
| Reflector definition exists | `.codex/agents/reflector.md` with required JSON contract | verified locally |
| Executor definition exists | `.codex/agents/executor.md` with safe-auto classification, Human-required boundaries, and `should_stop=false` preflight | verified locally |
| Agent boundaries are fail-closed | no agent may alter evidence, gates, revenue, or execution readiness without Human approval | verified locally |

## Stopping-Condition Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| Cost limit has highest priority | `cost_limit_reached` wins over other stop reasons | verified locally |
| Max iteration stop exists | iteration `>= 5` triggers `max_iterations_reached` | verified locally |
| No-progress stop exists | two consecutive non-improving loops trigger `no_progress` | verified locally |
| Repeated failure category stop exists | two repeated failure categories trigger `repeated_failure_category` after higher-priority checks | verified locally |
| Repeated failure threshold is configurable | `repeated_failure_threshold` exists in state/updater | verified locally |
| Stop reset is manual-only | `update-l1-loop-state.ps1 -ResetStop` requires Human confirmation and does not approve Executor | verified locally |

## Observability Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| Dashboard summarizes health | health status, score, secret hits | verified locally |
| Dashboard summarizes stop state | `should_stop`, `stop_reason`, failure category | verified locally |
| Dashboard summarizes evidence intake | `blocked`, `present_yes=0`, `present_no=10` while evidence is missing | verified locally |
| Dashboard summarizes pilot status | ai占卜.ai remains `no_go`, `execution_go=false` | verified locally |

## Auditor Decision Prompt

The auditor should decide whether L1 governance is ready as a governance system. The auditor should not infer downstream project launch, revenue, payment, or execution readiness.
