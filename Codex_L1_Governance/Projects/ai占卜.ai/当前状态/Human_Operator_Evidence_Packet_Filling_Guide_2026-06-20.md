# Human Operator Evidence Packet Filling Guide + Examples 2026-06-20

## Purpose

This guide explains how a real Human Operator should fill `Human_Operator_Evidence_Packet_Template_2026-06-20.md` for ai-divination.

Current project state:

| Field | Current value |
| --- | --- |
| overall_decision | `no_go` |
| execution_go | `false` |
| human-evidence-intake-check | `blocked` |
| present_yes | `0` |
| present_no | `10` |

This guide is not evidence. It helps a Human Operator prepare evidence without exposing secrets or fabricating readiness.

## Filling Flow

1. Prepare materials:
   - Identify the exact environment verified: `local`, `staging`, `test`, `sandbox`, or `production`.
   - Collect only masked artifacts: public URLs, redacted screenshots, sanitized logs, KPI rows, hashes, or masked summaries.
   - Keep raw secrets, `.env`, payment/provider keys, customer private data, and webhook tokens out of all evidence.
2. Fill operator fields:
   - Fill `submitted_by`, `role`, `submitted_at`, `verified_environment`, and `verification_scope`.
   - Use real values only. Do not use `todo`, inferred identities, or chat-only claims.
3. Fill evidence candidate rows:
   - Keep `present=no` until a real masked artifact exists.
   - Use `present=yes` only when the artifact path/link is reviewable and masked.
4. Self-check:
   - Run through the Evidence Quality Checklist below.
   - Confirm there are no secrets or private data.
5. Submit for validation:
   - Run `human-evidence-intake-check.ps1` after updating the real evidence file.
   - A non-blocked intake result still does not mean `execution_go=true`; it only enables decision-refresh review.

## Field Guide

### `submitted_by`

Meaning: the real Human Operator submitting the evidence packet.

Format:

- Use a real name, team role, or stable operator identifier.
- Avoid personal data if not needed; a role identifier such as `Ops Reviewer A` is acceptable when the reviewer can trace it internally.
- Do not leave as `todo`.

Good Example:

```text
Ops Reviewer A
```

Bad Example:

```text
todo
```

Problem: `todo` is not a real submitter and keeps evidence intake blocked.

Common mistakes:

- Using `Codex` as the submitter for human evidence.
- Copying a name from chat without an actual Human Operator submission.
- Using a fake placeholder to make the gate pass.

Avoidance:

- Fill only after a real person has reviewed the evidence packet.

### `role`

Meaning: the capacity in which the Human Operator verified the evidence.

Format:

- Use a concise role such as `Founder`, `Ops`, `QA`, `Reviewer`, or `Marketing Operator`.
- Do not use vague values like `person`, `admin`, or `unknown`.

Good Example:

```text
Marketing Operator
```

Bad Example:

```text
admin maybe
```

Problem: unclear role makes the verification chain hard to audit.

Common mistakes:

- Leaving role blank.
- Using a system role instead of a human responsibility.

Avoidance:

- Pick the actual responsibility used during verification.

### `submitted_at`

Meaning: when the Human Operator submitted or updated the evidence packet.

Format:

- Use an explicit timestamp.
- Recommended format: `YYYY-MM-DD HH:mm timezone`.
- Example timezones: `Asia/Shanghai`, `UTC`, or local timezone with offset.

Good Example:

```text
2026-06-20 18:30 Asia/Shanghai
```

Bad Example:

```text
today
```

Problem: relative dates become ambiguous in audit records.

Common mistakes:

- Using `now`, `today`, or a date without timezone.
- Reusing a previous timestamp from an old packet.

Avoidance:

- Write the actual submission time as an absolute timestamp.

### `verified_environment`

Meaning: the environment personally verified by the Human Operator.

Allowed values:

- `local`
- `staging`
- `test`
- `sandbox`
- `production`

Good Example:

```text
staging
```

Bad Example:

```text
online maybe
```

Problem: ambiguous environment can be mistaken for production readiness.

Common mistakes:

- Claiming production when only local/staging was verified.
- Mixing payment provider mode with app environment.

Avoidance:

- State exactly where the evidence was verified.
- If unsure, use the narrower environment and explain in `verification_scope`.

### `verification_scope`

Meaning: what the Human Operator personally checked.

Format:

- One or two concrete sentences.
- Include what was checked, where it was checked, and what artifact proves it.

Good Example:

```text
Verified one manually published Day010 asset on Xiaohongshu staging marketing queue. Checked public URL, timestamp, masked account label, and KPI row artifact.
```

Bad Example:

```text
Everything is ready.
```

Problem: broad readiness claims are not evidence.

Common mistakes:

- Claiming full launch readiness from one artifact.
- Omitting the checked channel or artifact.

Avoidance:

- Keep the scope narrow and tied to artifacts.

### `present`

Meaning: whether a row has a real masked artifact attached.

Allowed values:

- `no`: evidence is missing, unresolved, or not reviewable.
- `yes`: a real masked artifact exists and is linked.

Good Example:

```text
present=yes
masked artifact path=Codex_L1_Governance/Projects/ai占卜.ai/当前状态/manual_publication_artifacts/day010_post_001_masked.png
```

Bad Example:

```text
present=yes
masked artifact path=todo
```

Problem: `present=yes` without an artifact is fabricated evidence.

Common mistakes:

- Changing all rows to `present=yes` after writing a summary.
- Linking to a raw secret file or unmasked screenshot.

Avoidance:

- Only change one row at a time after the artifact exists.
- Keep unresolved rows as `present=no`.

### `Masked artifact path/link`

Meaning: the path or URL where a reviewer can inspect the masked proof.

Format:

- Use a repo path, public URL, or sanitized external reference.
- Avoid raw credentials, private dashboards, customer data, or secret-bearing files.

Good Example:

```text
Codex_L1_Governance/Projects/ai占卜.ai/当前状态/manual_publication_artifacts/day010_publication_proof_001_masked.md
```

Bad Example:

```text
.env.production
```

Problem: raw secret-bearing files must never be evidence artifacts.

Common mistakes:

- Linking to screenshots with visible tokens or personal data.
- Linking to local files that a reviewer cannot inspect.

Avoidance:

- Redact first, then link the redacted artifact.

### `Human note`

Meaning: a short explanation of the evidence row.

Format:

- Explain what the artifact proves.
- Mention limitations.
- Do not make broad readiness claims.

Good Example:

```text
Proves one manually published Day010 asset had a public URL and timestamp. Does not prove Revenue Gate readiness.
```

Bad Example:

```text
This proves launch is ready.
```

Problem: one evidence row cannot prove full launch readiness.

Common mistakes:

- Overclaiming.
- Omitting what remains blocked.

Avoidance:

- Write the narrow fact proven by the artifact.

## Evidence Quality Checklist

- [ ] A real Human Operator filled `submitted_by`.
- [ ] `role` describes the operator's actual responsibility.
- [ ] `submitted_at` is an absolute timestamp.
- [ ] `verified_environment` is one of the allowed values.
- [ ] `verification_scope` says exactly what was checked.
- [ ] Every `present=yes` row has a masked artifact path or link.
- [ ] Unresolved rows remain `present=no`.
- [ ] No raw `.env`, provider key, payment secret, webhook secret, production credential, or customer private data is included.
- [ ] Any screenshot is redacted before it is referenced.
- [ ] The packet avoids broad claims such as `execution_go=true`, `Revenue ready`, or `Production ready`.
- [ ] The packet has been checked with `human-evidence-intake-check.ps1`.

## ai-divination Current-State Notes

Because ai-divination currently has `present_yes=0` and `present_no=10`:

- Do not try to complete all 10 rows at once.
- Start with the smallest real packet:
  1. Human Operator attestation.
  2. One manually published asset proof.
  3. One KPI row for that published asset.
- Leave all other rows as `present=no`.
- Treat any revenue or demand signal as a separate masked evidence candidate.

## Post-Fill Command

After a real Human Operator updates the actual evidence file, run:

```powershell
& .\Codex_L1_Governance\scripts\human-evidence-intake-check.ps1 `
  -EvidenceFile ".\Codex_L1_Governance\Projects\ai占卜.ai\当前状态\当前_Evidence_Gate_状态.md" `
  -Json
```

## Template Update Recommendation

The base template should link to this guide. The template itself should remain compact so Human Operators can fill it quickly.

## Compliance Boundary

This guide does not submit evidence, does not change `present=no`, does not set `execution_go=true`, and does not approve Evidence or Revenue gates.

