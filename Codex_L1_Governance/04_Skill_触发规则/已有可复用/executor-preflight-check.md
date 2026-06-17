# Skill: executor-preflight-check

## Priority

Medium

## Status And Authority

- status: observed-local skill summary
- source: `C:\Users\Administrator\.agents\skills\executor-preflight-check\SKILL.md`
- authority: local executor availability check only

## Trigger Conditions

- Before `ExecutorAnalyze`.
- Before `ExecutorExecute`.
- Before `SafeCycle` or `Autopilot`.
- During weekly Autopilot health checks.
- Any handoff that depends on a local Ollama Executor profile.

## Inputs

- intended executor profile
- required model name
- sanitized executor status request

## Outputs

- one structured executor availability JSON object
- model availability
- API reachability
- timeout status
- recommendation

## Error Handling

- If Ollama is missing, return `executor_available=false`.
- If the API is unreachable, return `executor_available=false`.
- If the required model is missing, return `executor_available=false`.
- If the profile is unknown, return `executor_available=false`.

## Compliance Constraints

- Passing ExecutorPreflight is not Execution Go.
- Do not modify `.env`, profile config, app source, production settings, payment state, deployment state, or Git history.
- Keep checks short and bounded.

## Integration Points

- `Codex_L1_Governance/05_Agent_与_Worker_边界/AGENTS.md`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/round-closeout-validator.md`
- project `.ai/MODEL_ROUTING.md` when present

## Post-Run Required Records

- Record executor availability in the relevant Review Packet or health check report.
- Do not update gate state unless an authorized orchestrator decision refresh consumes the result.
