# human-evidence-intake-check

## Priority

High

## Purpose

Validate a Human Operator masked evidence submission before any real go/no-go decision is refreshed.

## Trigger Conditions

Run this skill when:

- a Human Operator fills or updates a masked evidence `.md` file.
- Evidence Gate rows change from `present=no` to `present=yes`.
- `submitted_by`, `submitted_at`, or `verified_environment` changes.
- Revenue work depends on newly submitted masked evidence.

## Inputs

- Evidence `.md` file, such as `Projects/<project>/当前状态/当前_Evidence_Gate_状态.md`.
- Optional masked evidence artifact index.
- Optional validator command output.

## Core Validator

Preferred project validator:

```powershell
node .ai\validate-tianji-love-masked-evidence.mjs --file <masked-evidence-file>
```

If the validator is missing, record `validator_missing` and do not advance to `real_go`.

## Outputs

- validator summary
- missing field list
- row completeness summary
- secret-shape safety note
- recommendation on whether the submission can enter orchestrator review

## Non-Authority Boundary

This skill does not make the final `real_go` decision. It only determines whether evidence is complete enough to be consumed by `orchestrator-decision-refresh`.

## Required Checks

| Check | Pass condition |
| --- | --- |
| `submitted_by` | real Human Operator, not `todo` |
| `submitted_at` | present |
| `verified_environment` | local, staging, test, sandbox, or production |
| evidence rows | each required row has `present=yes/no` |
| masked artifacts | required `present=yes` rows link to masked artifacts |
| secret safety | no raw secrets or provider/payment values |

## Compliance Constraints

- Do not change `submitted_by`.
- Do not change `present=no` to `present=yes`.
- Do not infer a real operator from chat history.
- Do not read `.env` files or raw provider/payment material.
- Do not output raw secrets even if discovered.

## Key Files

- `Codex_L1_Governance/02_Gate_System/Evidence_Gate/Evidence_Human_Operator_填写模板.md`
- `Codex_L1_Governance/Projects/<project>/当前状态/当前_Evidence_Gate_状态.md`
- `.ai/validate-tianji-love-masked-evidence.mjs` when present in the target project
