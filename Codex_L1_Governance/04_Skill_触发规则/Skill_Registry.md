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
| `weekly-governance-health-schedule` | automation workflow | active | 8/10 | `.github/workflows/weekly-governance-health-check.yml` | Codex | Active scheduled workflow; commits generated health and feedback reports only |
| `weekly-governance-feedback-report` | validation helper | active | 8/10 | `scripts/generate-weekly-feedback-report.ps1` | Codex | Converts weekly health JSON into Markdown/JSON feedback and 12D recommendations |
| `l1-governance-reflector` | validation helper | active | 8/10 | `scripts/reflect-l1-governance-loop.ps1` | Codex | Converts health, feedback, and state into advisory reflection JSON/Markdown |
| `l1-loop-state-updater` | validation helper | active | 8/10 | `scripts/update-l1-loop-state.ps1` | Codex | Applies loop stopping conditions to `L1_State.json`; uses estimated cost only |
| `l1-reflect-and-improve` | validation helper | active | 8/10 | `scripts/reflect-and-improve.ps1` | Codex | Consolidates health, feedback, reflection, and state into advisory Codex improvement suggestions |
| `l1-observability-dashboard` | observability helper | active | 8/10 | `scripts/generate-l1-observability-dashboard.ps1` | Codex | Generates read-only dashboard across health, feedback, reflection, state, evidence intake, and pilot status |
| `HealthChecker` | sub-agent definition | documented | 7/10 | `.codex/agents/healthchecker.md` | Codex | Reads/runs L1 health checks and reports status; no gate mutation |
| `Reflector` | sub-agent definition | documented | 7/10 | `.codex/agents/reflector.md` | Codex | Produces strict reflection JSON plus Markdown; advisory only |
| `Executor` | sub-agent definition | documented | 7/10 | `.codex/agents/executor.md` | Codex | May execute only Human-confirmed recommendations and only when `should_stop=false` |
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
