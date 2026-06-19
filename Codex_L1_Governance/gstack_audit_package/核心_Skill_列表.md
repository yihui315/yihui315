# Core Skill List For gstack Audit

## Summary

This file summarizes the L1 Skill chain currently documented for audit. Status is intentionally conservative and follows `Skill_Registry.md`.

## Reviewer Checklist

- Check whether each Skill status is supported by evidence, not assumption.
- Confirm script-backed claims point to an included or referenced script.
- Confirm `proposed` Skills are not described as runtime-active.
- Confirm revenue or execution work remains blocked unless final project-level gate evidence exists.

## High Priority Chain

| Skill | Current status | Maturity | Script support | Audit note |
| --- | --- | --- | --- | --- |
| `human-evidence-intake-check` | active | 8/10 | `scripts/human-evidence-intake-check.ps1` | Read-only intake validation verified; current ai占卜.ai evidence correctly remains blocked. |
| `orchestrator-decision-refresh` | proposed | 7/10 | no dedicated script | Decision refresh contract is documented and now requires round closeout after completion. |
| `tianji-revenue-gate` | observed-local | 8/10 | local skill file observed | Revenue work must read final orchestrator verdict before proceeding. |

## Medium Priority Chain

| Skill | Current status | Maturity | Script support | Audit note |
| --- | --- | --- | --- | --- |
| `governance-artifact-hygiene` | active | 8/10 | `scripts/governance-artifact-hygiene.ps1` | Read-only dry-run archive planner verified; no delete/archive execution by default. |
| `round-closeout-validator` | proposed | 8/10 | `scripts/round-closeout-validator.ps1` | Read-only script verified and included in this package. |
| `weekly-governance-health-check` | active | 9/10 | `scripts/weekly-governance-health-check.ps1` | Orchestrates closeout, artifact hygiene, secret-shape scan, and Slack/generic webhook notification with explicit enable switch. |

## Supporting Reusable Skills

| Skill | Current status | Maturity | Script support | Audit note |
| --- | --- | --- | --- | --- |
| `codex-system-governance-auditor` | observed-local | 8/10 | local skill file observed | Used for governance audits, durable artifact design, and evidence-first review. |
| `executor-preflight-check` | observed-local | 7/10 | local skill file observed | Passing preflight is explicitly not Execution Go. |

## Current Execution Chain

`Human Evidence -> human-evidence-intake-check -> State Sync -> orchestrator-decision-refresh -> round-closeout-validator -> REVIEW_PACKET_Master`

## Script-Backed Evidence

| Evidence | Location | Status |
| --- | --- | --- |
| Human evidence intake script | `已验证脚本/human-evidence-intake-check.ps1` | Included in audit package |
| Closeout validation script | `已验证脚本/round-closeout-validator.ps1` | Included in audit package |
| Artifact hygiene script | `已验证脚本/governance-artifact-hygiene.ps1` | Included in audit package |
| Weekly health script | `已验证脚本/weekly-governance-health-check.ps1` | Included in audit package |
| Artifact hygiene dry-run example | `00_审计材料索引.md` | Documented in v1.3 package |
| Blocked protection table | `00_审计材料索引.md` | Documented in v1.3 package |
| Closeout validation record | `REVIEW_PACKET_Master.md` in source L1 directory | Recorded as documentation-scope pass |
| Secret-shape scan result | `REVIEW_PACKET_Master.md` in source L1 directory | Recorded as `secret_shape_hits=0` |

## Additional v1.7 Evidence

| Evidence | Location | Status |
| --- | --- | --- |
| Webhook config example | `webhook_config_example.md` | Runtime-only URL pattern documented |
| Inactive schedule example | `automation_examples/github-actions-weekly-governance-health.yml` | Included but not enabled as CI |

## Audit Boundaries

- `proposed` means documented but not fully promoted as a runtime-active Skill.
- `observed-local` means a local Skill file was observed and summarized, but this package does not prove plugin/runtime invocation.
- `round-closeout-validator` has script support, but the Skill registry remains conservative until active promotion is formally recorded.
- No Skill may fabricate evidence, secrets, payment readiness, or gate state.

## Recommended Next Promotion Steps

1. Promote `round-closeout-validator` only after the active promotion checklist is accepted by the maintainer.
2. Add read-only script support for secret-shape scan and decision refresh validation.
3. Add a repeatable local or CI job for secret-shape scan, artifact hygiene, and closeout validation.
4. Record every promotion in `Skill_Registry.md`, `REVIEW_PACKET_Master.md`, and `CHANGELOG.md`.
