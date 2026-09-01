# Project: FocusDrawer Shopify Dawn Theme Customization

## Architecture
Shopify Online Store 2.0 (OS 2.0) theme based on Dawn (v16.0.0).
- Modular Liquid architecture: Layout (`layout/theme.liquid`), Sections (`sections/*.liquid`), Snippets (`snippets/*.liquid`), Templates (`templates/*.json`), Theme Configuration (`config/settings_data.json`, `config/settings_schema.json`), and Assets (`assets/*`).
- Dynamic CSS Custom Properties: Generated dynamically in `layout/theme.liquid` from color schemes defined in `config/settings_data.json` (`scheme-1` through `scheme-5`).
- Front-End Web Components & AJAX Pub/Sub: `cart-drawer`, `cart-drawer-items`, `product-form`, `product-info` utilizing `PUB_SUB_EVENTS` for real-time DOM updates and cart state synchronization.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | FocusDrawer Brand Logo | Header & mobile navigation logo integration referencing `assets/focusdrawer-logo.png` with retina scaling and fallback | M1 | ORIGINAL_REQUEST §R1, survey |
| 2 | Favicon Integration | 32x32px favicon setup in `<head>` | M1 | ORIGINAL_REQUEST §R1, survey |
| 3 | Dark Matte Core Color Scheme (`scheme-1`) | `#121212` matte black background, `#FFFFFF` text, `#E5A93C` vibrant gold primary buttons | M1 | ORIGINAL_REQUEST §R1, survey |
| 4 | Elevated Charcoal Surface Scheme (`scheme-2`) | `#1E1E1E` dark charcoal surface, `#FFFFFF` text, `#E5A93C` accent buttons for cards and drawers | M1 | ORIGINAL_REQUEST §R1, survey |
| 5 | Gold Accent Scheme (`scheme-3`) | `#E5A93C` gold background, `#121212` dark text for high-impact callouts and announcement bar | M1 | ORIGINAL_REQUEST §R1, survey |
| 6 | Deep Surface Footer/Header Scheme (`scheme-4`) | Deep charcoal surface (`#121212` / `#181818`), white text, gold accents for header and footer | M1 | ORIGINAL_REQUEST §R1, survey |
| 7 | Clean Light Contrast Scheme (`scheme-5`) | Clean white `#FFFFFF` surface with dark charcoal text for high-contrast documentation/invoices | M1 | ORIGINAL_REQUEST §R1, survey |
| 8 | Typography & Spacing System | Scaled typography (115% heading, 105% body), responsive breakpoints (mobile, tablet, desktop) | M1 | ORIGINAL_REQUEST §R1, survey |
| 9 | Gold Button & Focus Ring Styling | Consistent FocusDrawer gold (`#E5A93C`) styling for primary buttons, glow hover states, and focus indicators in `assets/base.css` | M1 | ORIGINAL_REQUEST §R1, survey |
| 10 | Branded Announcement Bar | Top announcement bar highlighting workspace bundle free shipping and 30-day guarantee | M2 | ORIGINAL_REQUEST §R4, survey |
| 11 | Responsive Mobile Drawer Nav | Slide-out mobile navigation drawer with structured category links and focus trap | M2 | ORIGINAL_REQUEST §R4, survey |
| 12 | Slide-Out Cart Drawer | Frictionless slide-out AJAX cart drawer with item manipulation and line item totals | M2 | ORIGINAL_REQUEST §R4, survey |
| 13 | Free Shipping Progress Meter | Dynamic interactive progress meter calculating progress toward free shipping threshold ($50/$75) with gold bar fill and real-time AJAX update | M2 | ORIGINAL_REQUEST §R4, survey |
| 14 | Modular Hero Banner | Impactful hero section with under-desk focus drawer visuals, high-converting copy, and dual CTA buttons | M3 | ORIGINAL_REQUEST §R2, survey |
| 15 | 3-Pillar Value Proposition | 3-column responsive section detailing "Declutter", "Focus", and "Ergonomics" with bespoke copy and icons | M3 | ORIGINAL_REQUEST §R2, survey |
| 16 | Featured Products Grid & Quick-Add | Responsive grid with product card hover effects, pricing, and functional Quick-Add trigger | M3 | ORIGINAL_REQUEST §R2, survey |
| 17 | Interactive Dimension / Specs Highlight | Collapsible/multirow interactive dimension comparison and desk clearance highlights | M3 | ORIGINAL_REQUEST §R2, survey |
| 18 | Customer Testimonials Section | Verified customer reviews from engineers and creators with star ratings and card layouts | M3 | ORIGINAL_REQUEST §R2, survey |
| 19 | High-Resolution Media Gallery | Thumbnail slider layout, lightbox zoom, and mobile thumbnail slider for product images | M4 | ORIGINAL_REQUEST §R3, survey |
| 20 | Dynamic Variant Selectors | Pill buttons and swatches for finishes (Matte Black, Stealth Charcoal, Walnut) and sizes (Compact, Pro, Ultra-Wide) | M4 | ORIGINAL_REQUEST §R3, survey |
| 21 | Expandable Technical Spec Accordions | 4 collapsible drawer tabs: Dimensions & Mounting (`ruler`), Materials (`check_mark`), Cable Management (`lightning_bolt`), Warranty (`star`) | M4 | ORIGINAL_REQUEST §R3, survey |
| 22 | Sticky "Add to Cart" on Scroll | Viewport-anchored sticky ATC bar on scroll synchronized with variant picker and main product form | M4 | ORIGINAL_REQUEST §R3, survey |
| 23 | Modular Collection Template | Filterable collection grid with faceted navigation and sorting in `templates/collection.json` | M4 | ORIGINAL_REQUEST §R3, survey |
| 24 | E2E Test Suite & Adversarial Hardening | Comprehensive 4-tier opaque-box test suite + Tier 5 adversarial coverage hardening verifying 100% test pass and Liquid/JSON schema integrity | M5 | ORIGINAL_REQUEST Acceptance Criteria, survey |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| E2E | E2E Testing Track | Design 4-tier test infrastructure, automated validators for Liquid syntax, JSON schemas, Brand assets, Cart & Product features. Publishes `TEST_READY.md`. | none | DONE |
| M1 | Brand Identity & Visual System | Configure color schemes 1–5 in `config/settings_data.json`, logo and favicon linking, typography, gold button/focus styling in `assets/base.css`. | none | DONE |
| M2 | Navigation, Cart Drawer & Shipping Meter | Branded announcement bar, mobile drawer nav, slide-out cart drawer with dynamic Free Shipping progress meter in `snippets/cart-drawer.liquid` & `assets/component-cart-drawer.css`. | M1 | DONE |
| M3 | Home Page Showcase | Build FocusDrawer homepage layout in `templates/index.json` with Hero banner, 3-pillar value props (Declutter, Focus, Ergonomics), featured products with quick-add, dimensions highlight, and testimonials. | M1 | DONE |
| M4 | Product & Collection Templates | Configure `templates/product.json` with thumbnail slider gallery, dynamic variant selector, 4 technical spec accordions, sticky ATC on scroll, and collection filters in `templates/collection.json`. | M1 | DONE |
| M5 | Final Milestone: 100% E2E Pass & Adversarial Hardening | Phase 1: Pass 100% of E2E tests (Tiers 1–4). Phase 2: Tier 5 adversarial white-box testing and coverage hardening. | E2E, M1, M2, M3, M4 | DONE |

## Interface Contracts
### Color Schemes (`config/settings_data.json` ↔ `layout/theme.liquid`)
- `scheme-1`: Background `#121212`, Text `#FFFFFF`, Button Background `#E5A93C`, Button Label `#121212`, Secondary Button Label `#FFFFFF`.
- `scheme-2`: Background `#1E1E1E`, Text `#FFFFFF`, Button Background `#E5A93C`, Button Label `#121212`.
- `scheme-3`: Background `#E5A93C`, Text `#121212`, Button Background `#121212`, Button Label `#FFFFFF`.
- `scheme-4`: Background `#121212`, Text `#FFFFFF`, Button Background `#E5A93C`, Button Label `#121212`.
- `scheme-5`: Background `#FFFFFF`, Text `#121212`, Button Background `#121212`, Button Label `#FFFFFF`.

### Free Shipping Meter Contract (`snippets/cart-drawer.liquid` ↔ `assets/cart-drawer.js`)
- Threshold: 5000 cents ($50.00) or 7500 cents ($75.00).
- Progress Container: `.cart-drawer__free-shipping` rendered inside `.drawer__inner`.
- Progress Bar: `.cart-drawer__free-shipping-bar-fill` with inline `style="width: {{ progress_percentage }}%"`.
- Progress Text: Displays remaining amount countdown when `cart.total_price < threshold`, displays unlocked celebration message when `cart.total_price >= threshold`.
- Live Update: Re-rendered automatically on AJAX cart updates via section rendering of `cart-drawer`.

### Sticky ATC Contract (`sections/main-product.liquid` ↔ `assets/sticky-atc.js` / `assets/product-info.js`)
- Visibility trigger: Appears when `#ProductSubmitButton-{{ section.id }}` or main buy buttons container scrolls out of the viewport.
- Synchronization: Listens to variant change events to update price, variant title, and disabled/sold-out state.
- Form Action: Triggers submit on the primary product form or sends AJAX `/cart/add` payload.

## Code Layout
- `config/`: `settings_data.json`, `settings_schema.json`
- `layout/`: `theme.liquid`, `password.liquid`
- `sections/`: `header.liquid`, `announcement-bar.liquid`, `footer.liquid`, `main-product.liquid`, `image-banner.liquid`, `multicolumn.liquid`, `featured-collection.liquid`, `collapsible-content.liquid`
- `snippets/`: `cart-drawer.liquid`, `buy-buttons.liquid`, `card-product.liquid`, `header-drawer.liquid`, `icon-*.liquid`
- `templates/`: `index.json`, `product.json`, `collection.json`, `cart.json`
- `assets/`: `focusdrawer-logo.png`, `base.css`, `component-cart-drawer.css`, `section-main-product.css`, `cart-drawer.js`, `product-info.js`, `sticky-atc.js`
- `.agents/`: Agent workspaces, reports, test scripts, and metadata ONLY.
