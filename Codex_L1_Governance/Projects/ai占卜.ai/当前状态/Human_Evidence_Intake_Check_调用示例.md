# human-evidence-intake-check Invocation Example

## Purpose

This file shows how ai占卜.ai should run the L1 evidence intake checker after a real Human Operator updates `当前_Evidence_Gate_状态.md`.

## Current Safe Command

```powershell
& .\Codex_L1_Governance\scripts\human-evidence-intake-check.ps1 `
  -EvidenceFile ".\Codex_L1_Governance\Projects\ai占卜.ai\当前状态\当前_Evidence_Gate_状态.md" `
  -Json
```

## Expected Current Result

As of 2026-06-20, the expected result is still:

- `status=blocked`
- `present_yes=0`
- `present_no=10`
- missing `submitted_by`
- missing `role`
- missing `submitted_at`
- missing `verified_environment`

## When To Rerun

Rerun only after a real Human Operator completes the Evidence Gate file with masked artifacts.

Do not rerun to force a pass. The script is designed to preserve blockers when evidence is incomplete.

## Decision Boundary

Even if this script returns a non-blocked result later, it does not make the final `real_go` decision. It only allows the evidence package to proceed to orchestrator review.
