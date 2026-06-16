# REVIEW_PACKET Quantitative Scoring Fields

## Required Section

Add this section after each orchestrator decision or major review.

```markdown
## 量化评分

- Evidence 完整度: 0-10
- Revenue 准备度: 0-10
- Approval 清晰度: 0-10
- 合规风险: low / medium / high
- blocker_count:
- blocker_count 趋势: up / down / flat
- 反馈闭环成熟度: 0-10
- 自动化潜力评分: 0-10
- 12维平均分: 0-10
- 整体健康度: 0-10
- 本轮主要问题维度:
- 本轮最大复用资产:
- 下一步最小安全行动:
```

## Scoring Guidance

| Field | 0-3 | 4-6 | 7-8 | 9-10 |
| --- | --- | --- | --- | --- |
| Evidence 完整度 | missing or unattributed | partial rows | mostly present and masked | complete, attributable, reviewed |
| Revenue 准备度 | no real proof | partial source readiness | tested critical path | full masked revenue evidence |
| Approval 清晰度 | unknown approver/scope | scope partly stated | explicit scope and limits | time-bound and traceable |
| 反馈闭环成熟度 | notes only | recurring notes | updates templates/checks | auto-routed and measured |
| 自动化潜力评分 | no repeatable path | manual repeatable path | scripts/checklists exist | validated automated loop |
| 整体健康度 | no_go with unknowns | no_go with known blockers | conditional/project-ready | execution-ready for approved scope |

## Rules

- A high documentation score cannot override missing evidence.
- A `plan-only` approval can improve Approval clarity but cannot set `execution_go=true`.
- If a score is estimated, label it as estimated.
- If a command was not run, do not imply validation coverage.
