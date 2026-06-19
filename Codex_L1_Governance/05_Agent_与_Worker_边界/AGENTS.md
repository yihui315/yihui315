# Codex L1 Agent Rules

## Scope

These rules apply to L1 governance work under `Codex_L1_Governance`, especially gate, skill, revenue, evidence, and orchestrator decision workflows.

## Mandatory Gate Chain

Use this chain for reusable governance work:

`Human Evidence -> human-evidence-intake-check -> State Sync -> orchestrator-decision-refresh -> Review Packet`

## Hard Rules

1. Any task involving Revenue must first trigger `human-evidence-intake-check` when new masked evidence is present, then trigger `orchestrator-decision-refresh` before revenue execution is considered.
2. Any Gate status change must trigger `orchestrator-decision-refresh`.
3. Any Human Operator evidence submission must first go through `human-evidence-intake-check`.
4. `human-evidence-intake-check` may validate completeness and missing fields, but it must not make the final `real_go` decision.
5. `orchestrator-decision-refresh` may consume validator outputs and gate state, but it must not invent evidence or judge raw evidence truth by itself.
6. `tianji-revenue-gate` must read the final `ORCHESTRATOR_GATE_DECISION.json` verdict before revenue work proceeds.
7. Revenue work may continue only when the orchestrator decision is `conditional_go` for the requested bounded scope or `execution_go=true`.
8. `submitted_by=todo` and `present=no` must remain unchanged until real Human Operator evidence exists.
9. Do not read, print, copy, stage, or summarize raw secrets, `.env` files, provider/payment keys, webhook secrets, or production credentials.
10. Use sanitized state files, masked evidence, validator summaries, and decision JSON as the L1 interface.
11. Any automation or script introduced for L1 must default to read-only or dry-run mode.
12. Every automation result must be recorded in the relevant Review Packet or L1 report before the round is considered closed.
13. Every governance round must run `round-closeout-validator` after the final decision refresh and before the next round starts.
14. A skill cannot be marked `active` in the registry until a script, command, or runtime invocation has been verified and recorded.
15. Any failed validator, missing artifact, or skipped required record must be preserved as a blocker rather than summarized away.
16. The L1 layer must run `weekly-governance-health-check` at least once per calendar week when governance work continues.
17. Weekly health check output must be recorded before claiming weekly L1 audit readiness.
18. Webhook notifications must be disabled or dry-run by default; real delivery requires an explicit enable switch and a runtime URL from an external secret store.
19. Schedule examples, GitHub Actions examples, or cron examples must not be treated as enabled automation until a maintainer explicitly installs them in the active scheduler location.

## Weekly Health Check Trigger

Run a governance health check when any of these occur:

- two or more gate refreshes happen in one week.
- blocker_count changes.
- a failure case remains open for more than one review cycle.
- a proposed skill is used operationally but not promoted in the registry.
- revenue, executor, or environment gates are mentioned in a handoff.
- artifact directories such as `.ai/artifacts`, screenshots, logs, or MCP outputs grow significantly; trigger `governance-artifact-hygiene` in dry-run mode.
- an Orchestrator or Self-Distillation round ends; trigger `round-closeout-validator` before entering the next round.
- each active governance week ends; trigger `weekly-governance-health-check` and store the Markdown report.

## Notification And Scheduling Boundary

- Use `-NotificationDryRun:$true` when validating webhook wiring.
- Use real webhook delivery only with `-EnableNotification`, `-NotificationDryRun:$false`, and a URL supplied at runtime.
- Never commit full webhook URLs or provider secrets.
- Keep automation examples outside active scheduler paths unless the maintainer approves activation.

## Required Review Packet Update

Every rule, skill binding, or gate chain change must be recorded in `REVIEW_PACKET_Master.md` with:

- date
- skill or rule name
- trigger condition
- key files
- compliance boundary
