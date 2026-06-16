# Codex System Overview

## Purpose

This directory is the shared L1 governance layer for Codex-managed projects. It is not a single-project review packet. It defines the reusable standards, templates, scoring fields, gate language, failure-case structure, and agent collaboration boundaries that project-level governance files should inherit.

## Four-Layer Model

| Layer | Name | Scope | Example artifacts |
| --- | --- | --- | --- |
| L1 | Core governance | Shared across all Codex projects | 12D scan framework, gate templates, skill rules, failure case library |
| L2 | Project governance | One project or product line | `ORCHESTRATOR_GATE_STATE.json`, `ORCHESTRATOR_GATE_DECISION.json`, project `REVIEW_PACKET.md` |
| L3 | Execution workflow | Specific rounds, agents, validators, workers | validation commands, review runs, evidence checks, worker outputs |
| L4 | Evidence and assets | Real submitted evidence, masked screenshots, logs, reports | Human Operator rows, masked evidence files, public result checks |

## Inheritance Rules

1. L1 files define standards only. They must not claim a project has passed a gate.
2. L2 project files may reference L1 templates, but each project must keep its own current gate state.
3. L3 execution records must include commands, outputs, and limitations.
4. L4 evidence must be submitted by a real Human Operator or produced by a verifiable system action.
5. Missing evidence remains missing. Do not convert `present=no` to `present=yes` without real evidence.

## Canonical L1 Artifacts

- `01_12维扫描引擎/12维扫描框架_v1.md`
- `02_Gate_System/Gate_Decision_Canonical.json`
- `03_失败案例库/Failure_Case_Template.md`
- `04_Skill_触发规则/Skill_Trigger_Rules.md`
- `05_Agent_与_Worker_边界/Agent_Collaboration_Protocol.md`
- `06_反馈闭环_与_评分/REVIEW_PACKET_量化评分字段.md`
- `REVIEW_PACKET_Master.md`

## Operating Mode

The L1 governance layer is problem-driven. It should help Codex decide:

- What is blocked?
- What evidence is missing?
- Which gate is allowed to pass?
- Which work can run in parallel?
- Which failure should become reusable knowledge?
- Which next action is the smallest safe action?
