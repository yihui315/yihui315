# L1 Governance Overview

## Purpose

`Codex_L1_Governance` is the shared governance layer for Codex-driven project work. It provides reusable rules, gates, Skill definitions, validation scripts, review packets, and audit records.

This layer is a control plane. It is not an execution approval artifact for any individual project.

## Architecture

```text
Codex_L1_Governance
  -> Overview and principles
  -> 12D scan engine
  -> Gate system
  -> Failure case library
  -> Skill trigger rules and registry
  -> Agent and Worker boundaries
  -> Feedback and scoring
  -> Scripts and generated validation reports
  -> Self-run and self-evolution feedback reports
  -> Codex improvement suggestion reports
  -> Observability dashboard
  -> Project pilot records
```

## Core Control Chain

```text
Human Operator evidence
  -> human-evidence-intake-check
  -> sanitized evidence/state sync
  -> orchestrator-decision-refresh
  -> round-closeout-validator
  -> weekly-governance-health-check
  -> generate-weekly-feedback-report
  -> reflect-l1-governance-loop
  -> update-l1-loop-state
  -> reflect-and-improve
  -> L1 observability dashboard
  -> REVIEW_PACKET_Master and CHANGELOG
```

## Gate Boundary

| Gate | L1 role | Non-claim |
| --- | --- | --- |
| Evidence | Provides intake templates and read-only validation | Does not invent Human Operator identity or evidence |
| Revenue | Provides safety binding and readiness templates | Does not prove payment/provider readiness |
| Approval | Tracks plan-only governance approval | Does not grant execution approval |
| Execution | Requires project-specific gate evidence | L1 docs alone cannot set `execution_go=true` |

## Audit Readiness

Current readiness posture:

- governance audit readiness: `ready_for_gstack_governance_audit`
- project execution readiness: not claimed
- latest package version: `gstack-audit-package-v2.0`
- latest known L1 maturity estimate: `8.6/10`

## Self-Run And Observability

L1 now produces four connected report families:

| Report family | Purpose | Boundary |
| --- | --- | --- |
| Weekly Health | Confirms validator, hygiene, secret-shape, and stop-state status | Does not approve projects |
| Feedback | Converts health into 12D recommendations and Codex suggestion candidates | Advisory only |
| Reflection | Identifies root cause and failure category | Cannot trigger Executor |
| Observability Dashboard | Summarizes health, stop state, evidence intake, and pilot status in one place | Read-only |

## Evidence Principle

Every status claim must be backed by a durable file, script result, or explicit fail-closed record. When evidence is missing, the correct output is `blocked`, not a synthetic pass.
