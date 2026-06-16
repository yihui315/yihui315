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

## Registration Rules

- `proposed`: documented trigger exists, implementation not yet confirmed.
- `active`: executable skill/script exists and has been verified in the current environment.
- `deprecated`: no longer used, retained for history.

## Promotion Checklist

Before changing a skill from `proposed` to `active`:

- verify the skill exists locally or in the approved plugin set.
- record the command or tool used for verification.
- run a small dry run.
- update this registry with the verification date.
- document known limitations.
