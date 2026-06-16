# Agent Collaboration Protocol

## Collaboration Goals

The agent system should reduce repeated manual work while preserving accountability and evidence quality.

## Standard Flow

1. Lead Orchestrator defines scope and gates.
2. Evidence and Revenue auditors inspect their lanes.
3. QA Worker runs validators and secret-shape scans.
4. Documentation Steward updates durable artifacts.
5. Lead Orchestrator issues the final decision.

## Required Decision Inputs

- latest gate state
- validator outputs
- Human Operator evidence status
- blocker count and trend
- approval scope
- risk notes

## Communication Rules

- Keep status updates short and evidence-based.
- Distinguish facts, inferences, and assumptions.
- Name blocked conditions directly.
- Do not hide failed commands.
- Do not claim current live state without verification.

## Final Decision Template

```text
Decision: go / no_go / conditional_go / plan_only
Execution allowed: true / false
Approved scope:
Evidence Gate:
Revenue Gate:
Approval Gate:
Blocker count:
Commands run:
Main risks:
Next smallest safe action:
```
