# gstack Audit Simulation Q&A

## 1. What is the purpose of Codex_L1_Governance?

It is a shared governance control plane for Codex workflows. It defines rules, gates, Skill triggers, scripts, review records, and audit materials. It does not approve project execution by itself.

## 2. Does L1 readiness mean ai占卜.ai can execute or launch?

No. ai占卜.ai remains `no_go` with `execution_go=false`. Evidence and Revenue remain blocked until real Human Operator evidence exists.

## 3. What is the current audit package version?

The current target version is `gstack-audit-package-v2.0`.

## 4. What is the latest L1 maturity estimate?

The latest formal estimate remains `8.6/10`. Newer docs and scripts improve audit readiness, but we do not claim 10/10.

## 5. Why is 10/10 not claimed?

Decision refresh validation, standalone secret-shape automation, longer project trend history, and multiple observed scheduled runs still need additional work.

## 6. Which scripts are verified?

The L1 layer has verified read-only, dry-run, report-only, or state-only scripts for evidence intake, round closeout, artifact hygiene, weekly health checks, feedback generation, reflection, and L1 loop state updates.

## 7. What does a Weekly Health `pass` mean?

It means L1 documentation-scope checks passed. It does not mean a project is ready for execution, revenue, payment, or production launch.

## 8. What happens when Human Operator evidence is missing?

`human-evidence-intake-check.ps1` returns `blocked`, records missing fields, and preserves the blocked state.

## 9. Did Codex fabricate `submitted_by` or evidence rows?

No. The current ai占卜.ai record keeps missing Human Operator fields and `present=no` rows unresolved.

## 10. How are secrets handled?

Scripts avoid reading `.env` files, count env-like files as blockers where relevant, and perform secret-shape scans on scannable governance files.

## 11. Does webhook notification expose webhook URLs?

No. Webhook URLs are passed at runtime and are not committed. Reports record only `webhook_host`, not the full URL.

## 12. Which real notification method is supported?

The weekly health script supports Slack incoming webhook payloads, plus generic JSON webhooks. Real sending requires `-EnableNotification`, `-NotificationDryRun:$false`, and a runtime URL supplied from a secret store.

## 13. Is there a scheduled automation?

The repository now includes an active `.github/workflows/weekly-governance-health-check.yml` workflow for weekly L1 health and feedback reports. The older `automation_examples/` file remains reference-only.

## 14. How does multi-project governance work?

Projects reference shared L1 rules and keep project-specific evidence separate. Each project remains fail-closed until its own evidence is complete.

## 15. What is the current ai占卜.ai pilot status?

It is `connected_with_blockers`: L1 controls are connected, but Evidence and Revenue remain blocked and the project remains `no_go`.

## 16. What should the Human Operator do next?

Complete `当前_Evidence_Gate_状态.md` using `Evidence_补齐指南.md`, providing real masked evidence paths and real operator metadata.

## 17. What should gstack focus on during formal audit?

gstack should verify whether the L1 governance system is clear, conservative, script-backed, and fail-closed. It should not treat L1 health as project launch readiness.

## 18. Does Reflector automatically change the system?

No. Reflector only writes advisory JSON and Markdown. It cannot modify gates, evidence, revenue state, execution readiness, or production settings.

## 19. What does `L1_State.json` control?

It tracks loop iteration count, latest score, execution_go trend, estimated cost, repeated failure category, and stopping status. Executor must not run when `should_stop=true`.

## 20. Are cost fields real billing data?

No. Cost fields are caller-provided estimates only. The system does not read API billing or claim exact spend.

## 21. What are the stopping-condition priorities?

The priority order is `cost_limit_reached`, `max_iterations_reached`, `no_progress`, then `repeated_failure_category`.

## 22. Can Executor run from GitHub Actions?

No. The workflow generates health, feedback, reflection, state, improvement, and observability reports only. Executor is not triggered by GitHub Actions. Local Executor work may safe-auto only low-risk governance docs/templates/indexes/reports/descriptive metadata when `should_stop=false`; high-risk work still requires explicit Human confirmation.

## 23. What happens if the same failure category repeats?

Reflector recommends lowering the next goal or pausing, and the state updater can set `should_stop=true` with `repeated_failure_category` unless a higher-priority stop reason applies.

## 24. What does `reflect-and-improve.ps1` do?

It consolidates health, feedback, reflection, and state into advisory Codex improvement suggestions. It does not call an external AI API and does not modify files, gates, evidence, revenue, or production state.

## 25. How does L1 recover after `should_stop=true`?

A Human reviewer must inspect `stop_reason`. Only then may `update-l1-loop-state.ps1 -ResetStop` be used. Resetting stop state only permits another observation loop; it does not approve Executor or project readiness.

## 26. What is the observability dashboard?

`L1_Observability_Dashboard.md` is a read-only dashboard summarizing latest weekly health, stop state, reflection, improvement suggestions, evidence intake, and ai占卜.ai pilot status.

## 27. Does the dashboard mean ai占卜.ai is ready?

No. The dashboard explicitly records ai占卜.ai as fail-closed while Human Operator evidence is missing. It is a visibility artifact, not a gate approval.
