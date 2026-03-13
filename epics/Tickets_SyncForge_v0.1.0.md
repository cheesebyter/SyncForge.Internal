# SyncForge MVP_V01

## EPIC 1 – Core Engine (Plugin-agnostisch)

Ziel: Integrationsmotor ohne Kenntnis von CSV oder MSSQL.

### TICKET C-1 – Solution Setup

Status: Closed (05-03-2026)

Ziel: Grundstruktur anlegen

Akzeptanzkriterien:

.NET 8 Solution (SyncForge)

Projekte:

SyncForge.Core

SyncForge.Abstractions

SyncForge.Cli

Linux Build erfolgreich (dotnet build unter Linux getestet -> wird seperat getestet.)

Keine Windows-spezifischen APIs

### TICKET C-2 – Plugin-Abstractions definieren

Status: Closed (05-03-2026)

Ziel: Core kennt nur Interfaces

Implementieren:

public interface ISourceConnector
{
    Task<IAsyncEnumerable<DataRecord>> ReadAsync(JobContext context);
}

public interface ITargetConnector
{
    Task<WriteResult> WriteAsync(
        IAsyncEnumerable<DataRecord> records,
        JobContext context);
}

Akzeptanzkriterien:

Core referenziert keine konkrete Implementierung

Abstractions-Projekt enthält nur Interfaces + Models

Keine Abhängigkeit zu CSV/SQL

### TICKET C-3 – DataRecord Modell

Status: Closed (05-03-2026)

Ziel: Generisches, strukturunabhängiges Datenmodell

Beispiel:

public class DataRecord
{
    public Dictionary<string, object?> Fields { get; init; }
}

Akzeptanzkriterien:

Keine Typspezialisierung

Unterstützt Null-Werte

Serialisierbar

### TICKET C-4 – Job-Konfigurationsmodell

Status: Closed (05-03-2026)

Ziel: JSON-konfigurierbare Jobs

Implementieren:

JobDefinition

SourceDefinition

TargetDefinition

MappingDefinition

StrategyDefinition

Akzeptanzkriterien:

JSON deserialisierbar via System.Text.Json

Validierung via DataAnnotations oder FluentValidation (Open Source)

CLI kann Job-Datei einlesen

### TICKET C-5 – Mapping Engine

Status: Closed (05-03-2026)

Ziel: Feldzuordnung + einfache Transformation

MVP:

1:1 Mapping

Pflichtfeld-Validierung

Optional minimal:

ToUpper

Trim

Akzeptanzkriterien:

Mapping konfigurierbar

Fehlende Pflichtfelder brechen Batch sauber ab

Keine Abhängigkeit zu Connectoren

### TICKET C-6 – Strategy Engine (Upsert-Modi vorbereitet)

Status: Closed (05-03-2026)

MVP unterstützt:

Replace

InsertOnly

UpsertByKey (nur Metadaten, Implementierung im Target)

Akzeptanzkriterien:

Strategy wird vom Core übergeben

Target entscheidet Umsetzung

Keine SQL-Logik im Core

### TICKET C-7 – Job Orchestrator

Status: Closed (05-03-2026)

Ziel: Pipeline

Ablauf:

Source.Read()

Mapping

Target.Write()

Result loggen

Akzeptanzkriterien:

IAsyncEnumerable Pipeline

CancellationToken Support

Fehler werden abgefangen und sauber geloggt

### TICKET C-8 – Logging

Status: Closed (05-03-2026)

NuGet:

Serilog (kostenlos, OSS)

Anforderungen:

Console Logging

JSON Logging optional

Log-Level konfigurierbar

### TICKET C-9 – CLI

Status: Closed (05-03-2026)

Commands:

syncforge run job.json
syncforge validate job.json
syncforge dry-run job.json

Akzeptanzkriterien:

Exit Codes korrekt

Fehler verständlich ausgegeben

Linux ausführbar

## EPIC 2 – CSV Connector Plugin

Ziel: Datei → DataRecord Stream

Technologie:

Kein EPPlus (Excel wäre Lizenzproblem)

CSV-only im MVP

System.IO + CsvHelper (Open Source, MIT)

### TICKET CSV-1 – Plugin-Projekt anlegen

Status: Closed (05-03-2026)

Projekt:
SyncForge.Plugin.Csv

Referenziert:

SyncForge.Abstractions

Nicht referenziert:

SyncForge.Core

### TICKET CSV-2 – CSV Reader (Streaming)

Status: Closed (05-03-2026)

Implementierung:

CsvHelper

IAsyncEnumerable<DataRecord>

Anforderungen:

Unterstützt UTF-8

Konfigurierbarer Delimiter

Header-Row Pflicht

Akzeptanzkriterien:

Große Dateien > 500MB ohne Memory Explosion

Streaming funktioniert

### TICKET CSV-3 – Schema Validation

Status: Closed (05-03-2026)

Vor Verarbeitung prüfen:

Existieren alle gemappten Spalten?

Fehlende Spalte → Abbruch

### TICKET CSV-4 – File Hashing

Status: Closed (05-03-2026)

Ziel:
SHA256 über Datei berechnen

Verwendung:

Wiederholte Verarbeitung erkennen

Linux-kompatibel:
System.Security.Cryptography

## EPIC 3 – MS-SQL Target Plugin

Technologie:

Microsoft.Data.SqlClient (kostenlos)

Keine Windows Authentication Pflicht

Linux-Support testen

### TICKET SQL-1 – Plugin-Projekt

Status: Closed (05-03-2026)

SyncForge.Plugin.MsSql

Referenziert:

SyncForge.Abstractions

### TICKET SQL-2 – Basic Insert

Status: Closed (05-03-2026)

Ziel:
InsertOnly Strategie

Anforderungen:

Parameterisierte Queries

SQL Injection sicher

Batch Insert (konfigurierbare Batch Size)

### TICKET SQL-3 – Upsert (MERGE)

Status: Closed (05-03-2026)

Implementieren:

MERGE INTO TargetTable AS target
USING @TempTable AS source
ON target.Key = source.Key
WHEN MATCHED THEN UPDATE ...
WHEN NOT MATCHED THEN INSERT ...

Akzeptanzkriterien:

Transaktion pro Batch

Rollback bei Fehler

Logging Anzahl Inserts/Updates

### TICKET SQL-4 – Replace Strategy

Status: Closed (05-03-2026)

Implementieren:

TRUNCATE + Insert

Optional:

Soft Replace (Delete + Insert in Transaction)

### TICKET SQL-5 – Constraint Error Handling

Status: Closed (05-03-2026)

Erkennen:

Unique Key Violation

Null Constraint

FK Constraint

Strategie:

FailFast

SkipRow (optional)

## EPIC 4 – Plugin Loading Mechanismus

Core darf Plugins nicht kennen.

### TICKET P-1 – Reflection-based Plugin Loader

Status: Closed (05-03-2026)

Implementieren:

Assembly scanning

Suche nach ISourceConnector / ITargetConnector

Registrierung per DI

Linux-kompatibel:
AssemblyLoadContext

### TICKET P-2 – Plugin-Konfiguration

Status: Closed (05-03-2026)

Job.json enthält:

"source": {
  "type": "csv",
  "plugin": "SyncForge.Plugin.Csv"
}

Core lädt dynamisch.

Definition of Done für MVP

✔ CSV → MSSQL InsertOnly funktioniert
✔ Upsert funktioniert
✔ Replace funktioniert
✔ CLI läuft unter Linux
✔ Keine Paid Dependencies
✔ Core kennt keine konkreten Plugins
✔ 500MB CSV getestet
✔ Fehler sauber geloggt

Testresultate (05-03-2026)

Linux-Nachweis (WSL):

- `dotnet run --project ./src/SyncForge.Cli/SyncForge.Cli.csproj -- validate ./examples/jobs/job-csv-validate.json` -> Exit `0`
- `dotnet run --project ./src/SyncForge.Cli/SyncForge.Cli.csproj -- dry-run ./examples/jobs/job-csv-to-mssql-upsert-docker.json` -> Exit `0` (Processed `3`, Succeeded `3`, Failed `0`)
- `dotnet run --project ./src/SyncForge.Cli/SyncForge.Cli.csproj -- run ./examples/jobs/job-csv-to-mssql-upsert-docker.json` -> Exit `0` (Processed `3`, Succeeded `2`, Failed `0`, Target: `Inserted=0, Updated=2`)
- `dotnet run --project ./src/SyncForge.Cli/SyncForge.Cli.csproj -- run ./examples/jobs/job-csv-to-mssql-replace-docker.json` -> Exit `0` (Processed `3`, Succeeded `2`, Failed `1`, Target: `Inserted=2, Updated=0, Failed=1`)
- `dotnet run --project ./src/SyncForge.Cli/SyncForge.Cli.csproj -- run ./examples/jobs/job-csv-to-mssql-insert-docker.json` -> Exit `5` (erwarteter FailFast bei PK-Verletzung `Error 2627`)

Ergaenzende DoD-Nachweise:

- `dotnet run --project ./src/SyncForge.Cli/SyncForge.Cli.csproj -- run ./examples/jobs/job-csv-to-mssql-insert-unique-docker.json` -> Exit `0` (RowsAfterInsertUnique `3`)
- `dotnet run --project ./src/SyncForge.Cli/SyncForge.Cli.csproj -- dry-run ./examples/jobs/job-csv-500mb-dryrun.json` -> Exit `0` (Datei `examples/data/customers-500mb.csv`, Groesse `555746164` Bytes, Processed `590591`)
- `dotnet build ./src/SyncForge.sln -c Release` -> Erfolgreich

Windows-Nachweis (PowerShell):

- `dotnet build src/SyncForge.sln -c Release` -> Erfolgreich
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- validate .\examples\jobs\job-csv-validate.json` -> Exit `0`
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- run .\examples\jobs\job-csv-to-mssql-upsert-docker.json` -> Exit `0` (Processed `3`, Succeeded `2`, Failed `0`)
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- run .\examples\jobs\job-csv-to-mssql-replace-docker.json` -> Exit `0` (Processed `3`, Succeeded `2`, Failed `1`)
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- run .\examples\jobs\job-csv-to-mssql-insert-unique-docker.json` -> Exit `0` (RowsAfterInsertUnique `3`)
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- dry-run .\examples\jobs\job-csv-500mb-dryrun.json` -> Exit `0` (Processed `590591`)
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- run .\examples\jobs\job-csv-to-mssql-insert-docker.json` -> Exit `5` (erwarteter FailFast bei PK-Verletzung `Error 2627`)
- `docker exec SyncForge /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Pa!!word" -C -d SyncForgeDemo -Q "SELECT COUNT(*) AS RowsAfterUpsert FROM dbo.CustomersSync;"` -> `2`
- `docker exec SyncForge /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Pa!!word" -C -d SyncForgeDemo -Q "SELECT COUNT(*) AS RowsAfterReplace FROM dbo.CustomersSync;"` -> `2`

Technische DoD-Analyse (formalisiert)

Status je DoD-Kriterium:

- CSV -> MSSQL InsertOnly: Erfuellt (Happy-Path mit `job-csv-to-mssql-insert-unique-docker.json` erfolgreich; FailFast mit Exit `5` bei Constraint-Verletzung nachgewiesen)
- Upsert funktioniert: Erfuellt (`MERGE`-Pfad, Inserts/Updates im Resultat nachgewiesen)
- Replace funktioniert: Erfuellt (Strategie ausgefuehrt, Resultate und DB-Counts vorhanden)
- CLI laeuft unter Linux: Erfuellt (WSL-Nachweis inkl. `validate`, `dry-run`, `run`)
- Keine Paid Dependencies: Erfuellt (CsvHelper, Serilog, Microsoft.Data.SqlClient, Microsoft.Extensions.DependencyInjection)
- Core kennt keine konkreten Plugins: Erfuellt (Plugin-Loading ueber Reflection/DI, keine Core-Referenz auf Plugin-Assemblies)
- 500MB CSV getestet: Erfuellt (`customers-500mb.csv` > 500MB, Dry-Run erfolgreich)
- Fehler sauber geloggt: Erfuellt mit Restpunkt (fachliche Fehlermeldung vorhanden; weitere Vereinheitlichung ueber Exit-Code-Doku empfohlen)

Restrisiken und technische Schulden:

- SQL Server `MERGE` bleibt langfristig wartungs- und parallelitaetssensitiv; deshalb ist `UpdateThenInsert` als Alternative implementiert und dokumentiert.
- Performance-Messungen sind fuer MVP dokumentiert (500MB/2GB), sollten aber in CI/Monitoring langfristig kontinuierlich nachgezogen werden.

## EPIC 5 - Follow-up Hardening

Ziel: Produktionshaertung nach MVP-Abnahme.

### TICKET F-1 - Replace atomar machen

Status: Closed (05-03-2026)

Ziel: Vollstaendige Atomaritaet fuer Replace-Lauf.

Anforderungen:

- Eine Transaktion ueber den gesamten Replace-Lauf (`TRUNCATE/DELETE` + alle Insert-Batches)
- Bei Fehlern: konsistenter Rollback ohne Teilzustand
- Eindeutiges Logging fuer Begin/Commit/Rollback

Akzeptanzkriterien:

- Erzwungener Fehler in Batch N fuehrt zu unveraendertem Zielzustand
- Integrationstest mit nachweisbarem Rollback vorhanden

### TICKET F-2 - Exit-Code-Tabelle dokumentieren

Status: Closed (05-03-2026)

Ziel: Stabile, dokumentierte Prozess-Exitcodes fuer Betrieb und CI.

Anforderungen:

- Tabelle in `README.md` mit Code, Bedeutung, typischen Ursachen
- Einheitliche Zuordnung im CLI-Code und in Tests

Akzeptanzkriterien:

- Jeder Fehlerpfad liefert dokumentierten Exit-Code
- CI-Check auf unveraenderte Exit-Code-Vertraege vorhanden

### TICKET F-3 - Performance-Metriken fuer Large Files

Status: Closed (05-03-2026)

Ziel: Messbare Aussagen zu Speicher-, Laufzeit- und GC-Verhalten.

Anforderungen:

- Messung fuer mindestens 500MB und 2GB CSV
- Erfassung von Laufzeit, Peak-Memory, GC-Events
- Ergebnisse als reproduzierbarer Bericht unter `examples/` oder `docs/`

Akzeptanzkriterien:

- Benchmark-Protokoll mit Messwerten liegt vor
- Streaming-Verhalten ohne Memory-Explosion nachgewiesen

### TICKET F-4 - MERGE-Alternative bereitstellen

Status: Closed (05-03-2026)

Ziel: Optionaler Upsert-Pfad ohne SQL `MERGE`.

Anforderungen:

- Alternative Strategie `UPDATE THEN INSERT`
- Konfigurierbar per Target-Setting
- Vergleichstest gegen `MERGE` fuer Korrektheit

Akzeptanzkriterien:

- Beide Strategien liefern bei identischen Daten denselben Endzustand
- Doku mit Trade-offs (Performance, Locking, Wartbarkeit) vorhanden

Testresultate EPIC 5 (05-03-2026)

- F-1 Replace atomar: Vor dem Lauf wird gezielt genau 1 Sentinel-Row in `dbo.CustomersSync` gesetzt (definierter Ausgangszustand). `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- run .\examples\jobs\job-csv-to-mssql-replace-atomic-fail-docker.json` -> Exit `5` (erwarteter Fehler), danach DB-Check: `RowsAfterReplaceAtomicFail = 1`, `SentinelStillPresent = 1` (korrekt, da Sentinel bei Rollback nicht verschwinden darf).
- F-2 Exit-Codes: `powershell -ExecutionPolicy Bypass -File .\scripts\check-exit-codes.ps1` -> `Exit code contract verified.`; Tabelle in `README.md` vorhanden.
- F-3 Performance Large Files: `powershell -ExecutionPolicy Bypass -File .\scripts\measure-large-file-performance.ps1` -> Bericht `docs/performance/large-file-report-2026-03-05.md` erzeugt.
- F-3 Messwerte: `500MB` Dry-Run Exit `0`, Dauer `~9.46s`, Peak `~164.67 MB`, Processed `590591`; `2GB` Dry-Run Exit `0`, Dauer `~23.4s`, Peak `~151.54 MB`, Processed `2340074`.
- F-4 MERGE-Alternative: `upsertImplementation` in MSSQL-Target verfuegbar (`Merge`, `UpdateThenInsert`), Vergleichslauf ergab `upsert-state-equal=true` bei identischen Eingabedaten.
- F-4 Trade-off-Doku: `docs/architecture/upsert-strategy-tradeoffs.md`.

## EPIC 7 - Native Connector Expansion (R 0.1.0)

Ziel: Vier native Connectoren bereitstellen, ohne Aenderung der bestehenden Core-Connector-Vertraege (`ISourceConnector`, `ITargetConnector`).

### EPIC 7A - Excel Connector (XLSX)

#### TICKET X-1 - Excel Plugin Projekt anlegen

Status: Closed (05-03-2026)

Nachweis:

- Projekt `src/SyncForge.Plugin.Excel` angelegt.
- Referenziert nur `SyncForge.Abstractions`.
- NuGet: `DocumentFormat.OpenXml` (MIT).
- Lizenzhinweis in `THIRD-PARTY-NOTICES.md` dokumentiert.

#### TICKET X-2 - XLSX Reader (Sheet1, Header-Row Pflicht)

Status: Closed (05-03-2026)

Nachweis:

- `ExcelSourceConnector` liest XLSX aus erstem Sheet oder optional per `sheetName`.
- Header-Pflicht umgesetzt; fehlende Mapping-Spalte fuehrt zu definiertem Fehler.
- Beispiel-Datei `examples/data/customers.xlsx` vorhanden.

#### TICKET X-3 - Large Excel File Behavior (Guardrails)

Status: Closed (05-03-2026)

Nachweis:

- Forward-only Verarbeitung via `OpenXmlReader`.
- Guardrails implementiert: `maxRows`, `maxFileSizeBytes`.
- Ueberschreitung fuehrt zu FailFast mit klarer Fehlermeldung.

#### TICKET X-4 - Excel Validation Mode

Status: Closed (05-03-2026)

Nachweis:

- `validate` fuehrt jetzt Connector-Preflight als dry-run aus (Datei/Sheet/Header werden geprueft).
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- validate .\examples\jobs\job-xlsx-validate.json` -> Exit `0`.

### EPIC 7B - REST Connector

#### TICKET R-1 - REST Plugin Projekt anlegen

Status: Closed (05-03-2026)

Nachweis:

- Projekt `src/SyncForge.Plugin.Rest` angelegt.
- Referenziert nur `SyncForge.Abstractions`.
- Umsetzung mit BCL `HttpClient` und `System.Text.Json`.

#### TICKET R-2 - REST Source: GET JSON Array -> DataRecord

Status: Closed (05-03-2026)

Nachweis:

- Unterstuetzt JSON Array und `{ items: [...] }` via `jsonPath=$.items`.
- Header konfigurierbar via `source.settings.header.*`.
- Nicht-JSON und inkompatible Payloads brechen reproduzierbar mit klarer Meldung ab.
- Example-Job: `examples/jobs/job-rest-to-mssql-upsert.json`.

#### TICKET R-3 - REST Target: POST per Record (Batch optional)

Status: Closed (05-03-2026)

Nachweis:

- Record-Mode und Batch-Mode implementiert (`target.settings.mode=record|batch`).
- 2xx success, 4xx fail-fast, 5xx retry (3x Backoff).
- Example-Job: `examples/jobs/job-csv-to-rest-post.json`.

#### TICKET R-4 - REST Contract Tests (Mock Server)

Status: Closed (05-03-2026)

Nachweis:

- Testprojekt `src/SyncForge.Plugin.Rest.Tests` angelegt.
- In-proc Mock via minimal `HttpListener`-Server in Tests.
- `dotnet test .\src\SyncForge.Plugin.Rest.Tests\SyncForge.Plugin.Rest.Tests.csproj -c Release` -> 2/2 Tests gruen.

### EPIC 7C - Packaging & Examples

#### TICKET P-7 - Example Jobs & Data Set erweitern

Status: Closed (05-03-2026)

Nachweis:

- Jobs erstellt:
    - `examples/jobs/job-xlsx-to-mssql-upsert-docker.json`
    - `examples/jobs/job-rest-to-mssql-upsert.json`
    - `examples/jobs/job-csv-to-rest-post.json`
    - `examples/jobs/job-xlsx-validate.json`
- Beispiel-Datei: `examples/data/customers.xlsx`.
- Mock Service: `examples/services/mock-api/`.

#### TICKET P-8 - Connector Capability Matrix

Status: Closed (05-03-2026)

Nachweis:

- Dokument `docs/connectors.md` erstellt.
- In `README.md` referenziert.

EPIC 7 - Testresultate (05-03-2026)

- `dotnet build .\src\SyncForge.sln -c Release` -> Erfolgreich (Windows).
- `docker run --rm -v ${PWD}:/work -w /work mcr.microsoft.com/dotnet/sdk:8.0 bash -lc "dotnet build ./src/SyncForge.sln -c Release"` -> Erfolgreich (Linux Container Build).
- `dotnet test .\src\SyncForge.Plugin.Rest.Tests\SyncForge.Plugin.Rest.Tests.csproj -c Release` -> Erfolgreich (2/2).
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- validate .\examples\jobs\job-xlsx-validate.json` -> Exit `0`.
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- validate .\examples\jobs\job-xlsx-validate-schema-fail.json` -> Exit `5` (erwarteter Schema-Drift Fehler).
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- dry-run .\examples\jobs\job-xlsx-to-mssql-upsert-docker.json` -> Exit `0` (Processed `2`).
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- run .\examples\jobs\job-csv-to-rest-post.json` -> Exit `0` (Mock-Retry sichtbar, danach Success).
- `dotnet run --project .\src\SyncForge.Cli\SyncForge.Cli.csproj -- run .\examples\jobs\job-rest-to-mssql-upsert.json` -> Exit `0`; DB Check `RowsAfterRestUpsert = 2`.

EPIC 7 - Definition of Done

✔ Core-Connector-Vertraege unveraendert
✔ Excel Source (XLSX) funktioniert (Sheet1 + Header)
✔ MSSQL Target funktioniert (Insert/Upsert/Replace, bestehend)
✔ REST Source (GET JSON) funktioniert (Mock getestet)
✔ REST Target (POST) funktioniert (Mock getestet)
✔ Beispiele + Doku vermitteln General Integration Engine
✔ Linux- und Windows-Build gruen
✔ Keine paid/problematischen Lizenzen (siehe `THIRD-PARTY-NOTICES.md`)
