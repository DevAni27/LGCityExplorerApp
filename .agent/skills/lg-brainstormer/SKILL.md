# lg-brainstormer

## Name
lg-brainstormer — Liquid Galaxy Flutter App Idea Generator

## Description
Generates well-scoped, technically feasible app ideas for the Liquid Galaxy Flutter platform.
Use this skill at the very start of a new project to define WHAT to build before HOW.
Do not skip this skill — building without a plan produces apps that don't fit the LG paradigm.

---

## The LG App Paradigm (internalize this)
A good Liquid Galaxy app is NOT a phone app that happens to run on a tablet.
It is a **geo-spatial, multi-screen, visually immersive experience** that uses:
- KML to show data ON the LG screens (not just in the Flutter UI)
- `flyTo` / camera movements to navigate Google Earth
- The left and right slave screens for logos, legends, or context panels
- Real-time or API-driven data that benefits from map visualization

Bad idea: "A to-do list app for LG" ← no geo, no KML, pointless on LG
Good idea: "Live flight tracker showing planes over a city as KML placemarks" ✓

---

## Brainstorm process (follow exactly)

### Step 1 — Define the domain
Ask (or infer from user prompt):
- What real-world data domain? (flights, weather, earthquakes, ships, satellites, ISS, wildfires…)
- Is there a free, accessible API for it?
- Does it have lat/lon coordinates? (required for KML)

### Step 2 — Define the LG experience
Answer:
1. What does the CENTER screen show? (Google Earth flyTo target)
2. What KML appears on screen? (Placemarks? Polygons? Paths? 3D models?)
3. What does the LEFT slave screen show? (logo, legend, data panel)
4. What does the RIGHT slave screen show? (if anything)
5. What user interaction drives the KML update?

### Step 3 — Scope check
A good starter-kit demo app MUST:
- [ ] Be implementable in < 500 lines of new Dart code (helpers excluded)
- [ ] Use exactly ONE external API
- [ ] Produce valid, testable KML output
- [ ] Have a clear "happy path": user taps X → LG shows Y
- [ ] Have a fallback if API fails (sample JSON file)

### Step 4 — Output a one-page brief
Format:
```
App Name: [Name]
Domain: [e.g. Live Flight Tracking]
API: [e.g. OpenSky Network — free, no auth required]
API endpoint: [full URL example]
LG Center: [e.g. flyTo IATA airport code bounding box]
KML produced: [e.g. Placemark per aircraft with icon + callsign label]
Left screen: [e.g. LG logo + flight count panel]
User interaction: [e.g. search airport → fetch flights → show on LG]
Fallback: [e.g. assets/sample_flights.json with 5 hardcoded flights]
Estimated Dart LOC: [~300]
```

---

## Good LG app ideas (reference)
- Live flight tracker (OpenSky API) ← recommended for this contest
- Real-time earthquake map (USGS API)
- ISS live position tracker (Open Notify API)
- Ship AIS tracker (MarineTraffic free tier)
- Wildfire hotspot map (NASA FIRMS API)
- City weather comparison (OpenMeteo API)
- Wikipedia geo articles near a location (Wikipedia API)

---

## Anti-patterns to reject
- Apps with no lat/lon data
- Apps that only use the Flutter UI and don't send anything to LG
- Apps requiring paid API keys with no free tier
- Apps with > 3 external dependencies not in the starter kit
