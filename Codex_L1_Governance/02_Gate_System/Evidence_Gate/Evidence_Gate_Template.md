# Evidence Gate Template

## Objective

The Evidence Gate verifies whether a project has real, reviewable, masked evidence for the claims needed by the current decision.

## Status Values

- `pass`: all required evidence rows are present and attributable.
- `blocked`: required evidence is missing, stale, unattributed, or not masked.
- `fail`: evidence contradicts the claim or exposes unacceptable risk.
- `not_applicable`: evidence is not required for the current scope.

## Required Fields

| Field | Required | Notes |
| --- | --- | --- |
| `submitted_by` | yes | Must be a real Human Operator or verified system actor |
| `submitted_at` | yes | ISO date or clear local date-time |
| `verified_environment` | yes | `local`, `staging`, `test`, `sandbox`, or `production` |
| `masked_evidence_rows` | yes | Each row must state `present=yes/no` |
| `reviewer` | yes | Person or Codex run that reviewed the evidence |
| `decision` | yes | `pass`, `blocked`, `fail`, or `not_applicable` |

## Evidence Row Schema

| Row ID | Claim | present | Masked artifact | Submitted by | Reviewer note |
| --- | --- | --- | --- | --- | --- |
| EV-001 |  | yes/no |  |  |  |

## No-Go Rules

The Evidence Gate must remain blocked when:

- `submitted_by` is `todo`, blank, or fabricated.
- a required row is `present=no`.
- an artifact contains unmasked secrets or private data.
- the artifact only describes intended work and does not prove completion.
- evidence exists in chat but is not saved or referenced in a durable artifact.

## Decision Block

```json
{
  "gate": "evidence",
  "status": "blocked",
  "submitted_by": "todo",
  "submitted_at": null,
  "verified_environment": null,
  "required_rows": 0,
  "present_rows": 0,
  "blocked_rows": 0,
  "notes": []
}
```
