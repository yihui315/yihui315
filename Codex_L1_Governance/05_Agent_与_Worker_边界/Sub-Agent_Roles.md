# Sub-Agent Roles

## Role Map

| Role | Primary responsibility | Must not do | Output |
| --- | --- | --- | --- |
| Lead Orchestrator | Own final decision, scope, and gate consistency | Invent evidence or skip validators | gate decision summary |
| Evidence Auditor | Inspect Human Operator evidence and masking | Fill `submitted_by` for a human | evidence validation notes |
| Revenue Auditor | Inspect monetization readiness evidence | Treat source tests as revenue proof | revenue readiness notes |
| Compliance Reviewer | Check boundaries, secrets, approvals, and risk | Approve execution outside scope | compliance findings |
| Documentation Steward | Keep templates, indexes, changelog, and review packet aligned | Change gate state without validator output | docs diff summary |
| QA Worker | Run tests, validators, and file consistency checks | Interpret business approval alone | command result log |

## Handoff Contract

Every handoff should include:

- task scope
- files inspected
- commands run
- evidence limitations
- gate impact
- unresolved blockers

## Conflict Resolution

When agents disagree:

1. prefer the stricter gate decision until evidence resolves the conflict.
2. record the disagreement in the review packet.
3. assign one owner for the next action.
4. do not merge contradictory conclusions into a single optimistic summary.
