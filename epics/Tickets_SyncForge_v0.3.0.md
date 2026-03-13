# SyncForge - Roadmap R 0.3.0
## Bidirektionale CSV- und Excel-Konnektoren

**Release Ziel:**
R 0.3.0 ermoeglicht CSV und Excel (XLSX) durchgaengig als Source und als Target.
Bestehende Source-Connectoren werden auf Produktionsreife, konsistente Validierung und Configurator-Paritaet gebracht.
Neue Target-Connectoren fuer CSV und Excel werden so umgesetzt, dass Jobs dateibasiert ohne MSSQL- oder REST-Ziel betrieben werden koennen.

**Release Fenster (geplant):** 03-2026
**Owner:** Core + Connector Team + Configurator Team

---

# EPIC 14 - CSV- und Excel-Dateikonnektoren

**Epic Ziel:**
CSV- und Excel-Dateien sollen in SyncForge in beiden Richtungen nutzbar sein:
- als Quelle fuer bestehende Mapping- und Orchestrierungs-Pfade
- als Ziel fuer `InsertOnly`, `Replace` und wo sinnvoll `UpsertByKey`

**In Scope:**
- CSV Source Hardening und CSV Target Connector
- Excel Source Hardening und Excel Target Connector
- Plugin Discovery, Configurator-Felder, Beispieljobs und Dokumentation

**Out of Scope:**
- Neue Connector-Typen ausserhalb von `csv` und `xlsx`
- Formatuebergreifende Bulk-Performanceoptimierungen ausserhalb des benoetigten Streaming-/Rewrite-Basisverhaltens
- Excel-Features wie Formeln, Styling, Makros oder mehrere Output-Sheets fuer 0.3.0

---

## CSV-141 - CSV Source Hardening und Konfigurations-Paritaet
Status: Closed (11-03-2026)
Prioritaet: High

**Ziel:** Bestehenden CSV-Source-Pfad fuer produktive Nutzung absichern und im Configurator vollstaendig abbilden.

**Tasks:**
- Settings-Vertrag fuer `path`, `delimiter`, `encoding`, `hasHeader`, optional `quote` und `escape` finalisieren
- Einheitliche Validierung fuer fehlende Dateien, leere Header und fehlende Mapping-Spalten ergaenzen
- Source-Preview, CLI-Validate und Runtime-Verhalten auf identische Fehlermeldungen ausrichten
- Relative Pfadauflosung, UTF-8/BOM und gross/klein-Schreibung der Header explizit dokumentieren

**Akzeptanzkriterien:**
- CSV-Jobs mit gueltigen Settings laufen unveraendert weiter
- Ungueltige Pfade und fehlende Header erzeugen nachvollziehbare Validation-Fehler vor dem Run
- Configurator zeigt alle unterstuetzten CSV-Source-Settings ohne Hardcodierung an
- Tests decken Header-/No-Header-, Delimiter- und Encoding-Faelle ab

**Nachweis (11-03-2026):**
- Zentrale CSV-Settings-Klasse `CsvSourceSettings` in `SyncForge.Abstractions/Configuration/CsvSourceSettings.cs` implementiert mit Validierung fuer path, delimiter, encoding, hasHeader, quote, escape.
- Validator erweitert: `JobDefinitionValidator.cs` integriert CSV-spezifische Validierung ueber `CsvSourceSettings.ValidateSourceSettings()`.
- CSV-Source-Connector aktualisiert: `CsvSourceConnector.cs` nutzt neue Settings-Klasse und unterstuetzt `hasHeader=false` mit generierten Column-Namen (Column1, Column2, ...).
- Configurator-Schema erweitert: `ConnectorConfigSchemaService.cs` listet neue CSV-Keys auf; `SourcePreviewService.cs` migriert auf dieselbe CSV-Parser-Logik (CsvHelper mit settings).
- Configurator.csproj mit `CsvHelper` NuGet-Abhaengigkeit ergaenzt.
- Testabdeckung: neue Tests in `JobDefinitionValidatorTests.cs` fuer CSV-Settings (path-missing, encoding-invalid, hasHeader-invalid, quote/escape).
- Neues Testprojekt `SyncForge.Plugin.Csv.Tests` mit `CsvSourceConnectorTests` fuer Header-Mode, No-Header-Mode, Encoding und Error-Handling (4 Tests).
- Build erfolgreich: `dotnet test "J:\SyncForge\src\SyncForge.sln" -c Release` (15 Tests, 0 Fehler).
- Dokumentation in `examples/README.md` ergaenzt mit CSV-Source-Settings-Referenz.

**Abhaengigkeiten:**
- Nutzt bestehenden CSV-Source-Connector als Basis
- Sollte vor CSV-142 abgeschlossen werden, damit Source/Target dieselbe Settings-Sprache verwenden

---

## CSV-142 - CSV Target Connector Foundation
Status: Open
Prioritaet: High

**Ziel:** Neuen CSV-Target-Connector als Plugin mit sauberem Settings- und Plugin-Vertrag bereitstellen.

**Tasks:**
- `CsvTargetConnector` inklusive Plugin-Assembly, Registrierung und Discovery-Metadaten implementieren
- Settings fuer `path`, `delimiter`, `encoding`, `writeHeader`, `fileMode` und `tempFilePattern` definieren
- Zielpfad-Erstellung, Directory-Checks und atomaren Abschluss ueber temporaere Datei vorbereiten
- Zielschema aus `mappings[].targetField` bzw. aus dem ersten Record deterministisch ableiten

**Akzeptanzkriterien:**
- Connector wird von CLI und Configurator als Target `csv` erkannt
- Zielordner wird validiert, Fehler bei Schreibrechten werden sauber gemeldet
- Target schreibt reproduzierbare Header-Reihenfolge
- Build ist gruen ohne harte Abhaengigkeit auf geschlossene Repos

**Abhaengigkeiten:**
- Basiert auf `SyncForge.Abstractions` und bestehender Plugin-Discovery
- Muss mit P-147 abgestimmt werden

---

## CSV-143 - CSV Write Modes und Dateisicherheit
Status: Open
Prioritaet: High

**Ziel:** CSV als Target fuer `InsertOnly`, `Replace` und dateibasiertes `UpsertByKey` nutzbar machen.

**Tasks:**
- `InsertOnly` fuer neue oder bestehende Dateien mit konsistentem Header-Verhalten implementieren
- `Replace` ueber Write-to-temp + atomaren Swap umsetzen
- `UpsertByKey` als Rewrite-Strategie definieren und dokumentieren
- Fehler- und Abbruchverhalten bei gesperrten Dateien, Disk-Full und ungueltigen Schluesselfeldern absichern

**Akzeptanzkriterien:**
- `InsertOnly` haengt Daten ohne kaputte Header oder doppelte Kopfzeilen an
- `Replace` hinterlaesst bei Fehlern keine halb geschriebene Zieldatei
- `UpsertByKey` aktualisiert bestehende Zeilen anhand der konfigurierten `keyFields` deterministisch
- Integrations-Tests pruefen kleine und grosse Dateien sowie Wiederanlauf nach Fehlern

**Abhaengigkeiten:**
- Depends on CSV-142
- Sollte nach C-123/Cancellation-Propagation-Muster umgesetzt werden

---

## EXCEL-144 - Excel Source Hardening und Betriebsgrenzen
Status: Open
Prioritaet: Medium

**Ziel:** Bestehenden Excel-Source-Pfad fuer produktive Jobs und UI-Preview robuster machen.

**Tasks:**
- Settings-Vertrag fuer `path`, `sheetName`, optional `sheetIndex`, `firstRowAsHeader` finalisieren
- Fehlerszenarien fuer leere Sheets, fehlende Arbeitsblaetter und unklare Header verbessern
- Dokumentierte Limits fuer Dateigroesse, Zeilenanzahl und Speicherverhalten definieren
- Preview- und Runtime-Pfad so angleichen, dass dieselbe Blattauflosung und Headerlogik gilt

**Akzeptanzkriterien:**
- XLSX-Jobs mit explizitem oder implizitem Sheet laufen reproduzierbar
- Fehler bei unbekanntem Sheet oder leerem Workbook werden vor dem produktiven Lauf erkannt
- Configurator kann Sheet-Auswahl und relevante Excel-Settings anzeigen
- Tests decken mehrere Sheets, Header-Zeile und leere Zellen ab

**Abhaengigkeiten:**
- Nutzt bestehenden Excel-Source-Connector als Basis
- Sollte vor EXCEL-145 abgeschlossen werden, damit Source/Target dieselben Feldannahmen teilen

---

## EXCEL-145 - Excel Target Connector Foundation
Status: Open
Prioritaet: High

**Ziel:** XLSX als erstes dateibasiertes Tabellen-Target in SyncForge bereitstellen.

**Tasks:**
- `ExcelTargetConnector` mit Workbook-, Worksheet- und Header-Erzeugung implementieren
- Settings fuer `path`, `sheetName`, `writeHeader`, `overwriteSheet`, `tempFilePattern` definieren
- Zellschreiblogik fuer Strings, Zahlen, Bool, DateTime und Null-Werte festlegen
- Dateierzeugung so aufbauen, dass erzeugte Dateien in Excel und LibreOffice geoeffnet werden koennen

**Akzeptanzkriterien:**
- Connector wird von CLI und Configurator als Target `xlsx` erkannt
- Erzeugte Dateien sind gueltige XLSX-Dateien und lassen sich oeffnen
- Header-Reihenfolge und Datentypabbildung sind deterministisch
- Tests validieren Workbook, Sheetname, Header und Row Count

**Abhaengigkeiten:**
- Nutzt bestehende OpenXml-basierte Plugin-Infrastruktur
- Muss mit P-147 abgestimmt werden

---

## EXCEL-146 - Excel Write Modes, Rewrite und Limits
Status: Open
Prioritaet: Medium

**Ziel:** Excel-Target fuer alltagstaugliche Schreibmodi absichern und klare Grenzen fuer dateibasiertes Upsert setzen.

**Tasks:**
- `Replace` ueber temp-file + atomaren Austausch implementieren
- `InsertOnly` definieren: neues Workbook oder Anhaengen an bestehendes Sheet, sofern technisch stabil
- `UpsertByKey` nur als vollstaendiges Rewrite mit dokumentierten Groessen-/Speichergrenzen umsetzen
- Fehlerbehandlung fuer gesperrte Dateien, kaputte Workbooks und inkonsistente Header einbauen

**Akzeptanzkriterien:**
- `Replace` ist der Standardpfad fuer stabile XLSX-Schreibvorgaenge
- `InsertOnly` ist entweder sauber unterstuetzt oder fuer 0.3.0 explizit nicht zulaessig dokumentiert
- `UpsertByKey` liefert deterministische Ergebnisse oder wird mit klarer Validation blockiert, wenn Grenzen verletzt werden
- Integrations-Tests pruefen mindestens den erfolgreichen Replace-Pfad und einen Fehlerfall mit bestehender Datei

**Abhaengigkeiten:**
- Depends on EXCEL-145
- Architekturentscheidung zu `InsertOnly` muss vor Abschluss dokumentiert sein

---

## P-147 - Plugin Discovery, Type Mapping und Job Schema
Status: Open
Prioritaet: High

**Ziel:** Neue CSV- und Excel-Target-Connectoren muessen ueber alle Produktoberflaechen einheitlich auffindbar und konfigurierbar sein.

**Tasks:**
- Discovery-Regeln fuer `csv` und `xlsx` als Source und Target vereinheitlichen
- Connector-Metadaten, Schema-Service und Type-Mapping fuer neue Target-Settings erweitern
- Job-Beispiele und Validatoren so erweitern, dass neue Targets ohne Sonderlogik verstanden werden
- Sicherstellen, dass OSS-Solution und interne Workspace-Loesung konsistent bleiben

**Akzeptanzkriterien:**
- CLI, Configurator und Preflight erkennen dieselben Connector-Typen und Settings
- Job-Definitionen fuer CSV->CSV, CSV->XLSX, XLSX->CSV und XLSX->XLSX sind validierbar
- Keine harte Projekt-Referenz auf optionale Plugin-Repos wird eingefuehrt
- Dokumentierte Beispieljobs decken mindestens vier Dateikombinationen ab

**Abhaengigkeiten:**
- Muss mit CSV-142 und EXCEL-145 abgestimmt werden
- Beachte Loesungstrennung zwischen OSS und internem Workspace

---

## UI-148 - Configurator, Beispieljobs und Dokumentation
Status: Open
Prioritaet: Medium

**Ziel:** Neue dateibasierte Source-/Target-Kombinationen im Configurator und in der Doku direkt benutzbar machen.

**Tasks:**
- Dynamische Settings-Panels fuer CSV/XLSX Source und Target vervollstaendigen
- Preflight-Hinweise fuer Datei-Existenz, Schreibrechte, Sheet-Auswahl und Upsert-Grenzen ergaenzen
- Beispieljobs fuer `csv->csv`, `csv->xlsx`, `xlsx->csv`, `xlsx->xlsx` erstellen
- Dokumentation in `README`, Connector-Doku und Quickstart aktualisieren

**Akzeptanzkriterien:**
- Configurator kann neue Source-/Target-Kombinationen ohne manuelle JSON-Nacharbeit speichern
- Preflight meldet dateibezogene Risiken vor dem Run
- Mindestens vier Beispieljobs laufen im Dry-Run erfolgreich
- Doku beschreibt unterstuetzte Settings, bekannte Grenzen und empfohlenen Einsatzpfad pro Format

**Abhaengigkeiten:**
- Depends on CSV-141 bis CSV-143
- Depends on EXCEL-144 bis EXCEL-146
- Depends on P-147

---

### EPIC 14 - Lieferreihenfolge und Risiken

**Empfohlene Reihenfolge:**
1. CSV-141
2. CSV-142
3. CSV-143
4. EXCEL-144
5. EXCEL-145
6. EXCEL-146
7. P-147
8. UI-148

**Hauptrisiken:**
- Dateibasiertes `UpsertByKey` ist fuer grosse CSV/XLSX-Dateien teurer als datenbankbasierte Targets
- XLSX-Schreibpfade haben hoehere Speicher- und Dateikonsistenzrisiken als CSV
- Unterschiedliche Header-/Typannahmen zwischen Preview, Validate und Run muessen frueh vereinheitlicht werden

**Definition of Done fuer das Epic:**
- CSV und XLSX sind in mindestens einem End-to-End-Szenario jeweils als Source und als Target nutzbar
- Neue Connectoren sind in CLI, Configurator und Preflight verfuegbar
- Dokumentation und Beispieljobs sind aktualisiert
- Build/Test-Nachweise koennen fuer OSS-Solution und relevante interne Kombinationen erbracht werden