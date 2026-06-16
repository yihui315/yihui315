# Skill Registry

## Registry Status

| Skill | Type | Status | Owner | Notes |
| --- | --- | --- | --- | --- |
| `Evidence_Validator` | L1 governance | proposed | Codex | Validates Human Operator evidence rows |
| `Revenue_Gate_Checker` | L1 governance | proposed | Codex | Validates masked monetization readiness |
| `Gate_Decision_Refresh` | L1 governance | proposed | Codex | Updates canonical gate decision JSON |
| `12D_Baseline_Scan` | L1 governance | proposed | Codex | Produces cross-project 12D scorecard |
| `Failure_Case_Recorder` | L1 governance | proposed | Codex | Turns blocked attempts into reusable cases |
| `Review_Packet_Scorer` | L1 governance | proposed | Codex | Adds quantitative scoring to review packets |
| `Secret_Shape_Scan` | validation helper | proposed | Codex | Scans evidence artifacts for secret-like values |
| `human-evidence-intake-check` | L1 governance | proposed | Codex | High priority masked evidence intake validator wrapper |
| `orchestrator-decision-refresh` | L1 governance | proposed | Codex | High priority decision refresh after gate changes |
| `codex-system-governance-auditor` | existing local skill | observed-local | Codex | L1 description file added under `已有可复用/` |
| `executor-preflight-check` | existing local skill | observed-local | Codex | L1 description file added under `已有可复用/` |
| `tianji-revenue-gate` | existing local skill | observed-local | Codex | L1 binding requires reading orchestrator verdict before revenue work |

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
