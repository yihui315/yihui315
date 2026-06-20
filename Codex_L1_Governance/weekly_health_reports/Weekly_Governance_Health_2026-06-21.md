# Weekly Governance Health 2026-06-21

## Summary

| Field | Value |
| --- | --- |
| status | `pass` |
| score | `100/100` |
| generated_at | `2026-06-21T06:28:02` |
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
| archive_plan | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\artifact_hygiene_reports\Archive_Plan_2026-06-21.md` |

## Secret And Env-Like Scan

| Field | Value |
| --- | --- |
| scanned_files | `136` |
| secret_shape_hits | `0` |
| env_like_files | `0` |

## L1 Loop State

| Field | Value |
| --- | --- |
| state_file_present | `True` |
| should_stop | `False` |
| stop_reason | `` |
| iteration_count | `3` |
| current_score | `80` |
| current_execution_go | `False` |
| current_failure_category | `context` |

## Commands

```powershell
& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 -Json
& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 -NotifyOn always -NotificationProvider slack -NotificationWebhookUrl '<slack-webhook-url-from-secret-store>' -NotificationDryRun:$true -Json
& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 -EnableNotification -NotifyOn blocked -NotificationProvider slack -NotificationWebhookUrl $env:L1_SLACK_WEBHOOK_URL -NotificationDryRun:$false -Json
& .\Codex_L1_Governance\scripts\round-closeout-validator.ps1 -Json
& .\Codex_L1_Governance\scripts\governance-artifact-hygiene.ps1 -TargetDirectories @('artifacts', 'screenshots', 'logs', 'mcp') -OlderThanDays 90 -DryRun:$true -Json
```

## Issues

- none

## Notification

| Field | Value |
| --- | --- |
| notify_on | `blocked` |
| should_notify | `False` |
| notification_provider | `generic` |
| notification_enabled | `False` |
| notification_status | `skipped_by_notify_mode` |
| notification_dry_run | `True` |
| webhook_host | `` |

## Compliance Boundary

- This report is L1 governance-only.
- This report does not grant project execution, revenue, payment, or production readiness.
- No files were moved, deleted, compressed, archived, or modified by the artifact hygiene step.
- Webhook URLs must be passed at runtime and must not be committed to repository files.
