# Feedback Loop Mechanism

## Loop Objective

Each review should improve the next run by updating templates, triggers, or automation candidates.

## Loop Stages

| Stage | Question | Artifact |
| --- | --- | --- |
| Observe | What happened? | review packet, validator output |
| Diagnose | Why did it happen? | 12D scan, failure case |
| Decide | What is allowed now? | gate decision JSON |
| Improve | What should be reusable? | template or skill rule update |
| Verify | Did the change work? | next review packet score |

## Required Feedback Fields

- repeated blocker:
- affected dimension:
- proposed template change:
- proposed skill or automation:
- owner:
- due date:
- verification command:
- next review date:

## Escalation Rules

Escalate a blocker to L1 when:

- it repeats in two or more projects.
- it involves evidence fabrication risk.
- it requires a shared skill, validator, or template.
- it affects production, revenue, or public trust.

## Closure Rules

A loop is closed only when:

- the root blocker is no longer present.
- the change is documented in a durable artifact.
- a later validation confirms the improvement.
