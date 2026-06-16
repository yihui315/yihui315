# orchestrator-decision-refresh

## Priority

High

## Purpose

Refresh the orchestrator decision after a gate state change using only sanitized state and validator outputs.

## Trigger Conditions

Run this skill when any of these change:

- Evidence Gate
- Revenue Gate
- Approval Gate
- Executor Gate
- Environment Gate
- `blocker_count`
- approved scope

## Inputs

- `ORCHESTRATOR_GATE_STATE.json`
- validator outputs
- sanitized gate summaries
- latest approval scope
- current blocker list

## Outputs

- refreshed `ORCHESTRATOR_GATE_DECISION.json`
- brief Review Packet record
- decision delta summary
- next smallest safe action

## Non-Authority Boundary

This skill consumes validator output. It does not judge raw evidence truth, does not inspect raw secrets, and does not upgrade a gate without supporting validator evidence.

## Decision Rules

| Condition | Decision impact |
| --- | --- |
| Evidence missing or `submitted_by=todo` | keep Evidence blocked |
| Revenue evidence missing | keep Revenue blocked |
| Approval scope is `plan-only` | keep `execution_go=false` |
| validator output is missing | do not upgrade gate |
| any raw secret exposure is detected | set or keep `no_go` |

## Required Review Packet Record

```markdown
### Orchestrator Decision Refresh

- refreshed_at:
- source_state:
- validators_consumed:
- previous_decision:
- new_decision:
- execution_go:
- blocker_count:
- gate_changes:
- evidence_limitations:
- next_action:
```

## Key Files

- `ORCHESTRATOR_GATE_STATE.json`
- `ORCHESTRATOR_GATE_DECISION.json`
- `Codex_L1_Governance/02_Gate_System/Gate_Decision_Canonical.json`
- `Codex_L1_Governance/REVIEW_PACKET_Master.md`
