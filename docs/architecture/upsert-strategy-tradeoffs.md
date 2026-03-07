# Upsert Strategy Trade-offs

Date: 2026-03-05

## Strategies

1. `Merge` (SQL Server `MERGE` statement)
2. `UpdateThenInsert` (per-row `UPDATE`; if no match then `INSERT`)

## Correctness

- Both strategies are expected to produce the same final table state for identical input and key fields.
- `Merge` uses set-based operations and can be efficient for large batches.
- `UpdateThenInsert` is easier to reason about and debug at row level.

## Performance

- `Merge`: typically better throughput on larger batches due to set-based execution.
- `UpdateThenInsert`: potentially slower due to row-by-row operations and more round-trips/commands.

## Locking and Concurrency

- `Merge`: compact SQL but can be sensitive under high concurrency depending on workload and indexing.
- `UpdateThenInsert`: explicit control path; potentially more lock events due to multiple statements.

## Known Behavior (Parallel Runs)

- `UpdateThenInsert` can be race-condition sensitive under concurrent writers (session A and B both observe "no row", then both try `INSERT`).
- Operational guardrail: enforce a unique constraint/index on business key columns.
- If a duplicate race still occurs, SQL Server raises a constraint violation and SyncForge follows configured constraint strategy (`FailFast` or `SkipRow`).
- For high-concurrency scenarios, prefer stronger transactional isolation/locking patterns or keep `Merge` as default.

## Maintainability

- `Merge`: concise but harder to troubleshoot in edge cases.
- `UpdateThenInsert`: longer code path but easier to inspect and instrument.

## Recommendation

- Default: `Merge` for MVP throughput.
- Fallback option: `UpdateThenInsert` for environments requiring simpler operational debugging.
