# Dispatch Assignment: m4_worker_1

## Task
You are m4_worker_1 (Product & Collection Worker).
Your working directory: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m4_worker_1`.
Read:
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\ORIGINAL_REQUEST.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\PROJECT.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m4_explorer_1\report.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m4_explorer_2\report.md`
- `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\m4_explorer_3\report.md`

## Owned Files Exclusively
- `templates/product.json`
- `templates/collection.json`
- `sections/main-product.liquid`
- `snippets/sticky-atc.liquid`
- `assets/section-main-product.css`

## Implementation Steps
1. In `templates/product.json`:
   - Configure `main` section with `gallery_layout: "thumbnail_slider"`, `media_size: "large"`, `mobile_thumbnails: "show"`, `image_zoom: "lightbox"`, `enable_sticky_info: true`.
   - Configure variant picker with pill buttons (`picker_type: "button"`).
   - Configure 4 expandable technical spec accordions (`collapsible_tab` blocks):
     1. Dimensions & Desk Compatibility (icon: `ruler`)
     2. Materials & Engineering (icon: `check_mark`)
     3. Cable Routing & Power Hub (icon: `lightning_bolt`)
     4. Lifetime Warranty & 30-Day Guarantee (icon: `star`)
   - Configure trust badge strip (`icon_with_text`).
2. Sticky "Add to Cart" on scroll:
   - Implement sticky ATC component (in `sections/main-product.liquid` or `snippets/sticky-atc.liquid` and `assets/section-main-product.css`) synchronized with variant picker and primary product form.
   - Styled with FocusDrawer gold button (`#E5A93C`) and dark charcoal container (`#1E1E1E`).
3. In `templates/collection.json`:
   - Configure modular collection grid (4 desktop columns), faceted filters, sorting, and quick add.
4. Run tests:
   - Run `powershell -ExecutionPolicy Bypass -File tests/run_e2e_tests.ps1` to confirm 100% test pass.
5. Write report to `report.md` and complete with `handoff.md`.

## Mandatory Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
