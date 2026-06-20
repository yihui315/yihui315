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
- Keep row notes concrete: include what was verified, where the masked artifact lives, and whether it was local/staging/test/sandbox/production.
- If a claim cannot be verified, leave the row as `present=no` and explain the blocker in `Notes`.

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

## Evidence Completion Priority

Use this priority order to avoid low-value evidence churn:

| Priority | Item | Reason |
| --- | --- | --- |
| P0 | Fill real Human Operator fields | No evidence package can proceed while operator metadata remains `todo` |
| P0 | Add one masked artifact for the most important user/revenue signal | Revenue and Evidence gates need real artifacts, not governance claims |
| P1 | Add validator or screenshot evidence for the core flow | Helps decision refresh review without exposing secrets |
| P1 | Add environment-specific verification scope | Prevents local/staging/production confusion |
| P2 | Add remaining lower-priority rows | Only after P0/P1 artifacts exist |

Rows must stay `present=no` until the corresponding masked artifact exists.

## Completion Checklist

- [ ] Real Human Operator filled `submitted_by`.
- [ ] Real role filled in `role`.
- [ ] Real timestamp filled in `submitted_at`.
- [ ] Environment selected in `verified_environment`.
- [ ] Verification scope describes what was personally checked.
- [ ] Every `present=yes` row has a masked artifact path or link.
- [ ] Every unresolved row remains `present=no`.
- [ ] No raw secrets, provider credentials, payment secrets, customer data, or `.env` contents were added.
- [ ] `human-evidence-intake-check.ps1` was rerun after updates.
- [ ] Result was recorded in the project report before any decision refresh.

## Reviewer Red Flags

- `submitted_by` is still `todo`.
- `present=yes` appears with `todo` evidence path.
- Evidence path points to `.env`, secret, provider, payment, or credential files.
- Evidence is described only in chat and not backed by a file or link.
- The operator claims production readiness without masked artifacts.

## Compliance Boundary

This guide is an intake template. It does not authorize Evidence Gate pass, Revenue Gate pass, or `execution_go=true`.
