# Archive Plan 2026-06-20

## Metadata

| Field | Value |
| --- | --- |
| skill | governance-artifact-hygiene |
| generated_at | `2026-06-20T20:56:52` |
| root_path | `C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance` |
| older_than_days | `90` |
| cutoff | `2026-03-22T20:56:52` |
| dry_run | `True` |
| status | `pass` |

## Compliance Reminder

- This report is metadata-only and dry-run by default.
- The script does not move, delete, compress, or archive files.
- Review candidate paths manually before running any real command.
- Do not include .env, secrets, provider credentials, payment data, or business source code in hygiene operations.

## Target Directory Inventory

| Target | Resolved path | Status | Files | Directories | Candidate files | Candidate directories | Total size |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| `artifacts` | `artifacts` | `missing` | 0 | 0 | 0 | 0 | 0 B |
| `screenshots` | `screenshots` | `missing` | 0 | 0 | 0 | 0 | 0 B |
| `logs` | `logs` | `missing` | 0 | 0 | 0 | 0 | 0 B |
| `mcp` | `mcp` | `missing` | 0 | 0 | 0 | 0 | 0 B |

## Archive Candidate Summary

- total_candidate_items: `0`
- displayed_candidate_items: `0`
- max_entries: `500`

No archive candidates found for the configured threshold.

## Sensitive-Shaped Path Checks

- sensitive_shaped_path_hits: `0`

## Dry-Run Command

```powershell
& 'C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\scripts\governance-artifact-hygiene.ps1' -RootPath 'C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance' -TargetDirectories @('artifacts', 'screenshots', 'logs', 'mcp') -OlderThanDays 90 -DryRun:$true
```

## Real Execution Command Template

Only run after manual review and explicit approval. Edit the candidate path list before execution.

```powershell
$archiveRoot = 'C:\Users\Administrator\Documents\codex进化助手\Codex_L1_Governance\.archive\governance-artifacts\2026-06-20'
New-Item -ItemType Directory -Force -Path $archiveRoot | Out-Null
# For each approved candidate only:
Move-Item -LiteralPath '<approved-candidate-path>' -Destination $archiveRoot
```

## Issues

- none
