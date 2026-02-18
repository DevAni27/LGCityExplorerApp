# lg-init

## Name
lg-init — Liquid Galaxy Flutter Project Initialiser

## Description
Verifies the project is correctly set up before any code generation begins.
Run this skill FIRST before any other. If any check fails, STOP and fix it.

---

## Checks (run in order)

### 1. Flutter environment
```bash
flutter --version   # must be >= 3.19
dart --version      # must be >= 3.3
flutter doctor -v   # no fatal errors
```
If flutter not installed → "STOP: Install Flutter SDK >= 3.19 before proceeding."

### 2. Required pubspec.yaml dependencies
These packages MUST be present:
| Package | Purpose |
|---|---|
| `dartssh2` | SSH connection to LG rig |
| `provider` | state management (mandatory) |
| `shared_preferences` | persist LG settings across sessions |
| `flutter_lints` | code quality |

Missing `dartssh2` or `provider` → "STOP: Missing critical dependency."

### 3. Folder structure check
```
lib/
  controllers/
    ssh_controller.dart       ← REQUIRED
    settings_controller.dart  ← REQUIRED
    lg_controller.dart        ← REQUIRED
  helpers/
    kml_helper.dart           ← REQUIRED
    snackbar_helper.dart      ← REQUIRED
  models/
  views/
    home/
    settings/
    widgets/
  constants/
    app_constants.dart        ← REQUIRED
test/
.agent/
  skills/
  workflows/
```
For each missing item → "MISSING: <path> — create before proceeding."

### 4. Provider wiring (main.dart)
- `MultiProvider` at root ✓
- `SshController`, `SettingsController`, `LgController` all registered ✓
- `ChangeNotifierProvider` used (NOT bare `Provider`) ✓

Failure → "ARCHITECTURE VIOLATION: Provider not wired correctly in main.dart."

### 5. SshController contract
These public methods MUST exist:
- `Future<void> connect(String host, int port, String username, String password)`
- `Future<String> runCommand(String command)`
- `Future<void> disconnect()`
- `bool get isConnected`

Missing method → "CONTRACT VIOLATION: SshController missing <method>."

### 6. Settings persistence
- Settings saved via `shared_preferences` (not in-memory only)
- `loadSettings()` called on controller init
- `notifyListeners()` called after every update

In-memory only → "BUG: Settings lost on restart. Use shared_preferences."

---

## Output format

✅ Success:
```
✅ lg-init PASSED
  Flutter: OK ✓  |  Dependencies: OK ✓  |  Structure: OK ✓
  Provider wiring: OK ✓  |  SSH contract: OK ✓  |  Persistence: OK ✓
→ Proceed to lg-plan-writer
```

❌ Failure:
```
❌ lg-init FAILED
  - MISSING: lib/controllers/lg_controller.dart
  - BUG: Settings are in-memory only
DO NOT proceed until all failures are resolved.
```

---

## Quick fixes
| Failure | Command |
|---|---|
| Missing dartssh2 | `flutter pub add dartssh2` |
| Missing provider | `flutter pub add provider` |
| Missing shared_preferences | `flutter pub add shared_preferences` |
| In-memory settings | Inject SharedPreferences, call prefs.setString() in each updater |
