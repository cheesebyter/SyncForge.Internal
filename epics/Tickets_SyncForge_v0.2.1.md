# SyncForge - Roadmap R 0.2.1
## Stabilitaet, Governance und Produktivbetrieb

**Release Ziel:**
R 0.2.1 fokussiert auf Stabilitaet nach dem UI-Ausbau in 0.2.0.
Schwerpunkte: observability, sichere Konfiguration, robustere Mapping-Validierung und reproduzierbare Packaging-Pipelines.

**Release Fenster (geplant):** 03-2026
**Owner:** Core + Configurator Team

---

# EPIC 12 - Core Hardening

## C-121 - Duplicate TargetField Guard
Status: Closed (10-03-2026)
Prioritaet: High

**Ziel:** Verhindern von stillem Ueberschreiben bei doppelten `mappings[].targetField`.

**Tasks:**
- Validator-Regel fuer doppelte `targetField` (case-insensitive)
- Fehlertext mit betroffenen Feldern ausgeben
- CLI und Configurator zeigen identisches Fehlerbild

**Akzeptanzkriterien:**
- Job mit doppeltem `targetField` wird abgelehnt
- Fehler nennt beide Mapping-Eintraege eindeutig
- Unit-Tests decken Positiv- und Negativfall ab

**Nachweis (10-03-2026):**
- Erweiterte Validierung in `SyncForge/src/SyncForge.Abstractions/Configuration/JobDefinitionValidator.cs` implementiert.
- Duplicate-Check ist case-insensitive und meldet beide Mapping-Indizes.
- Runtime-Guard zusaetzlich in `SyncForge/src/SyncForge.Core/Mapping/MappingEngine.cs` eingebaut, damit auch bei umgangener Vorvalidierung kein stilles Ueberschreiben passiert.

---

## C-122 - Transformation Whitelist Validation
Status: Closed (10-03-2026)
Prioritaet: High

**Ziel:** Unbekannte Transformationen nicht mehr still ignorieren.

**Tasks:**
- Erlaubte Werte zentral definieren (`Trim`, `ToUpper`)
- Validierung fuer `mappings[].transformations[]`
- Dokumentation in Connector-/Job-Docs aktualisieren

**Akzeptanzkriterien:**
- Tippfehler in Transformationen erzeugen Validation-Fehler
- Guelte Transformationen laufen unveraendert
- Tests fuer case-insensitive Verarbeitung vorhanden

**Nachweis (10-03-2026):**
- Transformation-Whitelist (`Trim`, `ToUpper`) in `SyncForge/src/SyncForge.Abstractions/Configuration/JobDefinitionValidator.cs` ergaenzt.
- `SyncForge/src/SyncForge.Core/Mapping/MappingEngine.cs` validiert Transformationen ebenfalls zur Laufzeit und wirft bei unbekannten Werten explizit Fehler.
- Tests fuer gueltige/ungueltige Werte inkl. case-insensitive Verhalten hinzugefuegt in `SyncForge/src/SyncForge.Core.Tests/JobDefinitionValidatorTests.cs`.

---

## C-123 - Cancellation Token Propagation
Status: Closed (10-03-2026)
Prioritaet: Medium

**Ziel:** Bessere Abbruchfaehigkeit bei langen Source/Target-I/O.

**Tasks:**
- Connector-Interfaces um `CancellationToken` erweitern
- Alle Plugins auf neue Signatur migrieren
- Ctrl+C Verhalten in CLI und Configurator pruefen

**Akzeptanzkriterien:**
- Lauf kann bei langem Read/Write sauber abgebrochen werden
- Keine Deadlocks / haengende Tasks
- Migration Build gruen fuer alle Plugins

**Nachweis (10-03-2026):**
- Connector-Interfaces um CancellationToken erweitert:
	- `SyncForge/src/SyncForge.Abstractions/Connectors/ISourceConnector.cs`
	- `SyncForge/src/SyncForge.Abstractions/Connectors/ITargetConnector.cs`
- Alle beteiligten Implementierungen auf neue Signatur migriert (CSV, Excel, REST, JSONL in CLI/Configurator sowie MSSQL-Plugin-Projekt).
- Orchestrator propagiert Token durchgaengig (`SyncForge/src/SyncForge.Core/Orchestration/JobOrchestrator.cs`).
- Build erfolgreich: `dotnet build SyncForge/src/SyncForge.sln -c Release`.

---

## C-124 - Error Logging with Exception Context
Status: Closed (10-03-2026)
Prioritaet: Medium

**Ziel:** Schnellere Ursachenanalyse im Betrieb.

**Tasks:**
- Exception-Typ + Stacktrace in Orchestrator-Logs ausgeben
- Log-Format fuer JSON und Text konsistent halten
- Fehlerfall-Doku um Beispiel-Logs erweitern

**Akzeptanzkriterien:**
- Fehlerlogs enthalten Message, Typ und Stacktrace
- Keine doppelte/rauschende Fehlermeldung

**Nachweis (10-03-2026):**
- Logger-API um exception-aware Methode erweitert:
	- `SyncForge/src/SyncForge.Abstractions/Logging/ISyncForgeLogger.cs`
	- Implementierungen in `NoOpSyncForgeLogger` und `SerilogSyncForgeLogger` aktualisiert.
- Orchestrator loggt Fehler nun mit Exception-Objekt (`SyncForge/src/SyncForge.Core/Orchestration/JobOrchestrator.cs`), damit Typ + Stacktrace erhalten bleiben.
- Verhalten mit Unit-Test abgesichert: `SyncForge/src/SyncForge.Core.Tests/JobOrchestratorTests.cs`.

---

### EPIC 12 - Umsetzungsnachweis (10-03-2026)

- Fokus auf Stabilitaet und Nachvollziehbarkeit umgesetzt ohne neue Core-Abhaengigkeiten zu Plugin-spezifischer Logik.
- Core-Hardening umgesetzt ueber Validierung + Runtime-Guards + Cancellation-Propagation + verbessertes Error-Logging.
- Neues Testprojekt erstellt: `SyncForge/src/SyncForge.Core.Tests`.
- Build und Tests erfolgreich fuer die geaenderte Loesung.

---

# EPIC 13 - Configurator Reliability & UX

## UI-131 - Connector Preflight Panel
Status: Closed (10-03-2026)
Prioritaet: High

**Ziel:** Fruehes Erkennen von Verbindungs-/Schemafehlern vor Run.

**Tasks:**
- Preflight-Button fuer Source und Target
- Ergebnisanzeige mit Severity (Info/Warn/Error)
- Letztes Preflight-Result pro Job zwischenspeichern

**Akzeptanzkriterien:**
- Preflight meldet Fehler ohne Start eines Runs
- Ergebnis ist nachvollziehbar und exportierbar

**Nachweis (10-03-2026):**
- Preflight-Service hinzugefuegt: `SyncForge.Configurator/Services/PreflightService.cs`.
- Preflight prueft Connector-Aufloesung, required settings, Source-Probe und Dry-Run-Orchestrierungsprobe.
- UI erweitert um `Preflight`-Action, Severity-basierte Findings (`INFO/WARN/ERROR`) und Exportfunktion.
- Letztes Ergebnis wird pro Jobname im ViewModel-Cache gehalten und beim Jobwechsel wieder geladen.

---

## UI-132 - Unsaved Changes Guard
Status: Closed (10-03-2026)
Prioritaet: Medium

**Ziel:** Schutz vor Datenverlust beim Schliessen/Wechseln.

**Tasks:**
- Dirty-Tracking fuer JSON, Mappings und Settings
- Confirm-Dialog bei New/Open/Close
- Option "Nicht erneut fragen" fuer Session

**Akzeptanzkriterien:**
- Keine stillen Datenverluste bei Navigation
- Guard greift fuer alle relevanten Aktionen

**Nachweis (10-03-2026):**
- Dirty-Tracking im ViewModel implementiert (`HasUnsavedChanges`, `UnsavedIndicator`).
- Guard fuer `New`, `Open` und Window-`Close` in `SyncForge.Configurator/Views/MainWindow.axaml.cs` umgesetzt.
- Dialogoption `Nicht erneut fragen (nur diese Session)` integriert und an Session-Flag gebunden.

---

## UI-133 - Validation Error Navigation
Status: Closed (10-03-2026)
Prioritaet: Medium

**Ziel:** Schnellere Korrektur bei grossen Job-Dateien.

**Tasks:**
- Klick auf Validation-Fehler springt zum Feld/Section
- Fehler-Highlight in Mapping-Grid und Settings
- Filter nur "kritische Fehler"

**Akzeptanzkriterien:**
- Jeder Fehler ist direkt anspringbar
- Fokus landet auf betroffener Eingabe

**Nachweis (10-03-2026):**
- Auswahl + Navigation fuer Validation-Fehler implementiert (`Go To Selected Error`).
- Navigation erweitert Expander gezielt und springt bei Mapping-Fehlern auf die betroffene Zeile (Index-Parsing `Mappings[n]`).
- Statushinweise zur angesprungenen Section im UI ergaenzt.

---

## UI-134 - Job Templates (Starter Packs)
Status: Closed (10-03-2026)
Prioritaet: Low

**Ziel:** Schnellstart fuer haeufige Integrationsmuster.

**Tasks:**
- Template-Bibliothek: CSV->MSSQL, REST->CSV, Excel->REST
- Platzhalter fuer Secrets/Path
- Kurzbeschreibung und erwartete Felder je Template

**Akzeptanzkriterien:**
- Neues Job-Template erzeugt gueltiges JSON
- Anwender kann ohne manuelles Grundgeruest starten

**Nachweis (10-03-2026):**
- Wizard um Starter-Templates erweitert (`Custom`, `CSV -> MSSQL`, `REST -> JSONL`, `Excel -> REST`).
- Template-Auswahl + `Apply Template` in der UI integriert und im ViewModel auf gueltige Scaffold-Settings verdrahtet.
- Generierte Templates erzeugen gueltiges JSON inklusive basisfaehiger Connector-Settings.
- Hinweis: `REST -> CSV` wurde mangels verfuegbarem CSV-Target-Connector als lauffaehige Variante `REST -> JSONL` umgesetzt.

---

### EPIC 13 - Umsetzungsnachweis (10-03-2026)

- Reliability/UX-Verbesserungen im Configurator ohne neue Core-Abhaengigkeit zu plugin-spezifischer Logik umgesetzt.
- Build erfolgreich: `dotnet build SyncForge.Configurator/SyncForge.Configurator.csproj -c Release`.
- Regressionstest erfolgreich: `dotnet test SyncForge/src/SyncForge.sln -c Release --no-build`.

---

# EPIC 14 - Delivery, Security and Ops

## OPS-141 - Reproducible Packaging
Status: Closed (11-03-2026)
Prioritaet: High

**Ziel:** Deterministische Artefakte fuer Windows/Linux Pakete.

**Tasks:**
- Build-Skripte auf reproduzierbare Versionierung umstellen
- Artefakt-Metadaten (Version, Commit, Build-Time) einbetten
- Release-Checkliste aktualisieren

**Akzeptanzkriterien:**
- Gleiches Commit erzeugt vergleichbare Artefakte
- Version/Commit sind im Paket nachvollziehbar

**Nachweis (11-03-2026):**
- Build-/Packaging-Skripte um deterministische Publish-Properties erweitert (`ContinuousIntegrationBuild`, `Deterministic`, `Version`, `InformationalVersion`, `SourceRevisionId`, `RepositoryCommit`).
- Metadaten-Output implementiert: `build-metadata.json` in Publish-/Package-Output.
- Version/Commit/Build-Zeit koennen ueber Skriptparameter injiziert werden.

---

## OPS-142 - Plugin Signature and Trust Policy
Status: Closed (11-03-2026)
Prioritaet: High

**Ziel:** Nur vertrauenswuerdige Plugins laden.

**Tasks:**
- Signaturpruefung fuer Plugin-Assemblies
- Allowlist fuer Publisher/Key-Fingerprint
- Fail-safe Verhalten bei unsignierten Plugins

**Akzeptanzkriterien:**
- Unsignierte oder untrusted Plugins werden blockiert
- Audit-Log dokumentiert Ladeentscheidung

**Nachweis (11-03-2026):**
- Trust-Policy fuer Plugins implementiert: `SyncForge/src/SyncForge.Cli/Runtime/PluginLoading/PluginTrustPolicy.cs`.
- Loader blockiert Plugins ausserhalb der Allowlist oder mit SHA256-Mismatch (`ReflectionPluginLoader`).
- Audit-Entscheidungen (Allowed/Blocked inkl. Grund/SHA256) werden gesammelt und durch die CLI geloggt.
- Build-Skripte erzeugen `trusted-plugins.json` automatisiert.

---

## OPS-143 - Run Metrics Snapshot Export
Status: Closed (11-03-2026)
Prioritaet: Medium

**Ziel:** Betriebstransparenz fuer Support und Audits.

**Tasks:**
- Export von `RunMetricsTotals` und letzten Runs als JSON
- CLI-Command `metrics export <path>`
- Configurator-Button fuer denselben Export

**Akzeptanzkriterien:**
- Export ist schema-stabil und parsebar
- Daten stimmen mit internem RunStore ueberein

**Nachweis (11-03-2026):**
- Neuer CLI-Command: `syncforge metrics export <output.json> [--state-store <path>] [--job <jobName>] [--take <N>]`.
- Export enthaelt `RunMetricsTotals` plus letzte Runs als JSON.
- Datenquelle ist der persistente SQLite RunStore (`SqliteJobStore`), inkl. globalem Recent-Query.

---

## OPS-144 - Test Matrix and CI Gates
Status: Closed (11-03-2026)
Prioritaet: Medium

**Ziel:** Regressionen frueh erkennen.

**Tasks:**
- Matrix fuer Windows/Linux und .NET 8
- Mindestabdeckung fuer Core + kritische Plugins
- Pflicht-Gates: Build, Unit-Tests, Smoke-Dry-Run

**Akzeptanzkriterien:**
- PR ohne gruene Gates kann nicht gemergt werden
- CI-Report zeigt klaren Status pro Komponente

**Nachweis (11-03-2026):**
- Neue CI-Matrix angelegt: `SyncForge/.github/workflows/ci.yml`.
- Gates enthalten:
	- Build (`dotnet build`)
	- Unit-Tests inkl. Coverage-Threshold (Core + REST Plugin)
	- Smoke-Dry-Run gegen Beispieljob
- Matrix laeuft auf `ubuntu-latest` und `windows-latest` mit .NET 8.

---

### EPIC 14 - Umsetzungsnachweis (11-03-2026)

- Delivery/Security/Ops-Paket umgesetzt: reproduzierbare Artefakte, Trust-Policy, Metrics-Export und CI-Gates.
- Fokus auf Stabilitaet und Nachvollziehbarkeit: alle Outputs sind versioniert bzw. auditierbar (`build-metadata.json`, `trusted-plugins.json`, `metrics export`).

---

# Milestones

- M1 (Woche 1): C-121, C-122, UI-131 gestartet
- M2 (Woche 2): C-123 Interface-Migration, UI-132 fertig
- M3 (Woche 3): OPS-141, OPS-142 in CI integriert
- M4 (Woche 4): Hardening-Tests, Release Candidate

---

# Release Exit Kriterien

- Keine offenen High-Prioritaet Tickets
- Core- und Configurator-Builds gruen auf Windows + Linux
- Smoke-Runs fuer 3 Referenzjobs erfolgreich
- Dokumentation aktualisiert (`connectors.md`, `quickstart-10-min.md`, Release Notes)
