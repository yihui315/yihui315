# Manual Publication Proof Checklist 2026-06-20

## Purpose

Use this checklist to convert one approved `pending_manual_review` asset into reviewable masked publication evidence.

## Companion Evidence Collection Templates

Use these supporting templates after a real Human Operator manually publishes an approved asset:

- `Post_Publication_Evidence_Collection_Template_2026-06-20.md`
- `Publication_Evidence_Log_Template_2026-06-20.csv`
- `Publication_Evidence_Log_Template_2026-06-20.json`

These files standardize post-publication evidence collection. They do not publish content, submit evidence, change `present=no`, or change `execution_go=false`.

## Selected Asset

| Field | Value |
| --- | --- |
| asset_id_or_name | `todo` |
| source_day | `Day010_or_specific_day` |
| source_path | `todo_sanitized_path` |
| approval_status_before_publish | `pending_manual_review` |
| publication_channel | `todo_channel` |

## Human Manual Action

The Human Operator must complete these actions:

- [ ] Confirm the asset is policy-safe and approved for manual publication.
- [ ] Publish the asset manually through an approved account/channel.
- [ ] Capture the public URL or channel-level proof.
- [ ] Record the publish timestamp.
- [ ] Record the account label without exposing credentials.
- [ ] Save a masked screenshot or sanitized proof artifact.
- [ ] Add one KPI observation row after publication.

## Masked Proof Fields

| Field | Required value |
| --- | --- |
| public_url_or_channel_proof | `todo` |
| published_at | `todo_actual_timestamp` |
| account_label_masked | `todo_masked_label` |
| screenshot_or_artifact_path | `todo_sanitized_path` |
| artifact_hash_optional | `todo_optional` |
| kpi_row_path | `todo_sanitized_path` |
| reviewer_note | `todo` |

## KPI Row Template

| published_at | channel | asset_id | public_url_or_proof | impressions | clicks | leads | revenue_signal | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `todo` | `todo` | `todo` | `todo_masked_or_public` | `todo` | `todo` | `todo` | `none_or_masked_candidate` | `todo` |

## Candidate Evidence Update

Only after the Human Operator completes the proof packet may a reviewer consider a candidate evidence row update.

Do not apply this automatically:

| Row ID | Candidate change | Condition |
| --- | --- | --- |
| EV-002 | `present=no` -> candidate `present=yes` | Real masked publication proof exists |
| EV-003 | `present=no` -> candidate `present=yes` | Real KPI row exists |

## Compliance Boundary

- This checklist does not publish content.
- This checklist does not trigger social auto-posting.
- This checklist does not send email.
- This checklist does not change `present=no`.
- This checklist does not change `execution_go=false`.
- This checklist does not prove revenue readiness.
