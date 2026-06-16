# tianji-revenue-gate

## Source Skill

Local skill read from `C:\Users\Administrator\.agents\skills\tianji-revenue-gate\SKILL.md`.

## Trigger Conditions

Use for TianJi revenue, payment, Stripe, Supabase, checkout, webhook, entitlement, masked evidence, Go/No-Go, staging launch gate, or monetization safety tasks.

## L1 Binding Rule

Before any revenue operation continues:

1. read the final verdict from `ORCHESTRATOR_GATE_DECISION.json`.
2. confirm the requested operation is inside the approved scope.
3. continue only when the decision is `conditional_go` for that bounded scope or `execution_go=true`.
4. if the decision is missing, stale, `no_go`, or `plan-only`, stop revenue execution and refresh the orchestrator decision first.

## Required Pre-Bind Chain

`Human Evidence -> human-evidence-intake-check -> orchestrator-decision-refresh -> tianji-revenue-gate`

## Inputs

- `ORCHESTRATOR_GATE_DECISION.json`
- masked revenue evidence
- validator summaries
- sanitized environment readiness summaries
- approval scope

## Outputs

- Revenue Evidence verdict: Go / Conditional Go / No-Go
- missing evidence list
- safety status
- next human-only action or safe command

## Key Files

- `ORCHESTRATOR_GATE_DECISION.json`
- `.ai/validate-tianji-love-masked-evidence.mjs`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/human-evidence-intake-check.md`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/orchestrator-decision-refresh.md`

## Compliance Constraints

- No live Stripe.
- No production Supabase.
- No production deploy.
- No real payment.
- No plaintext secrets.
- No `.env` staging or printing.
- No revenue execution when approval is only `plan-only`.
