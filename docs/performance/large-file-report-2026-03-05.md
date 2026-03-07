# Large File Performance Report (2026-03-05)

Environment:
- OS: Windows (PowerShell)
- Runtime mode: Native Windows host (kein WSL)
- CPU: AMD Ryzen 5 4500 6-Core Processor              
- Logical cores: 12
- RAM (total): 47.87 GB
- Command: dotnet run --project ./src/SyncForge.Cli/SyncForge.Cli.csproj -- dry-run <job>
- Measurement: wall-clock duration and peak working set of dotnet process
- SQL activity: Dry-run only, no target write operations executed

CSV characteristics:
- Delimiter: ;
- Columns: 5 (id, name, email, birthDate, payload)
- Generator row shape: 1;sample;sample@example.com;05-03-2026;<payload>
- Average field lengths by design: id=1, name=6, email=18, birthDate=10, payload=900

Data files:
- examples/data/customers-500mb.csv: 555746164 bytes
- examples/data/customers-2gb.csv: 2202009667 bytes

Results:

| Test | Exit | Duration (s) | Peak Working Set (MB) | Processed |
| --- | --- | ---: | ---: | ---: |
| 500MB dry-run | 0 | 10.16 | 165.96 | 590591 |
| 2GB dry-run | 0 | 24.39 | 160.9 | 2340074 |

Observations:
- Both dry-runs completed without process failure.
- Streaming remained stable for large files in this test setup.
- For reproducibility, rerun with scripts/measure-large-file-performance.ps1.
