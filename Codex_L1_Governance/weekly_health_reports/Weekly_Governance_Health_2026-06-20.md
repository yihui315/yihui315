# Weekly Governance Health 2026-06-20

## Summary

| Field | Value |
| --- | --- |
| status | `pass` |
| score | `100/100` |
| generated_at | `2026-06-20T06:11:23` |
| governance_root | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance` |

## Round Closeout

| Field | Value |
| --- | --- |
| exit_code | `0` |
| closeout_status | `pass` |
| overall_decision | `no_go` |
| execution_go | `False` |

## Artifact Hygiene

| Field | Value |
| --- | --- |
| exit_code | `0` |
| status | `pass` |
| candidate_items | `0` |
| sensitive_shaped_path_hits | `0` |
| archive_plan | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\artifact_hygiene_reports\Archive_Plan_2026-06-20.md` |

## Secret And Env-Like Scan

| Field | Value |
| --- | --- |
| scanned_files | `74` |
| secret_shape_hits | `0` |
| env_like_files | `0` |

## Commands

```powershell
& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 -Json
& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 -NotifyOn always -NotificationWebhookUrl '<webhook-url>' -NotificationDryRun:$true -Json
& .\Codex_L1_Governance\scripts\round-closeout-validator.ps1 -Json
& .\Codex_L1_Governance\scripts\governance-artifact-hygiene.ps1 -TargetDirectories @('artifacts', 'screenshots', 'logs', 'mcp') -OlderThanDays 90 -DryRun:$true -Json
```

## Issues

- none

## Notification

| Field | Value |
| --- | --- |
| notify_on | `always` |
| should_notify | `True` |
| notification_status | `dry_run` |
| notification_dry_run | `True` |
| webhook_host | `example.com` |

## Compliance Boundary

- This report is L1 governance-only.
- This report does not grant project execution, revenue, payment, or production readiness.
- No files were moved, deleted, compressed, archived, or modified by the artifact hygiene step.
- Webhook URLs must be passed at runtime and must not be committed to repository files.
