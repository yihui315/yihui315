# Weekly Health Check Report Guide

## Report Location

Default output:

```text
Codex_L1_Governance/weekly_health_reports/Weekly_Governance_Health_YYYY-MM-DD.md
```

## Summary Fields

| Field | Meaning | Audit interpretation |
| --- | --- | --- |
| `status` | Overall L1 weekly health status | `pass` means documentation-scope checks passed |
| `score` | Computed score from closeout, hygiene, and secret checks | `100/100` is a local health score, not project readiness |
| `governance_root` | L1 root checked | Confirms scan boundary |

## Round Closeout Section

Important fields:

- `closeout_status`
- `overall_decision`
- `execution_go`

Interpretation:

- `closeout_status=pass` means L1 documentation closeout can proceed.
- `overall_decision=no_go` and `execution_go=False` may still be correct.
- A closeout pass must not be reinterpreted as project execution approval.

## Artifact Hygiene Section

Important fields:

- `status`
- `candidate_items`
- `sensitive_shaped_path_hits`
- `archive_plan`

Interpretation:

- `candidate_items=0` means no old artifact candidates were found under configured targets.
- `sensitive_shaped_path_hits=0` means no sensitive-shaped artifact paths were detected by this script.
- The archive plan is dry-run evidence only.

## Secret And Env-Like Scan Section

Important fields:

- `secret_shape_hits`
- `env_like_files`

Interpretation:

- `secret_shape_hits=0` supports audit safety for scanned files.
- Any hit should block audit readiness until reviewed.
- `.env*` files under L1 should block closeout.

## Notification Section

Important fields:

- `notify_on`
- `should_notify`
- `notification_provider`
- `notification_enabled`
- `notification_status`
- `notification_dry_run`
- `webhook_host`

Interpretation:

- `notification_status=dry_run` means no webhook was sent.
- `notification_status=sent` means an explicitly enabled webhook POST completed.
- `notification_status=disabled_not_enabled` means the command requested non-dry-run delivery without the required `-EnableNotification` switch.
- `notification_status=skipped_by_notify_mode` means the current status did not match `NotifyOn`.
- `notification_provider=slack` means the script formatted a Slack incoming webhook payload.
- The report records only the webhook host, not the full URL.

## Status Rules

| Status | Meaning | Next action |
| --- | --- | --- |
| `pass` | L1 weekly checks passed for documentation scope | Record report and continue |
| `conditional` | Non-blocking gap exists | Resolve before claiming stronger readiness |
| `blocked` | Required L1 safety or completeness check failed | Do not claim weekly audit readiness |

## Non-Claims

The report does not claim:

- Human Operator evidence exists
- project Revenue Gate is ready
- project Execution Gate is ready
- production payment/provider credentials are valid
