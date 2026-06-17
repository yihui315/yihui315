# Skill: orchestrator-decision-refresh

## Priority

High

## Status And Authority

- status: proposed L1 governance skill
- authority: refresh sanitized decision artifacts from validator outputs
- not allowed: judging raw evidence truth or inventing gate pass states

## Trigger Conditions

- Evidence Gate changes.
- Revenue Gate changes.
- Approval Gate changes.
- Executor Gate changes.
- Environment Gate changes.
- `blocker_count` changes.
- approved scope changes.

## Inputs

- `ORCHESTRATOR_GATE_STATE.json`
- validator outputs
- sanitized gate summaries
- latest approval scope
- current blocker list

## Outputs

- refreshed `ORCHESTRATOR_GATE_DECISION.json`
- decision delta summary
- brief Review Packet record
- next smallest safe action
- automatic trigger note for `round-closeout-validator`

## Error Handling

- If gate state is missing, return `blocked: gate_state_missing`.
- If validator output is missing, do not upgrade any gate.
- If approval scope is `plan-only`, keep `execution_go=false`.
- If Evidence or Revenue is incomplete, keep the overall decision `no_go`.
- If secret-shaped material appears in sanitized inputs, stop and mark `blocked: possible_secret_exposure`.

## Compliance Constraints

- Consume validator outputs only.
- Do not inspect raw evidence, `.env`, provider keys, payment secrets, or production credentials.
- Do not convert documentation completeness into execution approval.
- Do not change `submitted_by` or evidence row truth values.

## Integration Points

- `Codex_L1_Governance/02_Gate_System/Gate_Decision_Canonical.json`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/human-evidence-intake-check.md`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/round-closeout-validator.md`
- `Codex_L1_Governance/REVIEW_PACKET_Master.md`

## Post-Run Required Records

- Update the relevant project Review Packet with the decision delta.
- Update `CHANGELOG.md` when durable governance files change.
- After the refresh finishes, run `round-closeout-validator` before starting the next governance round.
