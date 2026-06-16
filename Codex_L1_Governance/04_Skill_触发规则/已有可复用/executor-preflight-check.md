# executor-preflight-check

## Source Skill

Local skill read from `C:\Users\Administrator\.agents\skills\executor-preflight-check\SKILL.md`.

## Trigger Conditions

Use before:

- `ExecutorAnalyze`
- `ExecutorExecute`
- `SafeCycle`
- `Autopilot`
- weekly Autopilot health checks
- any handoff that depends on a local Ollama Executor profile

## Inputs

- intended executor profile
- required model name
- sanitized executor status request

## Outputs

- one structured executor availability JSON object
- recommendation
- timeout and model status

## Key Files

- `.ai/MODEL_ROUTING.md` when present in a target project
- `~/.codex/config.toml` only for profile location checking when needed
- `Codex_L1_Governance/05_Agent_与_Worker_边界/AGENTS.md`

## Compliance Constraints

- Passing ExecutorPreflight is not Execution Go.
- Do not modify env files, profile config, app source, production settings, payment state, deployment state, or Git history.
- Keep checks short and bounded.
