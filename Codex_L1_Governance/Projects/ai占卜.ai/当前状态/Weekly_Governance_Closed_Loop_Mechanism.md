# ai占卜.ai Weekly Governance Closed Loop Mechanism

## Purpose

This file records how the ai占卜.ai pilot uses the L1 self-run and feedback loop.

The mechanism connects the project to L1 governance checks, but it does not change project gate state.

## Weekly Cadence

| Step | Tool or file | Result |
| --- | --- | --- |
| 1. Evidence status review | `当前_Evidence_Gate_状态.md` | Confirms Human Operator evidence state |
| 2. Evidence intake check | `scripts/human-evidence-intake-check.ps1` | Returns `blocked` until real evidence exists |
| 3. Weekly health check | `.github/workflows/weekly-governance-health-check.yml` | Generates L1 weekly health reports |
| 4. Feedback generation | `scripts/generate-weekly-feedback-report.ps1` | Generates structured improvement recommendations |
| 5. Reflector report | `scripts/reflect-l1-governance-loop.ps1` | Generates advisory root-cause analysis |
| 6. L1 state update | `scripts/update-l1-loop-state.ps1` | Applies stop conditions to `L1_State.json` |
| 7. Human review | `Evidence_补齐指南.md` and project report | Human confirms evidence or keeps blockers |
| 8. Decision refresh | `orchestrator-decision-refresh` rule | Only after real evidence changes |

## Current Pilot State

- project status: `connected_with_blockers`
- current decision: `no_go`
- execution_go: `false`
- Evidence Gate: `blocked`
- Revenue Gate: `blocked`
- Approval Gate: `pass plan-only`

## Human Evidence Path

1. Human Operator completes `当前_Evidence_Gate_状态.md`.
2. Each `present=yes` row must include a masked artifact path or link.
3. Human Operator runs the command in `Human_Evidence_Intake_Check_调用示例.md`.
4. If intake remains `blocked`, the project remains `no_go`.
5. If intake becomes non-blocked, the project proceeds to orchestrator review; it still does not auto-pass.

## Feedback Improvement Path

1. Weekly Health Check generates health reports.
2. Feedback generator creates Markdown and JSON recommendations.
3. Reflector creates advisory root-cause JSON/Markdown.
4. State updater records stop conditions in `L1_State.json`.
5. Codex reviews recurring recommendations.
6. Human reviewer approves any L1 rule/script/project-record change.
7. Project gates remain fail-closed unless project-specific evidence changes.

## P2 Boundary

The P2 goal to make project `execution_go=true` was not executed.

No Revenue/Evidence MVP was built, no real user behavior was collected, and no gate was upgraded.

## Compliance Boundary

- This mechanism is governance-only.
- It does not fabricate `submitted_by`.
- It does not change `present=no` rows.
- It does not approve Revenue, Execution, payment, provider, or production readiness.
