# Architecture Map — LGFlutterStarterKit

## Dependency graph
```
main.dart
└── MultiProvider
    ├── SshController          ← dartssh2 only
    ├── SettingsController     ← shared_preferences only
    └── LgController           ← SshController + SettingsController + KmlHelper

views/*                        ← context.read/watch ONLY (no direct instantiation)
helpers/kml_helper.dart        ← static methods, zero dependencies
helpers/snackbar_helper.dart   ← BuildContext only
models/*                       ← pure Dart, no Flutter imports
```

## Layer rules (enforced by lg-architecture-guard)
| Layer | May import | May NOT import |
|---|---|---|
| models/ | dart:core only | flutter, dartssh2, provider |
| helpers/ | dart:core, models/ | flutter, dartssh2, provider |
| controllers/ | flutter/foundation, helpers/, models/, dartssh2 (SSH only), provider | flutter/material (no widgets) |
| views/ | flutter/material, provider (context.read/watch), models/ | dartssh2, direct controller instantiation |

## Folder structure
```
lib/
  main.dart                  ← app entry point, MultiProvider root
  constants/
    app_constants.dart       ← ALL magic strings/numbers live here
  controllers/
    ssh_controller.dart      ← SSH transport layer (dartssh2 wrapper)
    settings_controller.dart ← persistent LG config
    lg_controller.dart       ← LG hardware operations (KML, flyTo, cleanup)
  helpers/
    kml_helper.dart          ← ALL KML string generation
    snackbar_helper.dart     ← UI feedback utility
  models/                    ← pure data classes (add per-app models here)
  views/
    home/
      home_page.dart         ← main screen skeleton
    settings/
      settings_page.dart     ← LG connection settings
    widgets/
      connection_status_dot.dart
      lg_control_panel.dart
test/
  kml_helper_test.dart       ← unit tests for KML generation
```
