# Skill: human-evidence-intake-check

## Priority

High

## Status And Authority

- status: proposed L1 governance skill
- authority: intake validation only
- not allowed: final `real_go` or gate pass decision

## Trigger Conditions

- A Human Operator submits or updates masked evidence.
- `submitted_by`, `submitted_at`, `verified_environment`, or evidence rows change.
- Evidence rows are proposed to change from `present=no` to `present=yes`.
- Revenue work depends on newly submitted masked evidence.

## Inputs

- Evidence Markdown file.
- Masked artifact references.
- Optional validator output.
- Optional current gate decision summary.

## Outputs

- validator summary
- missing field list
- row completeness summary
- secret-shape safety note
- recommendation on whether evidence can enter `orchestrator-decision-refresh`

## Error Handling

- If the evidence file is missing, return `blocked: evidence_file_missing`.
- If `submitted_by` is `todo`, blank, or synthetic, return `blocked: submitted_by_missing`.
- If required rows are absent, return `blocked: evidence_rows_incomplete`.
- If the project validator is missing, return `blocked: validator_missing`.
- If secret-shaped material is detected, stop and mark `blocked: possible_secret_exposure`.

## Compliance Constraints

- Do not change `submitted_by`.
- Do not change `present=no` to `present=yes`.
- Do not infer a Human Operator identity from chat history.
- Do not read `.env` files, provider keys, payment secrets, or raw production credentials.
- Do not output raw secrets even if discovered.

## Integration Points

- `Codex_L1_Governance/02_Gate_System/Evidence_Gate/Evidence_Human_Operator_填写模板.md`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/orchestrator-decision-refresh.md`
- `.ai/validate-tianji-love-masked-evidence.mjs` when present in a target project

## Post-Run Required Records

- Append a brief result to the relevant project Review Packet.
- If L1 behavior changed, update `Codex_L1_Governance/REVIEW_PACKET_Master.md`.
- If a repeated blocker is found, update `Codex_L1_Governance/03_失败案例库/00_案例索引.md`.
