# Governance Principles

## Non-Negotiable Principles

1. Truth over progress: a blocked gate must stay blocked until the required evidence exists.
2. No fabricated evidence: never forge `submitted_by`, `submitted_at`, screenshots, masked rows, logs, or public visibility.
3. Gate separation: Evidence, Revenue, and Approval gates can move independently.
4. Scope clarity: `plan-only` approval is not execution approval.
5. Least-risk execution: prefer small, reversible, auditable changes.
6. Evidence minimization: store masked evidence and avoid secrets, tokens, private customer data, or production credentials.
7. Problem-driven iteration: every new governance artifact must reduce a real recurring issue.
8. Human accountability: Human Operator fields must be filled by an actual responsible person.

## Decision Language

Use consistent decision words:

- `go`: all required gates for the requested scope pass.
- `no_go`: one or more required gates are blocked or failed.
- `conditional_go`: execution is allowed only inside explicitly listed limits.
- `plan_only`: planning, documentation, or template work is allowed, but live execution remains blocked.

## Evidence Standard

Evidence should answer four questions:

1. Who submitted it?
2. When was it submitted?
3. What environment was verified?
4. What masked artifact proves the claim?

If any answer is unknown, record it as unknown instead of filling a convenient value.
