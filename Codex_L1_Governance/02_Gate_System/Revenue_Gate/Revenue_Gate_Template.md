# Revenue Gate Template

## Objective

The Revenue Gate verifies whether monetization, payment, entitlement, pricing, and launch-readiness claims have real masked evidence.

## Status Values

- `pass`: all required revenue evidence exists, is masked, and has been reviewed.
- `blocked`: required revenue evidence is missing or cannot be attributed.
- `fail`: revenue behavior is broken, unsafe, or contradicts the decision claim.
- `not_applicable`: revenue is outside the current scope.

## Required Evidence Categories

| Category | Required evidence | Status | Notes |
| --- | --- | --- | --- |
| Pricing | price IDs, plan mapping, user-facing price display |  | No raw secrets |
| Checkout | checkout/session creation proof |  | Mask IDs where needed |
| Payment flow | sandbox/test payment result or equivalent |  | No live payment without explicit approval |
| Webhook | event receipt and handling proof |  | Mask signatures and payload secrets |
| Entitlement | paid/free access state proof |  | Show allowed and denied states |
| Refund/cancel | cancellation or downgrade behavior |  | If in scope |
| Compliance | terms, privacy, refund policy, support path |  | Public pages or staged proof |

## Revenue No-Go Rules

Revenue Gate must remain blocked when:

- there is no Human Operator or verifiable system evidence.
- payment provider keys, webhook secrets, or raw customer data are exposed.
- source tests pass but checkout, webhook, or entitlement evidence is absent.
- approval is only `plan-only`.
- production deployment is assumed from a branch merge without public verification.

## Decision Block

```json
{
  "gate": "revenue",
  "status": "blocked",
  "required_categories": [],
  "passed_categories": [],
  "blocked_categories": [],
  "masked_evidence_required": true,
  "notes": []
}
```
