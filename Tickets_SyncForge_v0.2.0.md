# SyncForge – Roadmap R 0.2.0  
## JSON-First Configurator (UI)

**Release Ziel:**  
SyncForge wird visuell konfigurierbar, ohne die JSON-First-Architektur zu verlassen.  
Keine Lizenzprüfung in 0.2.0. Keine Core-Logik-Duplikation.

---

# EPIC 8 – Configurator Foundation

## UI-1 – Avalonia Projekt Setup
Status: Closed (07-03-2026)

**Ziel:** Cross-Platform Desktop App

- Neues Projekt: `SyncForge.Configurator`
- .NET 8
- Avalonia + MVVM Struktur
- Referenz auf `SyncForge.Core` + `SyncForge.Abstractions`
- Startet unter Windows & Linux

**DoD:**
- App startet stabil
- Leeres Hauptfenster sichtbar

---

## UI-2 – Job File Management
Status: Closed (07-03-2026)

**Ziel:** JSON als First-Class Citizen

- Open job.json
- Save job.json
- Save As
- New job.json

**DoD:**
- JSON wird korrekt geladen & gespeichert
- Ungültiges JSON erzeugt saubere Fehlermeldung
- Kein Absturz bei Fehlern

---

## UI-3 – Core Validation Integration
Status: Closed (07-03-2026)

**Ziel:** UI nutzt Core-Validator

- Button: Validate
- Fehleranzeige mit Details

**DoD:**
- Validierung identisch zu CLI
- Exit-Code-Verhalten bleibt unverändert

### EPIC 8 - Umsetzungsnachweis (07-03-2026)

- Neues Projekt `src/SyncForge.Configurator` erstellt (Avalonia + MVVM Struktur).
- Solution erweitert: `src/SyncForge.sln` enthaelt `SyncForge.Configurator`.
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.
- Runtime Smoke Test: `dotnet run --project .\src\SyncForge.Configurator\SyncForge.Configurator.csproj` gestartet (MainWindow laeuft).
- Job File Management vorhanden: New/Open/Save/Save As mit sauberer JSON-Fehlerbehandlung.
- Core Validation Integration vorhanden: Validate nutzt `JobDefinitionJson` + `JobDefinitionValidator` aus Abstractions/Core-Pfad.

---

# EPIC 9 – Connector Integration

## UI-4 – Connector Discovery
Status: Closed (07-03-2026)

**Ziel:** Dynamische Plugin-Erkennung

- Reflection über Plugin-Ordner
- Source & Target Dropdowns
- Anzeige Connector-Metadaten

**DoD:**
- CSV, Excel, MSSQL, REST werden erkannt
- Keine Hardcodierung

**Nachweis (07-03-2026):**
- Reflection-basierte Discovery in `SyncForge.Configurator` implementiert (`Services/ConnectorDiscoveryService.cs`).
- Scan ueber Plugin-Ordner und `src`-Baum nach `SyncForge.Plugin.*.dll`.
- Dynamische Source-/Target-Dropdowns in der UI (ohne hardcodierte Connector-Liste).
- Connector-Metadatenanzeige (Assembly, Typ, Klasse) integriert.
- Auswahl aktualisiert JSON `source.type`/`source.plugin` bzw. `target.type`/`target.plugin` direkt.
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

## UI-5 – Dynamic Config Panels
Status: Closed (07-03-2026)

**Ziel:** Konfigurationsfelder je Connector dynamisch anzeigen

Beispiele:
- CSV: Path, Delimiter, Encoding
- MSSQL: ConnectionString, Table, Strategy
- REST: URL, Method, Headers

**DoD:**
- UI passt Felder je Plugin an
- JSON wird korrekt erzeugt

**Nachweis (07-03-2026):**
- Dynamische Settings-Panels fuer Source und Target im Configurator hinzugefuegt.
- Panel-Felder werden je Connector-Typ aus Schema-Service geladen (`Services/ConnectorConfigSchemaService.cs`).
- Beispiele umgesetzt:
	- CSV Source: `path`, `delimiter`, `encoding`
	- MSSQL Target: `connectionString`, `table`, `batchSize`, `commandTimeoutSeconds`, `replaceMode`, `constraintStrategy`, `upsertImplementation`
	- REST Source/Target: `url`, `jsonPath`/`mode`, `headers`, `timeoutSeconds`
- Settings sind bidirektional mit JSON synchronisiert (`source.settings` / `target.settings`).
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

## UI-6 – Mapping Grid
Status: Closed (07-03-2026)

**Ziel:** Visuelle Feldzuordnung

- Source-Spalten anzeigen (Preview)
- Target-Spalten manuell definieren
- Pflichtfelder validieren

**DoD:**
- Mapping korrekt in JSON gespeichert
- Validierungsfehler werden angezeigt

**Nachweis (07-03-2026):**
- Source-Preview fuer `csv`, `xlsx` und `jsonl` implementiert (`Services/SourcePreviewService.cs`) inklusive Pfadauflosung relativ zur Job-Datei.
- UI erweitert: Preview-Laden, Vorschau der Source-Spalten, Mapping-Editor mit `SourceField`, `TargetField` und `IsRequired` (`Views/MainWindow.axaml`).
- Mapping-Logik integriert: Add/Remove Rows, bidirektionale Synchronisierung nach JSON `mappings` (`ViewModels/MainWindowViewModel.cs`, `ViewModels/MappingRow.cs`).
- Pflichtfeld-Validierung erweitert: Required-Mappings ohne Source/Target erzeugen valide UI-Fehler in der Validation-Ansicht.
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

# EPIC 10 – Execution & Feedback

## UI-7 – Dry-Run Integration
Status: Closed (07-03-2026)

**Ziel:** Dry-Run aus UI starten

- Start Dry-Run
- Live Log Anzeige
- JSON Summary anzeigen

**DoD:**
- Verhalten identisch zur CLI
- Keine eigene Business-Logik

**Nachweis (07-03-2026):**
- Dry-Run-Start aus Configurator-Toolbar implementiert (`Views/MainWindow.axaml`, `Views/MainWindow.axaml.cs`).
- Configurator nutzt denselben Core-Orchestrator-Pfad mit `dryRun: true` (`Core/Orchestration/IJobOrchestrator`, `JobOrchestrator`) ueber `Services/DryRunExecutionService.cs`.
- Live-Log-Anzeige in UI integriert (ISyncForgeLogger-Adapter auf ObservableCollection `DryRunLogs`).
- JSON-Summary-Anzeige integriert (`DryRunSummaryJson`) mit Kennzahlen zu Job, Dauer, Processed/Succeeded/Failed.
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

## UI-8 – Run Integration
Status: Closed (07-03-2026)

**Ziel:** Produktivlauf aus UI starten

- Fortschrittsanzeige
- Log Anzeige
- Ergebnisübersicht

**DoD:**
- Exit-Code identisch zur CLI
- Fehler korrekt dargestellt

**Nachweis (07-03-2026):**
- Produktivlauf aus dem Configurator gestartet ueber neuen `Run`-Button (`Views/MainWindow.axaml`, `Views/MainWindow.axaml.cs`).
- Ausfuehrung nutzt denselben Core-Orchestrator wie CLI (`IJobOrchestrator.ExecuteAsync`) mit `dryRun: false` und ohne Business-Logik-Duplikation (`Services/DryRunExecutionService.cs`).
- Fortschrittsanzeige integriert: indeterminierter ProgressBar-Status waehrend Lauf (`IsRunInProgress`).
- Lauf-Loganzeige integriert (`RunLogs`) sowie Ergebnisuebersicht als JSON (`RunSummaryJson`) mit Dauer, Processed/Succeeded/Failed und Target-Stats.
- Fehler werden im UI als Status + Logeintrag dargestellt (keine stillen Fehler).
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

## UI-9 – Log Viewer
Status: Closed (07-03-2026)

**Ziel:** Lesbare Log-Ausgabe

- Level Filter
- Search
- Export Funktion

**DoD:**
- Logs korrekt angezeigt
- Keine Performance-Probleme bei großen Logs

**Nachweis (07-03-2026):**
- Dedizierter Log-Viewer in der UI hinzugefuegt mit zentraler Anzeige (`FilteredLogs`) fuer Dry-Run und Run-Logs.
- Level-Filter implementiert (`All`, `INFO`, `WARN`, `ERROR`) und Suchfeld fuer Textfilterung (`SelectedLogLevel`, `LogSearchText`).
- Export-Funktion umgesetzt (SaveFilePicker + Dateiexport der gefilterten Logs) in `Views/MainWindow.axaml.cs` und `ViewModels/MainWindowViewModel.cs`.
- Performance-Schutz fuer grosse Logmengen integriert: begrenzte In-Memory-Historie (`MaxLogEntries = 5000`) und inkrementelles Filtern beim Log-Zufluss.
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

# EPIC 11 – Usability Minimal Layer

## UI-10 – New Job Wizard
Status: Closed (07-03-2026)

**Ziel:** Geführte Erstellung eines neuen Jobs

Schritte:
1. Source auswählen
2. Target auswählen
3. Strategy wählen
4. Basisparameter setzen

**DoD:**
- Wizard erzeugt gültiges JSON
- Keine zusätzliche Logik

**Nachweis (07-03-2026):**
- Neuer gefuehrter Wizard in der Configurator-UI integriert (Toolbar `New Job Wizard` + Schrittpanel in `Views/MainWindow.axaml`).
- Schritte umgesetzt: 1) Source waehlen 2) Target waehlen 3) Strategy waehlen 4) Basisparameter setzen (Jobname, Source/Target Pfad).
- Wizard-Flow (Back/Next/Finish/Cancel) in `ViewModels/MainWindowViewModel.cs` implementiert und in `Views/MainWindow.axaml.cs` verdrahtet.
- `Finish` erzeugt direkt ein gueltiges `JobDefinition`-JSON via bestehende Abstraction-Serialisierung (`JobDefinitionJson.Serialize`) ohne neue Business-Logik.
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

## UI-11 – JSON Preview Panel
Status: Closed (07-03-2026)

**Ziel:** Transparenz wahren

- Live JSON Preview
- Sync zwischen UI und JSON

**DoD:**
- Änderungen im UI spiegeln sich im JSON wider
- JSON bleibt editierbar

**Nachweis (07-03-2026):**
- Dediziertes `JSON Preview (Live)` Panel in der Configurator-UI hinzugefuegt (`Views/MainWindow.axaml`).
- JSON bleibt weiterhin direkt editierbar im separaten `JSON Editor`-Bereich.
- Live-Synchronisierung umgesetzt: Aenderungen am JSON-Editor aktualisieren Connector-Auswahl, Settings-Panels und Mapping-Grid automatisch bei gueltigem JSON (`ViewModels/MainWindowViewModel.cs`).
- UI-getriebene Aenderungen (Wizard, Connector-Auswahl, Settings, Mappings) aktualisieren weiterhin das JSON und damit den Live-Preview sofort.
- Ungueltiges JSON wird im Preview-Status sauber angezeigt, ohne UI-Absturz (`JsonPreviewState`).
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

## UI-12 – Error UX Polish
Status: Closed (07-03-2026)

**Ziel:** Verständliche Fehlermeldungen

- Keine Stacktraces im UI
- Copy Error Details Funktion

**DoD:**
- Fehler verständlich & reproduzierbar

**Nachweis (07-03-2026):**
- Fehlerdarstellung in der UI erweitert: klare, nutzerfreundliche Fehler-Zusammenfassung statt technischer Stacktrace-Ausgaben (`LastErrorSummary`).
- Reproduzierbare Fehlerdetails eingefuehrt (`LastErrorDetails`) mit Zeitstempel, aktueller Datei und Kontextdaten; Details werden im UI angezeigt.
- `Copy Error Details` Funktion implementiert (Clipboard-Integration in `Views/MainWindow.axaml.cs`) fuer schnelles Teilen von Fehlerinformationen.
- Fehler-Details werden bei erfolgreichen Aktionen zurueckgesetzt (`ClearError`) und bei Fehlern standardisiert aufgebaut (`SetError` + Sanitizing ohne Stacktrace-Fragmente).
- Build erfolgreich: `dotnet build .\src\SyncForge.sln -c Release`.

---

# EPIC 12 – Packaging & Distribution

## UI-13 – Windows Build
- Release Build
- ZIP Distribution
- Self-contained optional

## UI-14 – Linux Build
- Self-contained Binary oder AppImage
- Start via Terminal möglich

## UI-15 – Quickstart Dokumentation
- 10-Minuten-Guide
- Screenshots
- Beispieljob

**DoD:**
- Frischer Download → Start in <10 Minuten möglich

---

# R 0.2.0 – Definition of Done

- UI startet stabil unter Windows & Linux  
- JSON-First Prinzip eingehalten  
- Keine Logik-Duplikation  
- Alle 4 Connectoren konfigurierbar  
- Dry-Run & Run identisch zur CLI  
- Packaging abgeschlossen  
- Dokumentation aktualisiert  
- Keine Lizenzprüfung  

---

# Scope Guard (Nicht Teil von 0.2.0)

- Lizenzmechanismus  
- Scheduling  
- Multi-User  
- Enterprise Monitoring  
- Plugin Marketplace  
- OAuth2 Advanced Flows  