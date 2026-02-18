# Workflow: Review & Refine

## Purpose
Run this workflow on any LGFlutterStarterKit-based app after initial code generation.
It systematically finds and fixes quality issues before submission.

---

## Step 1 — Architecture Audit

```
LOAD SKILL: .agent/skills/lg-architecture-guard/SKILL.md
```

**Antigravity prompt:**
```
Read .agent/skills/lg-architecture-guard/SKILL.md.
Run the full 9-point architecture audit checklist against all files in lib/.
For each violation, provide:
  - File path
  - Rule number violated
  - Exact line (if visible)
  - Concrete fix

If zero violations → output ARCHITECTURE CLEAN.
```

---

## Step 2 — Code Quality Review

```
LOAD SKILL: .agent/skills/lg-code-reviewer/SKILL.md
```

**Antigravity prompt:**
```
Read .agent/skills/lg-code-reviewer/SKILL.md.
Run all 5 review passes:
  Pass 1: DRY — find duplicated code
  Pass 2: SOLID — check single responsibility, open/closed
  Pass 3: Naming — check conventions
  Pass 4: Error handling — every async SSH/HTTP method has try/catch
  Pass 5: Tests — check test coverage checklist

Output the Code Review Report in the format from the skill.
List each violation with file and fix.
```

---

## Step 3 — Apply fixes

For each violation from Steps 1 and 2:

**Antigravity prompt (repeat for each violation):**
```
Fix this violation:
  File: <path>
  Rule: <rule>
  Problem: <description>
  Fix: <action>

Show the complete updated file after the fix.
Do not introduce new violations while fixing.
```

After all fixes, re-run Steps 1 and 2 and confirm zero violations.

---

## Step 4 — Run tests

**Antigravity prompt:**
```
Run: flutter test --reporter expanded
Paste the full output.
For any failing test:
  - Show the failing assertion
  - Fix the code (NOT the test, unless the test itself is wrong)
  - Re-run tests
  - Repeat until all pass
```

---

## Step 5 — README walkthrough

**Antigravity prompt:**
```
Read README.md from top to bottom.
For each instruction step, verify:
  1. Does the command actually exist and work?
  2. Are prerequisites correctly listed?
  3. Is the LG connection setup explained clearly?
  4. Is there a troubleshooting section?

Flag any step that is unclear, wrong, or missing.
Then update README.md to fix all flagged issues.
Output the complete updated README.md.
```

---

## Step 6 — Skeptical Mentor final gate

```
LOAD SKILL: .agent/skills/lg-skeptical-mentor/SKILL.md
```

**Antigravity prompt:**
```
Read .agent/skills/lg-skeptical-mentor/SKILL.md.
Ask me all 6 interrogation questions one by one.
Do not accept vague answers.
Do not output SKEPTICAL MENTOR SATISFIED until all 6 questions
have been answered with real evidence (logs, KML output, test results).
Begin with Question 1.
```

---

## Completion criteria
```
[ ] Architecture audit: CLEAN (0 violations)
[ ] Code review: CLEAN (0 violations)
[ ] flutter test: all pass
[ ] README: every step verified
[ ] Skeptical mentor: SATISFIED
```

When all 5 boxes are checked → this app is ready for submission.
