# LG Flutter Starter Kit — Agent Instructions

You are an AI coding agent helping build Flutter applications for the **Liquid Galaxy** platform.

Before doing ANYTHING else — before planning, before writing code, before analyzing files — you MUST read and internalize the skills in `.agent/skills/`. They define the rules, patterns, and gates you must follow for every task in this project.

## Mandatory skill loading order

Read these files NOW, in this order:

1. `.agent/skills/lg-init/SKILL.md` — environment & structure checks
2. `.agent/skills/lg-brainstormer/SKILL.md` — how to scope LG app ideas
3. `.agent/skills/lg-plan-writer/SKILL.md` — mandatory planning gate
4. `.agent/skills/lg-architecture-guard/SKILL.md` — MVC/Provider/KML rules
5. `.agent/skills/lg-kml-builder/SKILL.md` — KML generation rules
6. `.agent/skills/lg-networklink/SKILL.md` — LG SSH delivery conventions
7. `.agent/skills/lg-flight-api-opensky/SKILL.md` — OpenSky API integration
8. `.agent/skills/lg-code-reviewer/SKILL.md` — DRY/SOLID quality checks
9. `.agent/skills/lg-skeptical-mentor/SKILL.md` — proof-of-work final gate

After reading all skills, confirm with:
```
✅ Skills loaded: 9/9
Ready to assist with LG Flutter development.
```

---

## What this project is

This is the **LGFlutterStarterKit** — a skeleton Flutter app with best-practice bones for building Liquid Galaxy applications. It is NOT a finished app. It is a starting point.

Architecture: **MVC + Provider**
SSH library: `dartssh2`
State management: `provider` only
Settings persistence: `shared_preferences`

### The golden rules (never break these)
- All SSH goes through `SshController` only
- All KML strings are built in `KmlHelper` only  
- All config comes from `SettingsController` only
- Views contain zero SSH calls and zero KML string building
- Never restructure the existing `lib/` folder layout
- Never replace `Provider` with another state management solution

---

## How to handle user requests

### If user asks to build a new feature or app:

Execute ONE phase at a time. After each phase, STOP and wait for the user
to explicitly approve before moving to the next phase. Never combine phases.

```
Phase 1: lg-init    → validate environment & structure
         STOP → show results → wait for user
         
Phase 2: lg-brainstormer → validate idea fits LG paradigm, output one-page brief  
         STOP → show brief → wait for user approval

Phase 3: lg-plan-writer → write full 7-section plan
         STOP → show plan → output "⏸ WAITING FOR APPROVAL — type 'proceed' to begin coding"
         → wait for user to explicitly approve

Phase 4: lg-architecture-guard → audit plan against architecture rules
         STOP → show audit results → wait for user

Phase 5: Code generation — one file at a time
         Generate file → STOP → show file → wait for user → next file
         Order: models → constants → helpers → controllers → views → main.dart

Phase 6: lg-code-reviewer → run all 5 review passes on generated code
         STOP → show report → wait for user

Phase 7: lg-skeptical-mentor → ask all 6 proof questions one at a time
         One question per response → wait for answer → next question
```

This step-by-step approach is mandatory. It shows the agent's reasoning
and allows the user to course-correct at each phase.

### If user asks to review existing code:
→ Run `lg-code-reviewer` then `lg-architecture-guard`

### If user asks to fix a bug:
→ Run `lg-architecture-guard` after the fix to ensure no violations introduced

### If user asks a general question about LG or KML:
→ Answer using knowledge from the relevant skill files

---

## Project structure (read-only, do not restructure)
```
lib/
  main.dart                        ← MultiProvider root, do not modify wiring
  constants/app_constants.dart     ← all magic values live here
  controllers/
    ssh_controller.dart            ← ONLY dartssh2 entry point
    settings_controller.dart       ← shared_preferences persistence
    lg_controller.dart             ← all LG hardware operations
  helpers/
    kml_helper.dart                ← ALL KML string generation (extend only)
    snackbar_helper.dart           ← UI feedback utility
  models/                          ← add new domain models here
  views/
    home/home_page.dart            ← replace _FeaturePlaceholder for new apps
    settings/settings_page.dart
    widgets/
test/
  kml_helper_test.dart
.agent/
  skills/                          ← you are reading from here right now
  workflows/
  docs/
```

---

## Workflow files
For end-to-end app generation, refer to:
- `.agent/workflows/build_flight_tracker_demo.md` — full 9-phase build guide
- `.agent/workflows/review_and_refine.md` — quality gate loop
