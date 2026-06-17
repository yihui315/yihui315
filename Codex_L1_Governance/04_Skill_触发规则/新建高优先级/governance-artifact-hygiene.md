# Skill: governance-artifact-hygiene

## Priority

Medium

## Status And Authority

- status: active L1 governance skill for read-only dry-run planning
- authority: read-only artifact inventory and archive planning by default
- not allowed: deleting, moving, or archiving files without explicit approval

## Script Support

- script: `Codex_L1_Governance/scripts/governance-artifact-hygiene.ps1`
- default mode: dry-run / plan-only
- output: `artifact_hygiene_reports/Archive_Plan_YYYY-MM-DD.md`
- verified behavior: generates a Markdown archive plan without moving, deleting, compressing, or archiving files

## Trigger Conditions

- `.ai/artifacts`, screenshots, logs, mcp outputs, browser captures, or validator output directories grow significantly.
- Weekly health check requests artifact hygiene.
- `round-closeout-validator` finds stale or duplicated governance artifacts.
- A project handoff cannot identify which artifacts are current.

## Inputs

- target directory list
- optional current `ORCHESTRATOR_GATE_STATE.json`
- optional Review Packet path
- optional artifact retention policy

## Outputs

- Archive Plan
- keep list
- archive candidate list
- delete candidate list as proposal only
- dry-run commands
- manual review notes
- `Archive_Plan_YYYY-MM-DD.md`

## Dry-Run Command Templates

Inventory only:

```powershell
Get-ChildItem -LiteralPath <artifact-dir> -Recurse -File |
  Select-Object FullName, Length, LastWriteTime |
  Sort-Object LastWriteTime
```

Archive candidates older than 90 days:

```powershell
$cutoff = (Get-Date).AddDays(-90)
Get-ChildItem -LiteralPath <artifact-dir> -Recurse -File |
  Where-Object { $_.LastWriteTime -lt $cutoff } |
  Select-Object FullName, Length, LastWriteTime
```

Size summary:

```powershell
Get-ChildItem -LiteralPath <artifact-dir> -Recurse -File |
  Measure-Object -Property Length -Sum
```

## Error Handling

- If a target directory is missing, record `missing` and continue.
- If a path is outside the intended workspace, stop and return `blocked: path_outside_scope`.
- If a file appears secret-shaped, stop and return `blocked: possible_secret_exposure`.
- If archive/delete is requested without explicit approval, output a dry-run plan only.

## Compliance Constraints

- Do not read `.env` files or raw secret files.
- Do not delete, move, compress, or archive files by default.
- Do not treat cleanup as evidence validation.
- Keep masked evidence and current gate artifacts available until the relevant gate is closed.

## Integration Points

- `Codex_L1_Governance/05_Agent_与_Worker_边界/AGENTS.md`
- `Codex_L1_Governance/04_Skill_触发规则/新建高优先级/round-closeout-validator.md`
- `Codex_L1_Governance/REVIEW_PACKET_Master.md`

## Post-Run Required Records

- Append Archive Plan summary to the relevant Review Packet.
- If L1-level hygiene rules changed, update `REVIEW_PACKET_Master.md`.
- Record durable rule/template changes in `CHANGELOG.md`.
