# Dispatch Assignment: m1_worker_1

## 2026-09-01T12:27:25Z
## Task
You are m1_worker_1 (Brand & Visual System Worker).
Your working directory: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m1_worker_1`.
Read:
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\ORIGINAL_REQUEST.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\PROJECT.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m1_explorer_1\report.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m1_explorer_2\report.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m1_explorer_3\report.md`

## Owned Files Exclusively
- `config/settings_data.json`
- `sections/header.liquid`
- `sections/header-group.json`
- `layout/theme.liquid`
- `assets/base.css`

## Implementation Steps
1. In `config/settings_data.json`:
   - Update `color_schemes` with schemes 1–5 using FocusDrawer palette:
     - `scheme-1`: Background `#121212`, Text `#FFFFFF`, Button `#E5A93C`, Button Text `#121212`, Secondary Button Text `#FFFFFF`, Shadow `#000000`.
     - `scheme-2`: Background `#1E1E1E`, Text `#FFFFFF`, Button `#E5A93C`, Button Text `#121212`, Secondary Button Text `#FFFFFF`.
     - `scheme-3`: Background `#E5A93C`, Text `#121212`, Button `#121212`, Button Text `#FFFFFF`.
     - `scheme-4`: Background `#121212`, Text `#FFFFFF`, Button `#E5A93C`, Button Text `#121212`.
     - `scheme-5`: Background `#FFFFFF`, Text `#121212`, Button `#121212`, Button Text `#FFFFFF`.
   - Configure `logo_width: 160`, `heading_scale: 115`, `body_scale: 105`, `buttons_radius: 8`, `buttons_shadow_opacity: 0`, `badge_corner_radius: 40`, `sale_badge_color_scheme: "scheme-3"`, `sold_out_badge_color_scheme: "scheme-2"`, `drawer_color_scheme: "scheme-2"`, `card_style: "card"`, `card_color_scheme: "scheme-2"`, `card_corner_radius: 12`.
2. In `sections/header.liquid` and `layout/theme.liquid`:
   - Ensure clean logo rendering and fallback to `assets/focusdrawer-logo.png` so that FocusDrawer logo renders crisply on both desktop and mobile headers.
   - Ensure favicon link references `focusdrawer-logo.png` fallback in `layout/theme.liquid`.
3. In `assets/base.css`:
   - Ensure gold focus ring tokens (`#E5A93C`), hover states, and primary button styles are aligned with FocusDrawer brand specifications.
4. Run validation and tests:
   - Run `powershell -ExecutionPolicy Bypass -File tests/run_e2e_tests.ps1` to ensure all tests pass and zero schema/syntax errors exist.
5. Write your report to `report.md` and complete with `handoff.md`.

## Mandatory Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
