# L1 Observability Dashboard 2026-06-21

## Summary

| Metric | Value |
| --- | --- |
| weekly_health_status | `pass` |
| weekly_health_score | `100` |
| secret_shape_hits | `0` |
| l1_should_stop | `False` |
| l1_stop_reason | `` |
| reflection_failure_category | `context` |
| reflection_recoverable | `True` |
| recommended_strategy | `add_context` |
| auto_retry_count | `0` |
| max_auto_retries | `2` |
| auto_recovery_status | `not_needed` |
| codex_suggestion_count | `5` |
| improvement_suggestion_count | `8` |
| evidence_intake_status | `blocked` |
| evidence_present_yes | `0` |
| evidence_present_no | `10` |
| pilot_no_go | `True` |
| pilot_execution_go_false | `True` |
| loop_trend_points | `3` |

## Trend Analysis

### Loop Iteration Trend

| Recorded at | Iteration | Score | Failure | Recoverable | Auto retry | Recovery status | Stop/soft reason | Hard stop |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-06-20T20:57:53 | `2` | `100` | `prompt` | `False` | `0` | `` | `repeated_failure_category` | `True` |
| 2026-06-21T06:27:13 | `3` | `80` | `context` | `True` | `1` | `retry_allowed` | `no_progress` | `False` |
| 2026-06-21T06:28:53 | `4` | `100` | `context` | `True` | `0` | `not_needed` | `none` | `False` |

### Health Score Trend

| Date | Status | Score | Delta |
| --- | --- | --- | --- |
| 2026-06-20 | `pass` | `100` | `` |
| 2026-06-21 | `pass` | `100` | `0` |

### Stop Reason Distribution

| Stop reason | Count |
| --- | --- |
| `repeated_failure_category` | `1` |
| `none` | `2` |

### Improvement Suggestion Trend

| Date | Suggestion count | Failure category |
| --- | --- | --- |
| 2026-06-20 | `8` | `context` |
| 2026-06-21 | `8` | `context` |

## Key Metrics

| Metric | Value | Note |
| --- | --- | --- |
| improvement_suggestion_total | `16` | Counted from improvement report history |
| improvement_adoption_rate_percent | `` | not_tracked_until_suggestions_gain_status_fields |
| average_iteration_count | `3` | Uses loop_history when present, otherwise current state |
| repeated_failure_frequency_percent | `33.33` | Uses loop_history when present, otherwise current repeated-failure state |

## ai-divination Pilot Monitoring

| Metric | Value |
| --- | --- |
| execution_go_current | `False` |
| execution_go_trend | `stable_false` |
| evidence_status_current | `blocked` |
| evidence_present_yes_current | `0` |
| evidence_present_no_current | `10` |

## Source Files

| Area | Source |
| --- | --- |
| health | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\weekly_health_reports\Weekly_Governance_Health_2026-06-21.json` |
| feedback | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\feedback_reports\Weekly_Governance_Feedback_2026-06-21.json` |
| reflection | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\reflection_reports\L1_Reflection_2026-06-21.json` |
| improvement | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\improvement_reports\L1_Codex_Improvement_2026-06-21.json` |
| evidence_intake | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\evidence_intake_reports\Evidence_Intake_Report_2026-06-21.md` |
| state | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\L1_State.json` |
| pilot_decision | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\Projects\ai占卜.ai\当前状态\当前_Gate_Decision_摘要.md` |

## Compliance Boundary

- Dashboard is read-only.
- Dashboard does not change Evidence, Revenue, Approval, Execution, payment, provider, or production readiness.
- ai-divination pilot remains fail-closed while Human Operator evidence is missing.
