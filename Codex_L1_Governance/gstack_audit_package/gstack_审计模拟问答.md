# gstack Audit Simulation Q&A

## 1. What is the purpose of Codex_L1_Governance?

It is a shared governance control plane for Codex workflows. It defines rules, gates, Skill triggers, scripts, review records, and audit materials. It does not approve project execution by itself.

## 2. Does L1 readiness mean ai占卜.ai can execute or launch?

No. ai占卜.ai remains `no_go` with `execution_go=false`. Evidence and Revenue remain blocked until real Human Operator evidence exists.

## 3. What is the current audit package version?

The current target version is `gstack-audit-package-v1.7`.

## 4. What is the latest L1 maturity estimate?

The latest formal estimate remains `8.6/10`. Newer docs and scripts improve audit readiness, but we do not claim 10/10.

## 5. Why is 10/10 not claimed?

Decision refresh validation, standalone secret-shape automation, project trend history, and fully approved scheduling/CI still need additional work.

## 6. Which scripts are verified?

The L1 layer has verified read-only or dry-run scripts for evidence intake, round closeout, artifact hygiene, and weekly health checks.

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

The package includes an inactive GitHub Actions schedule example under `automation_examples/`. It is not installed under `.github/workflows/`, so it does not change CI behavior unless the repository maintainer explicitly enables it.

## 14. How does multi-project governance work?

Projects reference shared L1 rules and keep project-specific evidence separate. Each project remains fail-closed until its own evidence is complete.

## 15. What is the current ai占卜.ai pilot status?

It is `connected_with_blockers`: L1 controls are connected, but Evidence and Revenue remain blocked and the project remains `no_go`.

## 16. What should the Human Operator do next?

Complete `当前_Evidence_Gate_状态.md` using `Evidence_补齐指南.md`, providing real masked evidence paths and real operator metadata.

## 17. What should gstack focus on during formal audit?

gstack should verify whether the L1 governance system is clear, conservative, script-backed, and fail-closed. It should not treat L1 health as project launch readiness.
