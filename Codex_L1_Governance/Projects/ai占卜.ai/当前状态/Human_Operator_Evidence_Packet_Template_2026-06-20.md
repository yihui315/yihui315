# Human Operator Evidence Packet Template 2026-06-20

## Purpose

Use this packet when a real Human Operator is ready to submit masked evidence for ai占卜.ai. This is a template only. Do not treat it as evidence until a real Human Operator fills it.

## Companion Guide

Before filling this packet, read:

- `Human_Operator_Evidence_Packet_Filling_Guide_2026-06-20.md`

The guide explains each field, acceptable examples, invalid examples, and the self-check process. It is instructional only; it does not submit evidence or change any Gate state.

## Operator Attestation

| Field | Value |
| --- | --- |
| submitted_by | `todo_real_human_operator` |
| role | `todo_role` |
| submitted_at | `todo_actual_timestamp` |
| verified_environment | `todo_local_staging_test_sandbox_or_production` |
| verification_scope | `todo_what_was_personally_verified` |

## Required Masking Rules

- Do not paste raw `.env` content.
- Do not paste provider keys, payment secrets, webhook secrets, production credentials, or customer private data.
- Use masked screenshots, redacted logs, public URLs, hashes, sanitized paths, or non-secret config-shape summaries.
- Keep every unresolved row as `present=no`.
- Set `present=yes` only after a real masked artifact exists and is linked.

## Evidence Candidate Rows

| Row ID | Evidence candidate | present | Masked artifact path/link | Human note |
| --- | --- | --- | --- | --- |
| EV-001 | Human Operator attestation packet | no | todo | Fill after real attestation |
| EV-002 | Manual publication proof packet | no | todo | Fill after one approved item is published |
| EV-003 | KPI row for published item | no | todo | Fill after real observation exists |
| EV-004 | Demand or revenue signal candidate | no | todo | Fill only with masked proof |

## Post-Submission Check

After the Human Operator updates the real evidence file, run:

```powershell
& .\Codex_L1_Governance\scripts\human-evidence-intake-check.ps1 `
  -EvidenceFile ".\Codex_L1_Governance\Projects\ai占卜.ai\当前状态\当前_Evidence_Gate_状态.md" `
  -Json
```

## Expected Result

- If any required operator field is still missing, result must remain `blocked`.
- If any `present=yes` row lacks a masked artifact path, result must remain `blocked`.
- A non-blocked intake result still does not automatically mean `execution_go=true`; it only enables decision-refresh review.

## Compliance Boundary

This template does not submit evidence, does not mark rows present, and does not change gate decisions.
