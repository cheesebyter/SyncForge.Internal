# EPIC: Einführung eines eigenen SyncForge Design-Systems (Ablösung FluentTheme)

## Ziel

Ablösung des aktuellen Avalonia FluentTheme durch ein eigenes, vollständig kontrolliertes SyncForge-Theme zur Sicherstellung von:

- Konsistenter Markenidentität  
- Vollständiger Style-Kontrolle  
- Unabhängigkeit von Avalonia-Theme-Änderungen  
- Vorbereitung auf White-Labeling  
- Wartbarer, tokenbasierter Design-Architektur  

---

## Problemstellung

Aktuell basiert die UI auf `FluentTheme`. Dadurch entstehen:

- Unvorhersehbare Style-Overrides (z. B. Hover-Foreground wird überschrieben)
- Abhängigkeit von Avalonia-internen ControlTemplates
- Eingeschränkte visuelle Kontrolle
- Schwierige Anpassbarkeit bei Branding- oder Partneranforderungen

Für ein Produkt mit Integratoren-Zielgruppe ist visuelle Konsistenz und volle Kontrolle essenziell.

---

## Scope

Dieses Epic umfasst:

1. Entfernung von FluentTheme
2. Einführung eines zentralen SyncForgeTheme
3. Aufbau eines tokenbasierten Farb- und Style-Systems
4. Definition eigener ControlTemplates für Kern-Controls
5. Migration bestehender Views auf das neue Theme

### Nicht im Scope

- UX-Redesign
- Funktionale UI-Änderungen
- Animationen oder Advanced Visual States

---

## Zielarchitektur

/Styles
├── SyncForgeTheme.axaml
├── Tokens.axaml
├── Controls/
│ ├── Button.axaml
│ ├── TextBox.axaml
│ ├── ComboBox.axaml
│ ├── ListBox.axaml
│ ├── ScrollBar.axaml
│ └── ProgressBar.axaml


Theme wird ausschließlich über `Application.Styles` geladen.

Kein FluentTheme mehr im Projekt.

---

## Design-Prinzipien

- Token-basierte Farbdefinition
- Keine Hardcoded-Farben in Views
- Templates statt Property-Overrides
- Klare Zustände: Normal / Hover / Pressed / Disabled
- Vorbereitung für Dark-Mode (optional)
- Klare Trennung zwischen Design-Tokens und Control-Implementierung

---

## Definition of Done

- FluentTheme vollständig entfernt
- Alle Kern-Controls verwenden SyncForgeTheme
- Hover- und Pressed-Zustände funktionieren konsistent
- Keine ungewollten Style-Overrides
- DevTools zeigt keine aktiven Fluent-Styles mehr
- Dokumentation des Design-Systems vorhanden
- Keine Inline-Style-Definitionen in Views mehr

---

# Stories / Tasks

---

## Story 1 – Entfernen von FluentTheme

Status: Closed (08-03-2026)

**Ziel:** Entfernen der Theme-Abhängigkeit.

**Tasks:**
- FluentTheme aus `App.axaml` entfernen
- Application.Styles auf eigenes Theme umstellen
- UI-Regressions identifizieren
- DevTools prüfen

**Akzeptanzkriterien:**
- Kein FluentTheme im Projekt referenziert
- Anwendung startet ohne Exceptions
- Styles sind vollständig unter eigener Kontrolle

**Nachweis (08-03-2026):**
- `FluentTheme` aus `SyncForge.Configurator/App.axaml` entfernt.
- `Application.Styles` auf eigenes Theme umgestellt: `StyleInclude` auf `Styles/SyncForgeTheme.axaml`.
- Neues zentrales Theme angelegt: `SyncForge.Configurator/Styles/SyncForgeTheme.axaml`.
- NuGet-Referenz `Avalonia.Themes.Fluent` aus `SyncForge.Configurator/SyncForge.Configurator.csproj` entfernt.
- Technischer Check erfolgreich: `dotnet restore` und `dotnet build` fuer `SyncForge.Configurator` laufen fehlerfrei.
- DevTools-Pruefung (keine aktiven Fluent-Styles) ist als manueller UI-Check im laufenden Client auszufuehren.

---

## Story 2 – Einführung von Design-Tokens

Status: Closed (08-03-2026)

**Ziel:** Einführung eines zentralen Farb- und Style-Token-Systems.

**Tasks:**
- Definition von Farb-Tokens:
  - Primary
  - Secondary
  - Accent
  - Danger
  - Success
  - Warning
  - Neutral Scale (100–900)
- Definition als Color + Brush Ressourcen
- Erstellung `Tokens.axaml`
- Einbindung in `SyncForgeTheme.axaml`

**Akzeptanzkriterien:**
- Keine direkten Hex-Farben mehr in Views
- Alle Farben stammen aus zentralen Ressourcen

**Nachweis (08-03-2026):**
- Zentrale Token-Datei erstellt: `SyncForge.Configurator/Styles/Tokens.axaml`.
- Enthaltene Token-Gruppen umgesetzt:
  - Primary, Secondary, Accent, Danger, Success, Warning
  - Neutral Scale 100-900
  - Surface/Text-Rollen und State-Farben
- Alle Token als `Color` und `SolidColorBrush` Ressourcen definiert.
- `SyncForgeTheme.axaml` bindet Token zentral ein (`StyleInclude` auf `Tokens.axaml`).
- Harte Farbwerte in `SyncForge.Configurator/Views/MainWindow.axaml` auf `DynamicResource` umgestellt.
- Technische Validierung erfolgreich: `dotnet build` fuer `SyncForge.Configurator` laeuft fehlerfrei.

---

## Story 3 – Button Template Implementierung

Status: Closed (08-03-2026)

**Ziel:** Vollständige Kontrolle über Button-Rendering.

**Tasks:**
- Eigenes ControlTemplate definieren
- Zustände implementieren:
  - Normal
  - Hover
  - Pressed
  - Disabled
- Klassen definieren:
  - `.primary`
  - `.secondary`
  - `.danger`
- Konsistentes Padding, BorderRadius, Typography

**Akzeptanzkriterien:**
- Keine Abhängigkeit von Fluent Button Template
- Hover-Foreground funktioniert zuverlässig
- Buttons verhalten sich visuell konsistent

**Nachweis (08-03-2026):**
- Eigenes Button-Template implementiert in `SyncForge.Configurator/Styles/Controls/Button.axaml`.
- Template nutzt eigenen `ControlTemplate`-Aufbau (Border + ContentPresenter) statt Fluent-Template.
- Zustaende implementiert: `Normal`, `Hover`, `Pressed`, `Disabled`.
- Klassen umgesetzt: `.primary`, `.secondary`, `.danger` inklusive Zustandsstyles.
- Konsistente Button-Basiswerte eingefuehrt (Padding, CornerRadius, FontSize, FontWeight).
- `SyncForgeTheme.axaml` bindet das Control-Stylesheet zentral ein.
- Lokale Topbar-Button-Styles in `MainWindow.axaml` entfernt und auf Klassen umgestellt.
- Technische Validierung erfolgreich: `dotnet build` fuer `SyncForge.Configurator` laeuft fehlerfrei.

---

## Story 4 – TextBox & Input Controls

Status: Closed (08-03-2026)

**Ziel:** Konsistentes Input-Verhalten.

**Tasks:**
- Eigenes Template für TextBox
- Fokus-State definieren
- Border-Verhalten standardisieren
- Disabled-State implementieren
- Vorbereitung für Validierungszustände

**Akzeptanzkriterien:**
- Fokus visuell klar erkennbar
- Keine Style-Konflikte
- Einheitliche Border-Logik

**Nachweis (08-03-2026):**
- Eigenes TextBox-ControlTemplate implementiert in `SyncForge.Configurator/Styles/Controls/TextBox.axaml`.
- Fokus-State umgesetzt (`TextBox:focus` mit Primary-Border).
- Border-Verhalten standardisiert (Normal/Hover/Focus/Disabled).
- Disabled-State implementiert (`TextBox:disabled` mit neutralen Surface/Text/Border-Werten).
- Vorbereitung fuer Validierungszustaende umgesetzt ueber semantische Klassen:
  - `TextBox.invalid`
  - `TextBox.warning`
  - `TextBox.success`
- Zentrale Einbindung in `SyncForgeTheme.axaml` vorgenommen (`StyleInclude` auf `Controls/TextBox.axaml`).
- Technische Validierung erfolgreich: `dotnet build` fuer `SyncForge.Configurator` laeuft fehlerfrei.

---

## Story 5 – Listen- und Auswahl-Controls

Status: Closed (08-03-2026)

**Ziel:** Konsistentes Verhalten von Listen und Auswahlkomponenten.

**Tasks:**
- ListBox Template
- ComboBox Template
- ScrollBar Styling
- Selektionsfarben definieren
- Hover- und Selected-State konsistent umsetzen

**Akzeptanzkriterien:**
- Einheitliche Selektionsfarbe
- Scrollbars entsprechen Design-System
- Keine Theme-Overrides sichtbar

**Nachweis (08-03-2026):**
- Eigenes ListBox-Stylesheet erstellt: `SyncForge.Configurator/Styles/Controls/ListBox.axaml`.
- Eigenes ComboBox-Stylesheet erstellt: `SyncForge.Configurator/Styles/Controls/ComboBox.axaml`.
- Eigenes ScrollBar-Stylesheet erstellt: `SyncForge.Configurator/Styles/Controls/ScrollBar.axaml`.
- Einheitliche Selektionsfarben umgesetzt ueber zentrale Token/Brushes (`SfBrush.Selection`, `SfBrush.SelectionHover`, `SfBrush.SelectionForeground`).
- Konsistente Hover/Selected-Zustaende fuer `ListBoxItem` und `ComboBoxItem` implementiert.
- ScrollBar-Thumb im Design-System gestylt (Normal/Hover/Pressed).
- Zentrale Einbindung aller drei Control-Styles in `SyncForgeTheme.axaml` via `StyleInclude`.
- Technische Validierung erfolgreich: `dotnet build` fuer `SyncForge.Configurator` laeuft fehlerfrei.

---

## Story 6 – Migration bestehender Views

Status: Closed (08-03-2026)

**Ziel:** Entfernung von Inline-Styles.

**Tasks:**
- Refactoring harter Farbwerte
- Entfernen von lokalen Styles in Views
- Nutzung von Klassen (.primary etc.)
- Überprüfung aller Controls

**Akzeptanzkriterien:**
- Keine Hex-Farben in XAML-Views
- Alle Controls verwenden zentrale Styles
- Keine redundanten Style-Definitionen

**Nachweis (08-03-2026):**
- View-Migration in `SyncForge.Configurator/Views/MainWindow.axaml` durchgefuehrt.
- Redundante Inline-Style-Definitionen in der View entfernt und durch zentrale Klassen ersetzt.
- Neue zentrale View-Klassen in `SyncForgeTheme.axaml` eingefuehrt und verwendet:
  - `Border.panel`, `Border.panel-subtle`, `Border.statusbar`
  - `TextBlock.section-title`, `TextBlock.muted`
- Button-Verwendung in der View auf zentrale Klassen vereinheitlicht (`.primary`, `.secondary`, `.danger`).
- Hex-Farben in allen View-XAMLs entfernt (technischer Scan ohne Treffer).
- Technische Validierung erfolgreich: `dotnet build` fuer `SyncForge.Configurator` laeuft fehlerfrei.

---

## Story 7 – Dokumentation des Design-Systems

Status: Closed (08-03-2026)

**Ziel:** Nachhaltige Wartbarkeit.

**Tasks:**
- Dokumentation der Farb-Tokens
- Beschreibung der Control-Klassen
- Naming-Konventionen definieren
- Beispiel-Usage dokumentieren
- Guidelines für zukünftige UI-Entwicklung

**Akzeptanzkriterien:**
- Dokumentation im Repository vorhanden
- Entwickler können neue Views ohne Inline-Styling erstellen
- Style-Erweiterungen folgen klarer Struktur

**Nachweis (08-03-2026):**
- Zentrale Design-System-Dokumentation erstellt: `SyncForge.Configurator/docs/design-system.md`.
- Dokumentiert sind:
  - Farb- und Brush-Tokens
  - Control-Klassen und Zustandsverhalten
  - Naming-Konventionen
  - Guidelines fuer neue Views ohne Inline-Styling
  - Beispiel-Usage fuer Klassen und Ressourcen
- README aktualisiert und auf die Design-System-Dokumentation verlinkt.
- Wichtige Theme-/Control-Dateien im README referenziert.

---

# Business Impact

- Professionellerer Produktauftritt
- Technische Entkopplung von Avalonia-Themes
- Zukunftssicherheit bei Framework-Updates
- Grundlage für White-Labeling
- Bessere Wartbarkeit
- Reduzierte visuelle Inkonsistenzen

---

# Langfristige Erweiterungsmöglichkeiten

- Dark-Mode Support
- Partner-Branding
- Dynamisches Theme Switching
- Design-Token-Export (z. B. JSON für Web-Dokumentation)
- Design-System-Versionierung

---

# Priorisierung

Empfohlene Umsetzung:  
Start in v0.2.x  
Abschluss vor v0.6.0 (Beta-Rollout)

---

# Aufwandsschätzung

- Architektur & Tokens: Mittel
- Button & Kern-Controls: Mittel
- Migration: Mittel
- Dokumentation: Gering bis Mittel

Gesamt: Mittel bis Hoch (je nach Tiefe der Template-Implementierung)

---

# Aktueller Stand (08-03-2026)

Die folgenden kurzfristigen Lesbarkeits- und Layout-Fixes wurden bereits umgesetzt, ohne das Epic vollstaendig abzuschliessen:

- Theme-Variant im Configurator auf Light festgesetzt (`RequestedThemeVariant="Light"` in `App.axaml`).
- Topbar-Buttons mit eigenem lokalen Style verbessert (hellerer Button, konsistenter Hover/Pressed-State, lesbare Schrift).
- Hover-/Pressed-Foreground der Topbar-Buttons explizit auf weiss gesetzt.
- Lesbarkeitsprobleme in den Bereichen `Current File` und Connector-Panel behoben.
- JSON Editor und JSON Preview auf responsives 1:1-Layout umgestellt (statt fixer Hoehen).
- Mindesthoehen fuer beide JSON-Bereiche gesetzt, damit die Bedienbarkeit bei kleineren Fensterhoehen erhalten bleibt.

## Einordnung

Diese Aenderungen sind bewusst als Stabilisierungsschritt zu sehen. Das eigentliche Epic bleibt weiterhin offen, bis die Zielarchitektur vollstaendig umgesetzt ist:

- Vollstaendige Entfernung von `FluentTheme`
- Zentrales Token-System (`Tokens.axaml`)
- Eigene ControlTemplates fuer Kern-Controls
- Migration weg von Inline-Styles in allen Views
- Dokumentation des finalen Design-Systems