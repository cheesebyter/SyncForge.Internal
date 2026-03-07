# Connector Capability Matrix

## Matrix

| Connector | Source | Target | Formats | Notes / Limits | Auth |
| --- | --- | --- | --- | --- | --- |
| CSV | Yes | No | CSV | Streaming via CsvHelper; header required | n/a |
| Excel (XLSX) | Yes | No | XLSX | First sheet by default; optional `sheetName`; guardrails: `maxRows`, `maxFileSizeBytes` | n/a |
| MSSQL | No | Yes | Tabular records | `InsertOnly`, `UpsertByKey`, `Replace`; batch writes; parameterized SQL | connection string |
| REST | Yes | Yes | JSON | Source: array or `$.items`; Target: POST per record or batch mode; retries for 5xx | headers + `${ENV:...}` |
| JSONL (builtin) | Yes | Yes | JSON Lines | Local helper connector in CLI runtime | n/a |

## REST Details

- Source payloads:
  - `[{...}, {...}]`
  - `{ "items": [{...}] }` with `jsonPath: $.items`
- Source expects `application/json`.
- Pagination is intentionally not implemented in 0.1.0.
- Target behavior:
  - `2xx` success
  - `4xx` fail-fast
  - `5xx` retry (3 attempts, backoff)

## Excel Details

- Header row is mandatory.
- Mapped source fields must exist in header.
- Missing sheet or missing header column fails fast with clear error.
- Reader uses forward-only OpenXmlReader traversal for better large-file behavior.

## Examples

- `examples/jobs/job-xlsx-to-mssql-upsert-docker.json`
- `examples/jobs/job-rest-to-mssql-upsert.json`
- `examples/jobs/job-csv-to-rest-post.json`
