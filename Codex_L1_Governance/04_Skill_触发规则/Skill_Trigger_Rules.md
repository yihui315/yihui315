# Skill Trigger Rules

## Purpose

This file defines proposed L1 skill triggers. These are governance rules first; implementation as Codex skills can happen later.

## Trigger Table

| Skill name | Trigger condition | Required input | Required output | Related gate |
| --- | --- | --- | --- | --- |
| `Evidence_Validator` | Evidence Gate needs refresh or a Human Operator submission was added | filled `submitted_by`, `submitted_at`, evidence rows, masked artifact references | structured evidence validation report | Evidence |
| `Revenue_Gate_Checker` | Pricing, checkout, payment, webhook, or entitlement readiness is claimed | masked revenue artifacts, environment, provider mode | revenue gate readiness report | Revenue |
| `Gate_Decision_Refresh` | Any gate status, blocker count, or approval scope changes | latest gate state JSON and validation results | updated canonical decision JSON | All gates |
| `12D_Baseline_Scan` | New project onboarding, major governance review, or monthly baseline | project path, source list, current gate decision | 12D scorecard and improvement checklist | All gates |
| `Failure_Case_Recorder` | A blocker repeats, a gate cannot advance, or a compliance refusal occurs | incident summary, related files, attempted actions | failure case entry and index update | All gates |
| `Review_Packet_Scorer` | A review packet is created or refreshed | project review packet, gate decision, 12D scan | quantitative score section and trend notes | All gates |
| `Secret_Shape_Scan` | Evidence or revenue artifacts are added | target paths and masking policy | secret-shape result with hit count | Evidence, Revenue |

## Trigger Rules

1. Prefer a specific gate skill over a generic review when a gate status may change.
2. Run `Secret_Shape_Scan` before treating evidence artifacts as reviewable.
3. Run `Gate_Decision_Refresh` after, not before, validators have produced results.
4. Run `Failure_Case_Recorder` whenever the correct outcome is blocked because of a compliance boundary.
5. Do not let a skill mark `go` unless the required gate evidence exists.

## Open Implementation Notes

- These skills are proposed L1 governance skills, not proof that corresponding executable skills already exist.
- Before installing or invoking external skills, verify current Codex skill/plugin state using local truth sources.
- Keep installation Codex-first unless another toolchain is explicitly requested.
