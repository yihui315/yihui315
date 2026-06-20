# Weekly Health Check Invocation Record

## 2026-06-20

Command:

```powershell
& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 -Json
```

Result:

- status: `pass`
- score: `100`
- report: `../../../weekly_health_reports/Weekly_Governance_Health_2026-06-20.md`
- closeout status: `pass`
- artifact hygiene status: `pass`
- secret_shape_hits: `0`
- env_like_files: `0`
- notification_provider: `generic`
- notification_status: `skipped_by_notify_mode`
- notification_enabled: `false`
- webhook_host: ``

Project impact:

- no gate state changed
- ai占卜.ai remains `no_go`
- Evidence Gate remains `blocked`
- Revenue Gate remains `blocked`

Interpretation:

The weekly L1 health check confirms L1 governance tooling health. It does not prove project-specific evidence or revenue readiness.

## Scheduled Mechanism

- active workflow: `.github/workflows/weekly-governance-health-check.yml`
- report directories: `weekly_health_reports/`, `feedback_reports/`
- notification mode: dry-run by default
- project impact: no automatic gate change
- ai占卜.ai remains `no_go` until real Human Operator evidence is submitted and reviewed
