# Skill Registry

## Registry Status

| Skill | Type | Status | Current maturity | Script support | Owner | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `Evidence_Validator` | L1 governance | proposed | 5/10 | no dedicated script | Codex | Covered by evidence templates and trigger rules |
| `Revenue_Gate_Checker` | L1 governance | proposed | 5/10 | no dedicated script | Codex | Covered by revenue gate template and tianji binding |
| `Gate_Decision_Refresh` | L1 governance | proposed | 6/10 | no dedicated script | Codex | Canonical decision schema exists |
| `12D_Baseline_Scan` | L1 governance | proposed | 7/10 | manual report generation | Codex | Two baseline reports exist |
| `Failure_Case_Recorder` | L1 governance | proposed | 7/10 | no dedicated script | Codex | Template, index, and first case exist |
| `Review_Packet_Scorer` | L1 governance | proposed | 6/10 | no dedicated script | Codex | Scoring fields and dashboard template exist |
| `Secret_Shape_Scan` | validation helper | proposed | 6/10 | command pattern only | Codex | Manual `rg` scan currently used |
| `weekly-governance-health-check` | validation helper | active | 9/10 | `scripts/weekly-governance-health-check.ps1` | Codex | Orchestrates closeout, artifact hygiene, secret-shape scan, and Slack/generic webhook notification with explicit enable switch |
| `weekly-governance-health-schedule` | automation example | documented | 7/10 | `automation_examples/github-actions-weekly-governance-health.yml` | Codex | Inactive schedule example only; not installed under `.github/workflows/` |
| `human-evidence-intake-check` | L1 governance | active | 8/10 | `scripts/human-evidence-intake-check.ps1` | Codex | Read-only intake script verified; current ai占卜.ai evidence remains blocked |
| `orchestrator-decision-refresh` | L1 governance | proposed | 7/10 | no dedicated script | Codex | Auto-closeout rule documented |
| `governance-artifact-hygiene` | L1 governance | active | 8/10 | `scripts/governance-artifact-hygiene.ps1` | Codex | Read-only dry-run script verified; no archive/delete execution by default |
| `round-closeout-validator` | L1 governance | proposed | 8/10 | `scripts/round-closeout-validator.ps1` | Codex | Read-only script verified with `closeout_status=pass` |
| `codex-system-governance-auditor` | existing local skill | observed-local | 8/10 | local skill file observed | Codex | L1 summary and integration points exist |
| `executor-preflight-check` | existing local skill | observed-local | 7/10 | local skill file observed | Codex | Passing preflight is not Execution Go |
| `tianji-revenue-gate` | existing local skill | observed-local | 8/10 | local skill file observed | Codex | L1 binding requires reading orchestrator verdict before revenue work |

## Registration Rules

- `proposed`: documented trigger exists, implementation not yet confirmed.
- `observed-local`: a local skill file was read and summarized into the L1 registry, but this registry does not by itself prove runtime invocation.
- `active`: executable skill/script exists and has been verified in the current environment.
- `deprecated`: no longer used, retained for history.

## Promotion Checklist

Before changing a skill from `proposed` to `active`:

- verify the skill exists locally or in the approved plugin set.
- record the command or tool used for verification.
- run a small dry run.
- update this registry with the verification date.
- document known limitations.
