# Dispatch Assignment: m2_worker_1

## Task
You are m2_worker_1 (Navigation & Cart Drawer Worker).
Your working directory: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m2_worker_1`.
Read:
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\ORIGINAL_REQUEST.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\PROJECT.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m2_explorer_1\report.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m2_explorer_2\report.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m2_explorer_3\report.md`

## Owned Files Exclusively
- `sections/announcement-bar.liquid`
- `sections/header-group.json`
- `snippets/header-drawer.liquid`
- `snippets/cart-drawer.liquid`
- `assets/component-cart-drawer.css`
- `assets/component-menu-drawer.css`
- `assets/component-list-menu.css`

## Implementation Steps
1. In `sections/header-group.json` & `sections/announcement-bar.liquid`:
   - Configure branded announcement bar with `scheme-3` (Gold accent), text: "FREE SHIPPING ON WORKSPACE BUNDLES OVER $50 ✦ 30-DAY SETUP GUARANTEE", and catalog link.
   - Configure mobile drawer with `scheme-2` (Elevated charcoal surface).
2. In `snippets/header-drawer.liquid` & `assets/component-menu-drawer.css`:
   - Ensure clean responsive mobile drawer navigation with gold active indicators and accessibility compliance.
3. In `snippets/cart-drawer.liquid` & `assets/component-cart-drawer.css`:
   - Implement the interactive Free Shipping Progress Meter inside `.drawer__inner` with a 5000 cents ($50.00) threshold:
     - When `cart.total_price < 5000`: Calculate remaining amount (`remaining = 5000 | minus: cart.total_price | money`) and percentage (`progress_pct = cart.total_price | times: 100 | divided_by: 5000 | at_most: 100`).
     - When `cart.total_price >= 5000`: Show unlocked state "🎉 You've unlocked FREE Shipping on your workspace setup!" with 100% bar width.
     - Progress bar styled with FocusDrawer gold fill (`#E5A93C`) and dark charcoal track (`#2D2D2D`).
4. Run tests:
   - Run `powershell -ExecutionPolicy Bypass -File tests/run_e2e_tests.ps1` to confirm 100% test pass.
5. Write report to `report.md` and complete with `handoff.md`.

## Mandatory Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
