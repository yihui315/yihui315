# Skill: codex-system-governance-auditor

## Priority

High

## Status And Authority

- status: observed-local skill summary
- source: `C:\Users\Administrator\.agents\skills\codex-system-governance-auditor\SKILL.md`
- authority: governance audit and durable asset recommendation

## Trigger Conditions

- Codex workflow audit.
- Repeated workflow detection.
- Skill trigger cleanup.
- `AGENTS.md` consistency review.
- Failure ledger or project map work.
- Output quality and feedback loop diagnosis.

## Inputs

- L1 governance files.
- Review packets.
- Skill registry and trigger rules.
- Failure case index.
- sanitized status artifacts.

## Outputs

- governance findings
- candidate assets
- validation notes
- risk notes
- next actions

## Error Handling

- If live artifacts are missing, report them as missing instead of inferring state.
- If skill status cannot be verified, keep it `observed-local` or `proposed`.
- If evidence is stale, label it stale.

## Compliance Constraints

- Diagnose by evidence first.
- Do not create assets for one-off work.
- Do not promote a proposed skill to active without verification.
- Do not inspect raw secrets or `.env` files.

## Integration Points

- `Codex_L1_Governance/INDEX.md`
- `Codex_L1_Governance/REVIEW_PACKET_Master.md`
- `Codex_L1_Governance/04_Skill_触发规则/Skill_Registry.md`
- `Codex_L1_Governance/03_失败案例库/00_案例索引.md`

## Post-Run Required Records

- Record major audit outputs in `REVIEW_PACKET_Master.md`.
- Update `CHANGELOG.md` for durable L1 changes.
- Add repeated blockers to the failure case index.
