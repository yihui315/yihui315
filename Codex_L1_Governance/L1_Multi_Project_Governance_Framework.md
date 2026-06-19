# L1 Multi-Project Governance Framework

## Purpose

This framework defines how multiple projects should adopt `Codex_L1_Governance` without copying rules into divergent local variants.

The goal is shared governance with project-specific evidence.

## Layer Model

| Layer | Scope | Owner | Evidence boundary |
| --- | --- | --- | --- |
| L1 shared governance | Rules, templates, Skills, scripts, audit package | Codex L1 governance | No project gate pass by itself |
| Project binding | Project references to L1 rules and scripts | Project maintainer | Records which L1 controls are connected |
| Project evidence | Human Operator evidence, revenue evidence, environment checks | Human Operator / project owner | Required for project gate changes |
| Project decision | Project-level gate decision and review packet | Orchestrator / reviewer | Must stay fail-closed when evidence is missing |

## Project Onboarding Checklist

1. Create `Projects/<project-name>/当前状态/`.
2. Add a project rule reference file pointing to `05_Agent_与_Worker_边界/AGENTS.md`.
3. Add current Evidence Gate status using the L1 Human Operator template.
4. Add current Gate Decision summary.
5. Run `human-evidence-intake-check.ps1`.
6. Run `weekly-governance-health-check.ps1`.
7. Record whether the project is `connected`, `connected_with_blockers`, or `not_connected`.
8. Preserve `no_go` when Evidence or Revenue remains missing.

## Project Status Values

| Status | Meaning |
| --- | --- |
| `not_connected` | Project has not referenced L1 rules or scripts |
| `connected` | Project references L1 and has no current L1 adoption blockers |
| `connected_with_blockers` | Project references L1, but project-specific evidence is still blocked |
| `blocked` | Required files or safety checks are missing |

## Required Project Files

| File | Purpose |
| --- | --- |
| `L1_规则引用.md` | Records which L1 rules and scripts the project uses |
| `当前_Evidence_Gate_状态.md` | Tracks Human Operator evidence state |
| `当前_Gate_Decision_摘要.md` | Tracks current project decision and blocker state |
| `L1_试点接入报告_YYYY-MM-DD.md` | Records adoption status and latest checks |
| `Evidence_补齐指南.md` | Gives Human Operator evidence completion instructions |
| `Weekly_Health_Check_调用记录.md` | Records L1 weekly health check use |

## Shared Scripts

| Script | Project use |
| --- | --- |
| `scripts/human-evidence-intake-check.ps1` | Validate evidence intake shape |
| `scripts/round-closeout-validator.ps1` | Confirm L1 closeout health |
| `scripts/governance-artifact-hygiene.ps1` | Plan artifact hygiene in dry-run mode |
| `scripts/weekly-governance-health-check.ps1` | Run weekly L1 health and optional webhook notification |

## Fail-Closed Rule

If project-specific evidence is missing, the project remains blocked even when L1 health is good.

Examples:

- `weekly-governance-health-check` can pass while a project remains `no_go`.
- `human-evidence-intake-check` can correctly return `blocked`.
- `Approval Gate=pass plan-only` does not imply execution approval.

## Project Registry Template

| Project | L1 status | Current decision | Evidence | Revenue | Latest report | Next action |
| --- | --- | --- | --- | --- | --- | --- |
| `ai占卜.ai` | `connected_with_blockers` | `no_go` | `blocked` | `blocked` | `Projects/ai占卜.ai/当前状态/L1_试点接入报告_2026-06-20.md` | Human Operator evidence completion |

## Audit Guidance

Auditors should check:

1. Whether project files reference L1 rules rather than forked rules.
2. Whether scripts were run and reports were saved.
3. Whether project gates remain blocked when evidence is missing.
4. Whether no raw secrets or provider/payment credentials were added.
5. Whether project status claims match evidence reports.
