# Skill: tianji-revenue-gate

## Priority

High

## Status And Authority

- status: observed-local skill summary
- source: `C:\Users\Administrator\.agents\skills\tianji-revenue-gate\SKILL.md`
- authority: revenue safety and masked evidence readiness review

## Trigger Conditions

- Revenue, payment, checkout, webhook, entitlement, or monetization safety work is in scope.
- Stripe, Supabase, masked evidence, Go/No-Go, staging launch gate, or paid funnel work is mentioned.
- A revenue operation is requested after an orchestrator decision refresh.

## Inputs

- final `ORCHESTRATOR_GATE_DECISION.json`
- masked revenue evidence
- validator summaries
- sanitized environment readiness summaries
- approval scope

## Outputs

- Revenue Evidence verdict: Go / Conditional Go / No-Go
- missing evidence list
- safety status
- next human-only action or safe command

## Error Handling

- If final decision is missing, stale, `no_go`, or `plan-only`, stop revenue execution.
- If `execution_go=false` and no bounded `conditional_go` applies, stop revenue execution.
- If masked evidence is missing, return No-Go.
- If live Stripe, production Supabase, production deploy, real payment, or plaintext secret is detected, stop and mark No-Go.

## Compliance Constraints

- No live Stripe.
- No production Supabase.
- No production deploy.
- No real payment.
- No plaintext secrets.
- No `.env` staging or printing.
- No revenue execution when approval is only `plan-only`.

## Integration Points

- `ORCHESTRATOR_GATE_DECISION.json`
- `.ai/validate-tianji-love-masked-evidence.mjs`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/human-evidence-intake-check.md`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/orchestrator-decision-refresh.md`

## Post-Run Required Records

- Record Revenue Evidence verdict in the relevant Review Packet.
- Record missing evidence as explicit blockers.
- If a revenue blocker repeats, update the failure case library.
