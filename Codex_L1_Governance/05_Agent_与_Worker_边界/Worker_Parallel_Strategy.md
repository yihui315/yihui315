# Worker Parallel Strategy

## Safe Parallel Lanes

| Lane | Can run in parallel with | Merge requirement |
| --- | --- | --- |
| Evidence inventory | Revenue evidence inventory, docs indexing | Must reconcile shared artifact paths |
| Secret-shape scan | 12D scan, docs lint | Must finish before evidence is marked reviewable |
| 12D baseline scan | Failure-case drafting, project map update | Must cite inspected sources |
| Review packet scoring | Gate decision refresh preparation | Must wait for final gate statuses |
| Template drafting | Existing file inspection | Must avoid overwriting project-specific facts |

## Do Not Parallelize

- Two workers editing the same canonical decision file.
- Gate decision refresh before validators complete.
- Evidence pass/fail decisions before masking review.
- Production or revenue execution without explicit approval.

## Merge Protocol

1. Collect worker outputs as separate sections.
2. Normalize file paths and dates.
3. Resolve conflicts conservatively.
4. Update gate state only from validated evidence.
5. Record skipped checks and uncertain assumptions.

## Worker Output Minimum

Each worker must return:

- objective
- inspected files or tools
- result
- confidence level
- risks
- suggested next action
