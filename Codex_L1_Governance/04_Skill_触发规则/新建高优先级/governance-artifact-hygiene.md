# Skill: governance-artifact-hygiene

## 触发条件（Trigger Condition）

- `.ai/artifacts`、screenshots、logs、mcp 等目录下文件数量或体积显著增长时
- 每周定期触发（建议与 weekly-autopilot-health-check 联动）
- 手动触发（治理产物整理需求）

## 输入（Input）

- 目标目录路径列表（默认包含：artifacts、screenshots、logs、mcp）
- 当前 `ORCHESTRATOR_GATE_STATE.json`（可选）

## 输出（Output）

- Archive Plan：建议归档的目录/文件清单
- Dry-run 命令：可安全执行的归档/清理命令
- 保留清单：必须保留的核心治理文件
- 执行建议：是否需要人工确认后执行

## 核心职责

1. 识别治理相关产物中可归档或可清理的内容
2. 生成安全的归档计划，避免误删重要文件
3. 输出 dry-run 命令，降低执行风险
4. 记录本次 hygiene 操作到 `REVIEW_PACKET_Master.md`

## 合规约束

- 仅操作治理相关目录，不触碰业务代码、`.env`、secrets
- 所有归档操作必须先生成 dry-run，确认后再执行
- 重要文件必须列入保留清单

## 与现有体系的结合点

- 输出结果可直接追加到 `REVIEW_PACKET_Master.md`
- 可与 `round-closeout-validator` 配合使用
- 推荐在 `AGENTS.md` 中加入定期执行规则
