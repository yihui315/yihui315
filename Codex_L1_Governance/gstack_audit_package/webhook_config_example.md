# Weekly Health Webhook Config Example

## Scope

This file documents the expected runtime configuration shape for `weekly-governance-health-check.ps1`.

Do not commit complete webhook URLs, tokens, or provider secrets.

## Slack Incoming Webhook

Store the real webhook URL outside the repository, for example in a local secret manager or CI secret named:

```text
L1_SLACK_WEBHOOK_URL=<slack-webhook-url-from-secret-store>
```

Dry-run validation:

```powershell
& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 `
  -NotifyOn always `
  -NotificationProvider slack `
  -NotificationWebhookUrl $env:L1_SLACK_WEBHOOK_URL `
  -NotificationDryRun:$true `
  -Json
```

Real notification, only after dry-run review:

```powershell
& .\Codex_L1_Governance\scripts\weekly-governance-health-check.ps1 `
  -EnableNotification `
  -NotifyOn blocked `
  -NotificationProvider slack `
  -NotificationWebhookUrl $env:L1_SLACK_WEBHOOK_URL `
  -NotificationDryRun:$false `
  -Json
```

## Safety Rules

- `-NotificationDryRun` defaults to true.
- Real sending requires both `-EnableNotification` and `-NotificationDryRun:$false`.
- Reports record only `webhook_host`, never the full URL.
- Webhook configuration proves alert wiring only; it does not change any gate status.
