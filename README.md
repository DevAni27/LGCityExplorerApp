# LG Flutter Starter Kit

A production-ready skeleton for building **Liquid Galaxy Flutter applications** — complete with an agentic AI system (`.agent/`) that teaches Gemini in Google Antigravity to generate new LG apps from scratch.

Built for the **Gemini Summer of Code 2026** contest by the Liquid Galaxy project.

---

## What this is (and isn't)

✅ **IS**: A skeleton app with best-practice bones (MVC, Provider, SSH, KML) + a full AI agent system that can generate a complete feature app on top of it.

❌ **IS NOT**: A finished application. There are no domain-specific features here by design.

---

## Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | ≥ 3.19 |
| Dart SDK | ≥ 3.3 |
| A Liquid Galaxy rig | LG OS 2.x |
| sshpass (on LG master) | any |

Check your environment:
```bash
flutter --version
flutter doctor -v
```

---

## Quick Start

### 1. Clone & install dependencies
```bash
git clone https://github.com/YOUR_USERNAME/LGFlutterStarterKit.git
cd LGFlutterStarterKit
flutter pub get
```

### 2. Run the app
```bash
# On a connected Android tablet or emulator:
flutter run

# For debug output:
flutter run --verbose
```

### 3. Connect to your LG rig
1. Open the app → tap the **Settings** icon (top-right)
2. Enter:
   - **LG Master IP** — e.g. `192.168.1.100`
   - **SSH Port** — default `22`
   - **Username** — default `lg`
   - **Password** — your LG password
   - **Number of Rigs** — `1`, `3`, or `5`
3. Tap **Save**, then **Connect**
4. The dot in the top-right turns **green** when connected

### 4. Try the LG control panel
Bottom strip controls (requires connection):
- **Logo** — sends the LG logo to the left slave screen
- **Clear** — removes all KML from LG screens
- **Relaunch** — restarts Google Earth on the rig
- **Shutdown** — powers off the rig (confirmation dialog shown)

### 5. Run tests
```bash
flutter test
# Expected: All tests passed
```

---

## Using the AI agent system

The `.agent/` folder contains the full Gemini Antigravity agent system.

### Workflow to build a new app on top of this kit

Open Google Antigravity and run this sequence:

```
Step 1:  Load .agent/skills/lg-init/SKILL.md       → verify environment
Step 2:  Load .agent/skills/lg-brainstormer/SKILL.md → define what to build
Step 3:  Load .agent/skills/lg-plan-writer/SKILL.md  → write full implementation plan
Step 4:  Load .agent/skills/lg-architecture-guard/SKILL.md → validate plan
Step 5:  Generate code (lg-kml-builder + lg-flight-api-opensky + lg-networklink)
Step 6:  Load .agent/skills/lg-code-reviewer/SKILL.md → review generated code
Step 7:  Load .agent/skills/lg-skeptical-mentor/SKILL.md → demand proof it works
```

Or run the full end-to-end workflow:
```
.agent/workflows/build_flight_tracker_demo.md
```

### Skills reference
| Skill | Purpose |
|---|---|
| `lg-init` | Environment & structure verification gate |
| `lg-brainstormer` | App idea generation with LG paradigm check |
| `lg-plan-writer` | Forces 7-section plan before any code |
| `lg-architecture-guard` | MVC/Provider/KML layer enforcement |
| `lg-kml-builder` | KML generation rules and templates |
| `lg-flight-api-opensky` | OpenSky API integration guide |
| `lg-networklink` | LG SSH + file delivery conventions |
| `lg-code-reviewer` | DRY/SOLID/naming/error handling checks |
| `lg-skeptical-mentor` | Final proof-of-work gate |

---

## Project structure
```
LGFlutterStarterKit/
├── .agent/
│   ├── skills/                    ← AI agent skills (9 total)
│   ├── workflows/
│   │   ├── build_flight_tracker_demo.md
│   │   └── review_and_refine.md
│   └── docs/
│       └── architecture-map.md
├── lib/
│   ├── main.dart                  ← MultiProvider root
│   ├── constants/
│   │   └── app_constants.dart     ← All LG paths, defaults, airport lookup
│   ├── controllers/
│   │   ├── ssh_controller.dart    ← SSH transport (dartssh2 wrapper)
│   │   ├── settings_controller.dart ← Persistent LG config
│   │   └── lg_controller.dart     ← KML, flyTo, slaves, system controls
│   ├── helpers/
│   │   ├── kml_helper.dart        ← ALL KML generation (static methods)
│   │   └── snackbar_helper.dart   ← Consistent UI feedback
│   ├── models/                    ← Add domain models here
│   └── views/
│       ├── home/home_page.dart    ← Main screen skeleton
│       ├── settings/settings_page.dart
│       └── widgets/
│           ├── connection_status_dot.dart
│           └── lg_control_panel.dart
├── test/
│   └── kml_helper_test.dart
└── pubspec.yaml
```

---

## Architecture principles

This kit enforces **MVC + Provider** as the mandatory pattern:

| Layer | Responsibility | Forbidden |
|---|---|---|
| `models/` | Pure data classes | Flutter, SSH, API |
| `helpers/` | Stateless utilities | State, notifyListeners |
| `controllers/` | Business logic, SSH, API | Widget code |
| `views/` | UI only | Direct SSH, inline KML |

---

## Building your own app on this skeleton

1. **Do not rename or move** any existing file in `lib/`
2. **Add** new controllers in `lib/controllers/`
3. **Add** new models in `lib/models/`
4. **Extend** `KmlHelper` with new static methods — never build KML inline
5. **Replace** `_FeaturePlaceholder` in `home_page.dart` with your UI
6. **Register** new controllers in `main.dart`'s `MultiProvider`

See `.agent/workflows/build_flight_tracker_demo.md` for a complete worked example.

---

## Demo app

The companion demo app **LGFlightTrackerDemo** was generated using this kit + agent system:
👉 [github.com/YOUR_USERNAME/LGFlightTrackerDemo](https://github.com/YOUR_USERNAME/LGFlightTrackerDemo)

It shows live flights near any airport on Liquid Galaxy screens using the free OpenSky Network API.

---

## License

MIT License — same as the Liquid Galaxy project.

---

## Acknowledgements
- Liquid Galaxy project mentors Victor Sanchez & team
- OpenSky Network for the free flight data API
- dartssh2 package authors
