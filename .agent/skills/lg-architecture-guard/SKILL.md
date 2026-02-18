# lg-architecture-guard

## Name
lg-architecture-guard — Structure & Pattern Enforcement

## Description
The secret weapon. Enforces that generated code follows the starter kit's architecture.
Run this skill AFTER lg-plan-writer and AFTER every major code generation step.
Any violation found must be fixed before the next step proceeds.

---

## The non-negotiable rules

### RULE 1 — MVC Layer Separation
```
models/     → Pure data classes. No Flutter imports. No SSH. No UI logic.
controllers/ → Business logic. SSH calls. API calls. State. NO Widget code.
views/      → Widgets ONLY. No SSH. No direct API calls. No KML string building.
helpers/    → Stateless utility functions. Pure input→output. No state. No notifyListeners().
```

Violation check — scan every file:
- A file in `models/` that imports `package:flutter/material.dart` → VIOLATION
- A file in `views/` that calls `sshController.runCommand()` directly → VIOLATION
- A file in `helpers/` that calls `notifyListeners()` → VIOLATION
- A controller that contains `Widget build()` → VIOLATION

### RULE 2 — Provider is the only state management
- No `setState()` in any file outside of `StatefulWidget` that manages only LOCAL UI state (e.g. text field focus)
- No `BLoC`, `Riverpod`, `GetX`, `MobX` — ONLY `provider`
- No `StreamBuilder` connected directly to SSH — route through a controller

### RULE 3 — SshController is the ONLY SSH entry point
No code outside `SshController` may import or instantiate `dartssh2` directly.
All SSH commands go through `sshController.runCommand(cmd)`.

Violation → "ARCHITECTURE VIOLATION: Direct SSH usage outside SshController in <file>."

### RULE 4 — KML is only built in KmlHelper
No raw KML string concatenation anywhere except `lib/helpers/kml_helper.dart`.
Controllers may call `KmlHelper.someMethod()` but NEVER build `<kml>...</kml>` strings inline.

Violation → "ARCHITECTURE VIOLATION: Inline KML in <file>:<line>."

### RULE 5 — SettingsController owns all config
No hardcoded IPs, ports, usernames, or passwords anywhere.
All such values come from `settingsController.<property>`.

### RULE 6 — Demo app inherits, does not fork
The demo app (LGFlightTrackerDemo) MUST:
- Reference the same MVC structure (copy it as a starting point, not rewrite it)
- NOT redefine SshController or SettingsController from scratch
- NOT duplicate KmlHelper methods — extend it instead

---

## Architecture audit checklist
Run after code generation is complete:

```
[ ] models/ files: zero Flutter imports
[ ] views/ files: zero runCommand() calls
[ ] helpers/ files: zero notifyListeners() calls
[ ] All state via Provider, zero BLoC/Riverpod/GetX
[ ] Zero dartssh2 imports outside ssh_controller.dart
[ ] Zero KML string building outside kml_helper.dart
[ ] Zero hardcoded IPs or credentials
[ ] SettingsController uses shared_preferences (not in-memory)
[ ] LgController depends on SshController + SettingsController (not directly on dartssh2)
```

For every unchecked box → output:
```
❌ ARCHITECTURE VIOLATION
File: <path>
Rule: <rule number and name>
Problem: <what is wrong>
Fix: <concrete action to fix>
```

---

## Approved dependency graph
```
main.dart
  └── MultiProvider
        ├── SshController          (ChangeNotifier, depends on: dartssh2 only)
        ├── SettingsController     (ChangeNotifier, depends on: shared_preferences only)
        └── LgController           (depends on: SshController + SettingsController + KmlHelper)

views/*
  └── context.read/watch Provider  (NO direct instantiation of controllers)

helpers/kml_helper.dart            (static methods, no dependencies)
helpers/snackbar_helper.dart       (static/global function, depends on: BuildContext only)
```

Any arrow not in this diagram is a VIOLATION.

---

## Output
All clear:
```
✅ lg-architecture-guard PASSED — 9/9 checks green
→ Proceed to lg-kml-builder or lg-code-reviewer
```

Violations found:
```
❌ lg-architecture-guard FAILED
  [list each violation with file, rule, fix]
Fix all violations before proceeding.
```
