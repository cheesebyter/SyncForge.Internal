# THIRD-PARTY NOTICES

This project uses the following open-source components:

| Package | License | Used in |
| --- | --- | --- |
| CsvHelper | MIT | `src/SyncForge.Plugin.Csv` |
| Microsoft.Data.SqlClient | MIT | `../SyncForge.Plugin.MsSql` |
| DocumentFormat.OpenXml | MIT | `src/SyncForge.Plugin.Excel` |
| Serilog | Apache-2.0 | `src/SyncForge.Cli` |
| Serilog.Sinks.Console | Apache-2.0 | `src/SyncForge.Cli` |
| Serilog.Sinks.File | Apache-2.0 | `src/SyncForge.Cli` |
| Serilog.Formatting.Compact | Apache-2.0 | `src/SyncForge.Cli` |
| Microsoft.Data.Sqlite | MIT | `src/SyncForge.Infrastructure.Persistence` |
| xUnit | Apache-2.0 | `src/SyncForge.Plugin.Rest.Tests` |

Notes:
- No paid-only runtime dependencies are required for MVP/0.1.0.
- EPPlus is intentionally not used.
