# Evidence Completion Guide For Human Operator

## Purpose

This guide tells the Human Operator how to complete the ai占卜.ai Evidence Gate without exposing secrets or fabricating readiness.

Current status:

- Evidence Gate: `blocked`
- Revenue Gate: `blocked`
- overall decision: `no_go`
- execution_go: `false`

## Required Human Operator Fields

Fill these fields in `当前_Evidence_Gate_状态.md` only after real verification:

| Field | Required value |
| --- | --- |
| `submitted_by` | Real Human Operator name or role identifier |
| `role` | Operator role, for example `Founder`, `QA`, `Ops`, or `Reviewer` |
| `submitted_at` | Actual submission timestamp |
| `verified_environment` | `local`, `staging`, `test`, `sandbox`, or `production` |
| `verification_scope` | What was personally verified |

Do not use `todo`, placeholder names, inferred identities, or chat-only claims.

## Evidence Row Rules

For each row:

- Set `present=yes` only when a real masked artifact exists.
- Keep `present=no` when evidence is missing.
- Provide a masked evidence path or link for every `present=yes` row.
- Do not paste raw secrets, production keys, provider tokens, payment credentials, customer data, or `.env` content.

## Masked Evidence Examples

Acceptable examples:

- masked validator output
- sanitized screenshot path
- redacted log excerpt
- non-secret config shape report
- test/sandbox verification summary

Not acceptable:

- raw `.env` file
- provider/payment secret
- production credential
- unmasked customer data
- verbal claim without artifact

## Required Command After Update

After the Human Operator fills the evidence file, run:

```powershell
& .\Codex_L1_Governance\scripts\human-evidence-intake-check.ps1 `
  -EvidenceFile ".\Codex_L1_Governance\Projects\ai占卜.ai\当前状态\当前_Evidence_Gate_状态.md" `
  -Json
```

Only if this no longer returns `blocked` should the project proceed to orchestrator decision refresh review.

## Current Missing Items

As of 2026-06-20:

- `submitted_by`
- `role`
- `submitted_at`
- `verified_environment`
- 10 evidence rows remain `present=no`

## Compliance Boundary

This guide is an intake template. It does not authorize Evidence Gate pass, Revenue Gate pass, or `execution_go=true`.
