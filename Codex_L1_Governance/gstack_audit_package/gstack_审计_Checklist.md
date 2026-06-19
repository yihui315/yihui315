# gstack Audit Checklist

## Document Checklist

| Check | Expected result | Status |
| --- | --- | --- |
| Audit package has a current version | `gstack-audit-package-v1.7` | pending auditor review |
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
| GitHub Actions or cron example exists | schedule example only unless enabled by maintainer | implemented as inactive example |
| Notification support exists | real send requires explicit switch and URL at runtime | verified locally |
| Automation output is recorded | `REVIEW_PACKET_Master.md` and generated reports | verified locally |

## Auditor Decision Prompt

The auditor should decide whether L1 governance is ready as a governance system. The auditor should not infer downstream project launch, revenue, payment, or execution readiness.
