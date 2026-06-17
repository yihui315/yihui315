# Skill: round-closeout-validator

## Priority

Medium

## Status And Authority

- status: proposed L1 governance skill with read-only script support
- authority: closeout completeness validation
- not allowed: modifying gate state or declaring execution approval

## Trigger Conditions

- `orchestrator-decision-refresh` completes.
- Self-Distillation or governance work ends.
- Review Packet claims a round is complete.
- `AGENTS.md` weekly or periodic trigger requests closeout validation.

## Inputs

- latest Review Packet
- latest `ORCHESTRATOR_GATE_DECISION.json`
- latest `ORCHESTRATOR_GATE_STATE.json` when available
- `CHANGELOG.md`
- failure case index
- skill registry

## Outputs

- Round Closeout Report
- required artifact checklist
- missing closeout item list
- gate consistency result
- recommendation: Yes / Conditional / No for entering the next round

## Script Support

Read-only script path:

```text
Codex_L1_Governance/scripts/round-closeout-validator.ps1
```

## Error Handling

- If a required artifact is missing, return `closeout_status=blocked`.
- If decision JSON cannot parse, return `closeout_status=blocked`.
- If Review Packet and decision summary contradict each other, return `closeout_status=conditional`.
- If no failure-case index exists, return `closeout_status=conditional`.

## Compliance Constraints

- Do not modify gate state.
- Do not fabricate missing review records.
- Do not mark execution ready from documentation completeness alone.
- Do not inspect raw secrets, `.env`, provider keys, payment secrets, or production credentials.

## Integration Points

- `Codex_L1_Governance/scripts/round-closeout-validator.ps1`
- `Codex_L1_Governance/REVIEW_PACKET_Master.md`
- `Codex_L1_Governance/CHANGELOG.md`
- `Codex_L1_Governance/04_Skill_触发规则/Skill_Registry.md`

## Post-Run Required Records

- Append Round Closeout Report to the relevant Review Packet.
- Update `CHANGELOG.md` only when durable files changed.
- If closeout is blocked, create or update a failure case when the blocker is repeated or compliance-relevant.
