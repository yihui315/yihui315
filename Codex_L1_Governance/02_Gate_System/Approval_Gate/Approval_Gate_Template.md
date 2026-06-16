# Approval Gate Template

## Objective

The Approval Gate records what a human or authorized governance process has approved. It does not replace Evidence or Revenue gates.

## Approval Scopes

| Scope | Meaning | Allowed actions |
| --- | --- | --- |
| `plan-only` | Planning and documentation are approved | Templates, plans, checklists, non-execution docs |
| `local-execution` | Local commands and non-production validation are approved | Tests, local scripts, dry runs |
| `staging-execution` | Staging operations are approved | Staging deployment, sandbox checks |
| `production-execution` | Production changes are approved | Production deploy or live operations |

## Required Fields

| Field | Required | Notes |
| --- | --- | --- |
| `approved_by` | yes | Human approver or authorized governance process |
| `approved_scope` | yes | One of the listed scopes |
| `approved_at` | yes | Date-time |
| `limits` | yes | Explicit boundaries and forbidden actions |
| `expires_at` | recommended | Required for risky work |

## No-Go Rules

Approval Gate does not pass execution when:

- the approved scope is `plan-only`.
- the approver is unknown.
- limits are missing for revenue, production, or public-facing changes.
- Evidence or Revenue gates remain blocked for the requested execution.

## Decision Block

```json
{
  "gate": "approval",
  "status": "pass",
  "approved_scope": "plan-only",
  "approved_by": null,
  "limits": [
    "documentation only",
    "no fabricated evidence",
    "no production changes"
  ],
  "notes": []
}
```
