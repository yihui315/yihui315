# Skill: round-closeout-validator

## 触发条件（Trigger Condition）

- 每轮 `orchestrator-decision-refresh` 执行结束后
- 手动触发（本轮 Self-Distillation 或治理工作结束时）
- `AGENTS.md` 中定义的周期性触发

## 输入（Input）

- 本轮的 `ORCHESTRATOR_GATE_DECISION.json`
- `REVIEW_PACKET_Master.md` 最新内容
- `CHANGELOG.md` 最新内容
- 本轮产生的失败案例（如果有）

## 输出（Output）

- Round Closeout Report，包含：
  - 本轮关键决策与 Gate 状态总结
  - Review Packet 是否完整更新
  - 失败案例是否已沉淀
  - CHANGELOG 是否已更新
  - 是否存在未关闭的 blocker
  - 是否建议进入下一轮（Yes / Conditional / No + 理由）

## 核心职责

1. 验证本轮治理流程是否完整关闭
2. 检查关键治理文件是否已同步更新
3. 识别本轮遗留问题或未完成事项
4. 输出是否可以进入下一轮的明确判断

## 合规约束

- 只做验证和报告，不修改任何 Gate 状态或决策
- 所有判断必须基于已有文件内容

## 与现有体系的结合点

- 输出报告必须追加到 `REVIEW_PACKET_Master.md`
- 可与 `governance-artifact-hygiene` 配合使用
- 推荐在 `AGENTS.md` 中定义为每轮结束后的强制执行 Skill
