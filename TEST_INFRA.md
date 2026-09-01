# FocusDrawer Shopify Dawn Theme: Test Infrastructure Specification

**Document Version**: 1.0.0  
**Architect**: `e2e_test_writer_1` (E2E Test Suite Architect)  
**Target Repository**: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn`  
**Brand**: FocusDrawer (Premium Desk Organization & Workspace Setup)  
**Integrity Mode**: Development / CI Ready  

---

## 1. Overview & Test Strategy

The **FocusDrawer Dawn Theme Test Infrastructure** is an automated, opaque-box, deterministic testing framework engineered natively in **PowerShell 5.1 / .NET CLR 4.8** with zero third-party package dependencies. It is purpose-built to validate Shopify Online Store 2.0 (OS 2.0) theme assets, Liquid templates, sections, snippets, JSON schemas, CSS design tokens, and front-end JavaScript component integrations.

### 1.1 Key Testing Pillars
1. **Opaque-Box Architectural Verification**: Validates theme functionality, Liquid tag pairing, JSON schemas, and CSS/JS interfaces against requirements without coupling to internal ephemeral implementation details.
2. **Deterministic & Self-Contained Execution**: All tests execute statelessly in milliseconds, ensuring reproducibility in local development and automated CI/CD pipelines.
3. **Multi-Tiered Depth**: Structured into 4 distinct verification tiers ranging from unit-level feature contracts to complex full-journey simulation workloads.
4. **Adversarial Resilience**: Stresses parser edge cases, extreme variant counts, threshold arithmetic, missing brand assets, and multi-scheme CSS variable collisions.

---

## 2. Runtime Environment & Tooling Architecture

The test harness leverages native Windows and PowerShell capabilities:

| Subsystem | Technology | Purpose |
|---|---|---|
| **Scripting Host** | PowerShell 5.1 / 7+ | Command orchestration, test execution, colorized terminal reporting, exit code signaling. |
| **JSON Engine** | `ConvertFrom-Json` & `.NET JavaScriptSerializer` | Strict RFC 8259 validation for `templates/*.json`, `config/settings_*.json`, `locales/*.json`, and section `{% schema %}` blocks. |
| **Liquid Tokenizer** | .NET `System.Text.RegularExpressions` | AST-style delimiter balancing, paired tag stack verification (`if`, `unless`, `case`, `for`, `form`, `paginate`, `capture`, `style`), and inline `{% liquid %}` block parsing. |
| **Asset Image Decoder** | .NET `System.Drawing.Bitmap` / `Image` | Binary inspection of `assets/focusdrawer-logo.png` (dimensions, ARGB bit-depth, file integrity). |
| **Template Graph Analyzer** | Custom Object Graph Traversal | Section dependency mapping, block schema validation, `order` array integrity, and dead reference detection. |

---

## 3. Test Suite Architecture: The 4-Tier Model

```
┌────────────────────────────────────────────────────────────────────────┐
│                   FOCUSDRAWER 4-TIER TEST ARCHITECTURE                 │
├────────────────────────────────────────────────────────────────────────┤
│ TIER 1: FEATURE COVERAGE (≥5 Tests per Requirement Category R1-R4)    │
│  ├── R1: Brand Identity & Visual System (Logo, Schemes 1-5, CSS Vars) │
│  ├── R2: Home Page Showcase (Hero, 3 Pillars, Grid, Specs, Reviews)   │
│  ├── R3: Product Page (Gallery Slider, Accordions, Sticky ATC, Pills) │
│  └── R4: Navigation & Cart (Announcement Bar, Drawer Nav, Meter)       │
├────────────────────────────────────────────────────────────────────────┤
│ TIER 2: BOUNDARY & CORNER CASES (≥5 Tests per Feature Category)       │
│  ├── Edge 1: Empty cart / $0.00 subtotal zero-division prevention     │
│  ├── Edge 2: Threshold exact match ($75.00) & overshoot ($150.00)     │
│  ├── Edge 3: Missing logo asset graceful fallback to SVG/text         │
│  ├── Edge 4: Sold out / unavailable variant disablement in Sticky ATC │
│  ├── Edge 5: Malformed JSON and trailing comma rejection              │
│  └── Edge 6: Viewport extremes (<320px mobile to 4K ultra-wide)       │
├────────────────────────────────────────────────────────────────────────┤
│ TIER 3: CROSS-FEATURE INTERACTIONS (Pairwise Multi-Component Tests)   │
│  ├── Pair 1: Color Scheme isolation across Header, Body, & Cards      │
│  ├── Pair 2: Quick-Add to Cart Drawer -> Dynamic Shipping Meter Calc  │
│  ├── Pair 3: Sticky ATC Variant Picker -> Main Form Synchronization   │
│  ├── Pair 4: Mobile Nav Drawer Open -> Body Scroll Lock -> Cart Modal │
│  └── Pair 5: Collection Facet Filters -> Product Grid Card Hover State│
├────────────────────────────────────────────────────────────────────────┤
│ TIER 4: REAL-WORLD APPLICATION WORKLOADS (End-to-End User Journeys)   │
│  ├── Journey 1: First-Time Desk Setup Shopper Discovery & Exploration │
│  ├── Journey 2: High-Intent Ergonomic Pro Evaluator & Sticky ATC Flow │
│  ├── Journey 3: Multi-Item Workspace Bundle Builder & Threshold Unlocked
│  └── Journey 4: Responsive Multi-Breakpoint Accessibility & Layout Audit
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Comprehensive Test Inventory & Specification Matrix

### Tier 1: Feature Coverage (Unit & Component Contracts)

| Test ID | Category | Feature Under Test | Expected Behavior / Acceptance Rule |
|---|---|---|---|
| **T1.R1.01** | R1 Brand | Logo Asset Presence & Format | `assets/focusdrawer-logo.png` exists, is valid PNG, min 500x500px, 32-bit ARGB. |
| **T1.R1.02** | R1 Brand | Logo Settings Configuration | `config/settings_data.json` references `focusdrawer-logo.png` and specifies `logo_width` (120-200px). |
| **T1.R1.03** | R1 Brand | 5-Scheme Color Architecture | `config/settings_data.json` configures `scheme-1` through `scheme-5` with matte black `#121212`, `#18181B`/`#1E1E1E`, and Focus Gold `#E5A93C`. |
| **T1.R1.04** | R1 Brand | CSS Token Generation in Theme | `layout/theme.liquid` generates `--color-background`, `--color-foreground`, `--color-button`, `--color-button-text` for all schemes. |
| **T1.R1.05** | R1 Brand | Gold Button & Focus Styling | `assets/base.css` applies `#E5A93C` to primary buttons, active variant rings, and focus visible outlines. |
| **T1.R1.06** | R1 Brand | Typography System Settings | Scaled font settings defined in `settings_data.json` with standard fallbacks. |
| **T1.R2.01** | R2 Home | Modular Hero Showcase | `templates/index.json` contains `image-banner` with FocusDrawer headline, description, and dual CTA buttons. |
| **T1.R2.02** | R2 Home | 3-Pillar Value Proposition | `templates/index.json` contains `multicolumn` detailing "Declutter", "Focus", and "Ergonomics". |
| **T1.R2.03** | R2 Home | Featured Products Grid | `templates/index.json` contains `featured-collection` with `quick_add: "standard"` and desktop/mobile column settings. |
| **T1.R2.04** | R2 Home | Dimensions / Spec Highlights | `templates/index.json` contains interactive technical highlights section (`collapsible-content` / `rich-text` / `multirow`). |
| **T1.R2.05** | R2 Home | Customer Testimonials Section | `templates/index.json` contains customer review cards with star ratings and verified creator quotes. |
| **T1.R3.01** | R3 Product | Product Gallery Settings | `templates/product.json` configures `gallery_layout: "thumbnail_slider"`, `mobile_thumbnails: "show"`, and lightbox zoom. |
| **T1.R3.02** | R3 Product | Dynamic Variant Selector | `templates/product.json` includes `variant_picker` block supporting pill buttons and color finishes. |
| **T1.R3.03** | R3 Product | 4 Technical Spec Accordions | `templates/product.json` includes 4 `collapsible_tab` blocks: Dimensions (`ruler`), Materials (`check_mark`/`box`), Cable Routing (`lightning_bolt`), Warranty (`star`). |
| **T1.R3.04** | R3 Product | Sticky "Add to Cart" Bar | Sticky ATC structure exists in `sections/main-product.liquid` / `assets/sticky-atc.js` or `enable_sticky_info: true`. |
| **T1.R3.05** | R3 Product | Trust Badges & Guarantee | `templates/product.json` or `main-product.liquid` contains trust micro-copy ("30-Day Setup Guarantee", "Lifetime Warranty"). |
| **T1.R4.01** | R4 Nav/Cart | Branded Announcement Bar | `sections/announcement-bar.liquid` / `sections/header-group.json` highlights workspace bundle free shipping and guarantee. |
| **T1.R4.02** | R4 Nav/Cart | Mobile Navigation Drawer | `snippets/header-drawer.liquid` / `sections/header.liquid` contains accessible category navigation and search. |
| **T1.R4.03** | R4 Nav/Cart | Slide-Out Cart Configuration | `config/settings_data.json` defines `cart_type: "drawer"`. |
| **T1.R4.04** | R4 Nav/Cart | Free Shipping Meter Markup | `snippets/cart-drawer.liquid` contains `.cart-drawer__shipping-meter` or `.shipping-meter__progress` with dynamic threshold logic. |
| **T1.R4.05** | R4 Nav/Cart | Cart Drawer CSS & Bar Styling | `assets/component-cart-drawer.css` styles progress bar track and `#E5A93C` gold fill. |

---

### Tier 2: Boundary & Corner Cases (Stress & Resilience)

| Test ID | Area | Scenario / Boundary Condition | Expected Resilience / Behavior |
|---|---|---|---|
| **T2.ED.01** | Cart Meter | Empty Cart (`total_price == 0`) | Progress bar width computes to `0%`, no division by zero or NaN, renders "Add $[Threshold] more" prompt. |
| **T2.ED.02** | Cart Meter | Exact Threshold ($75.00 / 7500 cents) | Progress bar computes to exactly `100%`, renders unlocked celebration text, zero remaining cents. |
| **T2.ED.03** | Cart Meter | Overshoot Subtotal ($150.00 / 15000 cents) | Progress bar capped at `100%` (no overflow width), no negative balance displayed. |
| **T2.ED.04** | Header | Missing or Blank Logo Setting | `sections/header.liquid` gracefully falls back to `shop.name` or default brand SVG without broken `<img>` markup. |
| **T2.ED.05** | Product | Sold-Out Variant State | When variant is unavailable, Sticky ATC button disables, displays "Sold Out", and prevents cart injection. |
| **T2.ED.06** | Product | Single-Variant Product vs Multi-Variant | Sticky ATC dropdown conditionally renders only when `product.has_only_default_variant == false`. |
| **T2.ED.07** | Schemas | Malformed JSON & Trailing Commas | Strict parser rejects invalid JSON in section `{% schema %}` blocks and template JSONs. |
| **T2.ED.08** | Liquid | Unclosed Tag & Delimiter Mismatch | Liquid parser catches unmatched `{% if %}`, `{% for %}`, `{% form %}`, and unclosed `{{ ... }}` tokens. |
| **T2.ED.09** | Layout | Viewport Scalability & Responsive Tokens | CSS rules use fluid clamp/rem units and standard breakpoints (`750px`, `990px`) for seamless rendering. |
| **T2.ED.10** | Accordions | HTML & Special Character Escaping | Accordion titles and contents preserve HTML entity escaping without double-encoded artifacts. |

---

### Tier 3: Cross-Feature Interactions & PubSub Workflows

| Test ID | Interaction Pair | Scope & Flow | Verification Check |
|---|---|---|---|
| **T3.XF.01** | Palette & Theme Isolation | Header (Scheme 4) + Announcement (Scheme 3) + Main (Scheme 1) + Cards (Scheme 2) | All CSS custom properties scoped to respective class containers without cross-scheme variable leakage. |
| **T3.XF.02** | Quick-Add -> Cart Drawer PubSub | User clicks "Quick Add" on Featured Collection card -> Cart Drawer opens -> Shipping Meter recalculates | `cart:update` / `PUB_SUB_EVENTS.cartUpdate` event listeners registered in `cart-drawer.js` / `cart.js`. |
| **T3.XF.03** | Sticky ATC -> Variant Synchronization | User toggles variant pill in main form -> Sticky ATC bar reflects updated title, price, and thumbnail | Bi-directional change listener or form submission sync in `product-info.js` / `sticky-atc.js`. |
| **T3.XF.04** | Drawer Navigation -> Stacking & Scroll Lock | Mobile menu open / Cart drawer open | Body scroll locked via `overflow: hidden`, z-index stacking ensures modals render above sticky header and sticky ATC. |
| **T3.XF.05** | Collection Filters -> Card Quick Add | Collection faceted filters update -> Product cards re-render -> Quick Add button remains functional | Card snippet uses consistent DOM event delegation for AJAX cart addition. |

---

### Tier 4: Real-World Application Scenarios (User Journeys)

| Test ID | User Journey | Narrative / Flow Description | End-to-End Success Criteria |
|---|---|---|---|
| **T4.RW.01** | First-Time Shopper Discovery | Land on Home Hero -> Read 3 Value Pillars -> Inspect Dimension highlights -> Click Featured Product -> View drawer details. | All referenced section types exist, have valid block orders, and resolve template dependencies. |
| **T4.RW.02** | Ergonomic Setup Evaluator | Navigate to Product Page -> Select finish -> Expand 4 Tech Spec Accordions -> Scroll past reviews -> Click Sticky ATC. | `product.json` blocks, collapsible tabs, and sticky ATC hooks correctly structured and connected. |
| **T4.RW.03** | Bundle Builder & Free Shipping | Add Under-Desk Drawer ($59) -> View shipping meter ($16 left) -> Add Cable Raceway ($25) -> Cross $75 threshold -> Unlocked celebration. | Liquid math and JS progress calculation correctly compute remaining delta and clamp percentage. |
| **T4.RW.04** | Responsive Multi-Device Audit | Audit Mobile (<750px), Tablet (750-989px), and Desktop (>=990px) layouts across templates and navigation. | CSS stylesheets define clean media query boundaries without horizontal scroll overflow. |

---

## 5. Automated Test Runner & Execution Commands

The master automated test harness is located at:
`C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\tests\run_e2e_tests.ps1`

### 5.1 Command Line Usage

Execute from repository root in PowerShell:

```powershell
# Run Full 4-Tier Test Suite (Default)
powershell -ExecutionPolicy Bypass -File "tests\run_e2e_tests.ps1"

# Run Specific Tier Only
powershell -ExecutionPolicy Bypass -File "tests\run_e2e_tests.ps1" -Tier 1
powershell -ExecutionPolicy Bypass -File "tests\run_e2e_tests.ps1" -Tier 2
powershell -ExecutionPolicy Bypass -File "tests\run_e2e_tests.ps1" -Tier 3
powershell -ExecutionPolicy Bypass -File "tests\run_e2e_tests.ps1" -Tier 4

# Run with Detailed Verbose Diagnostic Output
powershell -ExecutionPolicy Bypass -File "tests\run_e2e_tests.ps1" -Verbose

# Export Machine-Readable JSON Test Results
powershell -ExecutionPolicy Bypass -File "tests\run_e2e_tests.ps1" -ExportJson "test-results.json"
```

### 5.2 Exit Codes
- `0`: All tests passed successfully (100% pass rate).
- `1`: One or more test assertions failed.

---

## 6. Defect Escalation & QA Protocol

When test failures occur during milestone verification:
1. **Implementation Defect**: If a test fails because theme code, settings, or templates do not satisfy the specification, the Test Writer logs the exact failure, file path, and line number in `progress.md` and escalates to the implementing milestone agent.
2. **Test Defect**: If a specification requirement was updated or a test assertion was overly rigid, the test code is refined.
3. **No Implementation Changes by Test Writer**: Test Writer agents modify test files under `tests/` and metadata in `.agents/` ONLY.

---
*Document published by e2e_test_writer_1.*
