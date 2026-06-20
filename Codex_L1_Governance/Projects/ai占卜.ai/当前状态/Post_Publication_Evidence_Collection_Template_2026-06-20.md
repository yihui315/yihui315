# Post-Publication Evidence Collection Template 2026-06-20

## Purpose

Use this template after a Human Operator manually publishes one approved `pending_manual_review` asset from Day003-Day010.

This template captures masked publication proof, KPI evidence, and optional demand/revenue signal evidence. It does not publish content and does not change gate state.

## Publication Platform Information

| Field | Value |
| --- | --- |
| evidence_packet_id | `PUB-EV-YYYYMMDD-001` |
| source_day | `Day003_to_Day010` |
| asset_id_or_name | `todo` |
| source_asset_path | `todo_sanitized_path` |
| platform_name | `todo_platform` |
| publication_channel | `todo_channel_or_account_label` |
| published_at | `todo_actual_timestamp_with_timezone` |
| public_url_or_channel_proof | `todo_public_url_or_masked_channel_proof` |
| verified_environment | `production_public_channel` or `staging_public_preview` |
| human_operator | `todo_real_operator_or_role` |

## Publication Content Archive

Required archive artifacts:

- [ ] Masked screenshot of published content.
- [ ] Text or image archive of the published post/content.
- [ ] Public URL or channel-level proof.
- [ ] Timestamp visible in screenshot or recorded in metadata.
- [ ] Account/channel label masked if it contains private account details.

Artifact table:

| Artifact type | Path/link | Masking status | Notes |
| --- | --- | --- | --- |
| published_content_screenshot | `todo` | `masked` | `todo` |
| content_archive | `todo` | `non_secret` | `todo` |
| url_or_channel_proof | `todo` | `public_or_masked` | `todo` |

## KPI Evidence

KPI screenshot requirements:

- Must include a visible timestamp or export timestamp.
- Must identify the same platform/channel as the published item.
- Must not expose private user data or credentials.
- If metrics are not available yet, record `not_available_yet` and schedule a follow-up.

KPI table:

| Metric | Value | Evidence path/link | Timestamp | Notes |
| --- | --- | --- | --- | --- |
| impressions | `todo_or_not_available_yet` | `todo` | `todo` | `todo` |
| clicks | `todo_or_not_available_yet` | `todo` | `todo` | `todo` |
| leads | `todo_or_not_available_yet` | `todo` | `todo` | `todo` |
| saves_or_follows | `todo_or_not_available_yet` | `todo` | `todo` | `todo` |

## Masked Revenue / Demand Signal Evidence

Use this section only if a real signal exists.

Allowed signal examples:

- Masked paid order proof.
- Masked qualified lead form.
- Masked purchase-intent conversation summary.
- Sandbox/test checkout proof with provider mode clearly stated.
- Public comment or inquiry proof with private data redacted.

Not allowed:

- Raw payment/provider dashboards.
- Unmasked customer data.
- Verbal claims without artifact.
- Production payment readiness claims from sandbox proof.

Signal table:

| Signal type | Exists? | Masked artifact path/link | Provider/environment | Notes |
| --- | --- | --- | --- | --- |
| paid_order | `no` | `todo` | `todo` | `todo` |
| qualified_lead | `no` | `todo` | `todo` | `todo` |
| purchase_intent | `no` | `todo` | `todo` | `todo` |
| checkout_proof | `no` | `todo` | `sandbox/test/production_if_real` | `todo` |

## Post-Publication Verification Checklist

- [ ] The asset was manually approved before publication.
- [ ] The Human Operator manually published it.
- [ ] Public URL or channel proof exists.
- [ ] Published timestamp is recorded.
- [ ] Account label is masked if needed.
- [ ] Published content screenshot is redacted.
- [ ] KPI evidence includes timestamp or states `not_available_yet`.
- [ ] Any demand/revenue signal has a masked artifact.
- [ ] No raw secrets, provider tokens, payment credentials, `.env`, or customer private data are included.
- [ ] Candidate evidence row update remains reviewer-controlled.

## Minimum Acceptable Evidence Standard

A publication evidence packet is minimally acceptable only when all required items exist:

| Requirement | Minimum acceptable value |
| --- | --- |
| Human operator | Real operator or traceable role identifier |
| Published item | One manually published approved asset |
| Proof | Public URL or masked channel-level proof |
| Timestamp | Absolute timestamp with timezone |
| Artifact | Redacted screenshot or sanitized archive |
| KPI | At least one KPI row, even if early metrics are `not_available_yet` |
| Safety | No secrets, credentials, raw customer data, or `.env` content |

If any required item is missing, the evidence should remain `present=no`.

## Candidate Evidence Mapping

Do not apply automatically. A reviewer may consider these only after the Human Operator submits this packet:

| Evidence row | Candidate condition |
| --- | --- |
| EV-002 | Manual publication proof packet is complete |
| EV-003 | KPI row is complete and linked |
| EV-004 | Masked demand/revenue signal exists |

## Compliance Boundary

This template does not publish content, does not trigger social automation, does not send email, does not process payment, does not change `present=no`, and does not change `execution_go=false`.

