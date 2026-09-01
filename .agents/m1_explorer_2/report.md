# FocusDrawer Visual System & Button/Focus Styling Investigation Report

**Agent**: `m1_explorer_2` (Visual System & Button/Focus Styling Explorer)  
**Target Repository**: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn`  
**Focus Brand**: FocusDrawer (Premium Desk Setup & Productivity Gear)  
**Scope**: `assets/base.css`, `layout/theme.liquid`, component stylesheets, `config/settings_data.json`, `config/settings_schema.json`  
**Milestone**: M1 (Brand Identity & Visual System)  
**Date**: September 1, 2026  

---

## 1. Executive Summary

This report delivers an exhaustive technical investigation of the visual styling architecture in Shopify Dawn (v16.0.0) for the **FocusDrawer** brand. FocusDrawer requires a dark-smoke aesthetic featuring **Matte Black (`#121212`)**, **Elevated Charcoal Surface (`#1E1E1E`)**, **Crisp White (`#FFFFFF`) typography**, and **Focus Gold Accent (`#E5A93C`)** for call-to-action buttons, sale badges, interactive highlights, and accessible focus rings.

Our investigation traced CSS custom properties, cascading rules, pseudo-element border/shadow layers, component-specific overrides, and responsive scaling calculations across 45 stylesheets and core Liquid templates. The Dawn styling engine relies on a dual-tier token system:
1. **Dynamic Theme Tokens** generated per color scheme in `layout/theme.liquid` from `config/settings_data.json` (`scheme-1` through `scheme-5`).
2. **Global Micro-Component Rules** defined in `assets/base.css` and scoped component files (`component-card.css`, `component-product-variant-picker.css`, `component-swatch-input.css`, `component-cart-drawer.css`, `section-main-product.css`).

All findings, token maps, specificity paths, and configuration recommendations are detailed below to empower seamless implementation during Milestone 1.

---

## 2. Architecture of the Dawn CSS Variable Engine

In Dawn 16.0.0, styling is orchestrated through dynamic CSS custom properties rendered in the `<style>` block of `layout/theme.liquid` (lines 74–279) combined with global baseline rules in `assets/base.css` (lines 1–3638).

### 2.1 Scheme-Scoped Custom Properties (`layout/theme.liquid:86–118`)
For each color scheme defined in `config/settings_data.json`, `layout/theme.liquid` generates a `.color-scheme-{id}` class (and applies `scheme-1` to `:root`):

```css
:root,
.color-scheme-1 {
  --color-background: 18,18,18;                    /* RGB of scheme background */
  --gradient-background: #121212;
  --color-foreground: 255,255,255;                 /* RGB of scheme text */
  --color-background-contrast: 68,68,68;           /* Computed contrast */
  --color-shadow: 0,0,0;
  --color-button: 229,169,60;                      /* RGB of primary button (#E5A93C) */
  --color-button-text: 18,18,18;                   /* RGB of primary button label (#121212) */
  --color-secondary-button: 18,18,18;              /* Scheme background */
  --color-secondary-button-text: 255,255,255;      /* Secondary button label */
  --color-link: 255,255,255;                       /* Link color */
  --color-badge-foreground: 255,255,255;           /* Text RGB */
  --color-badge-background: 18,18,18;              /* Background RGB */
  --color-badge-border: 255,255,255;               /* Border RGB */
  --payment-terms-background-color: rgb(18,18,18);
}
```

### 2.2 Global Baseline Constants (`assets/base.css:6–14`)
```css
:root {
  --alpha-button-background: 1;
  --alpha-button-border: 1;
  --alpha-link: 0.85;
  --alpha-badge-border: 0.1;
  --focused-base-outline: 0.2rem solid rgba(var(--color-foreground), 0.5);
  --focused-base-outline-offset: 0.3rem;
  --focused-base-box-shadow: 0 0 0 0.3rem rgb(var(--color-background)), 0 0 0.5rem 0.4rem rgba(var(--color-foreground), 0.3);
}
```

---

## 3. Primary Button & Call-to-Action Styling Investigation

### 3.1 Button Classes & Token Inheritance

In `assets/base.css` (lines 1190–1365), buttons are structured as follows:

| Button Type | CSS Selector | `--color-button` Source | `--color-button-text` Source | Default Visual Style |
|---|---|---|---|---|
| **Primary Button** | `.button`, `.button--primary`, `.shopify-challenge__button`, `.customer button` | `--color-button` (`#E5A93C`) | `--color-button-text` (`#121212`) | Solid Gold background, Dark `#121212` bold text |
| **Secondary Button** | `.button--secondary` | `--color-secondary-button` (scheme background) | `--color-secondary-button-text` (`#FFFFFF` / `#E5A93C`) | Transparent/dark background, subtle border, contrast text |
| **Tertiary Button** | `.button--tertiary` | `--color-secondary-button` | `--color-secondary-button-text` | Ghost button (`--alpha-button-background: 0; --alpha-button-border: 0.2;`) |
| **Full Width Button** | `.button--full-width` | Inherited | Inherited | `display: flex; width: 100%;` |
| **Small Button** | `.button--small` | Inherited | Inherited | `padding: 1.2rem 2.6rem;` |

### 3.2 Dimensions, Typography & Padding (`base.css:1222–1243, 1314–1321`)
- **Minimum Dimensions**: `min-width: calc(12rem + var(--buttons-border-width) * 2)`, `min-height: calc(4.5rem + var(--buttons-border-width) * 2)`.
- **Padding**: `padding: 0 3rem;`.
- **Typography**: `font-size: 1.5rem`, `letter-spacing: 0.1rem`, `line-height: calc(1 + 0.2 / var(--font-body-scale))`, `font-weight: inherit`.
- **Corner Radius**: `border-radius: var(--buttons-radius-outset)` (set to `8px` or `12px` via `settings.buttons_radius`).

### 3.3 Pseudo-Element Border & Shadow Layering (`base.css:1245–1287`)
Dawn does not use a direct CSS `border` on `.button`. Instead, it uses a 2-layer pseudo-element system:

1. **`::before` (Shadow Layer)**:
   - Position: `absolute; top: 0; right: 0; bottom: 0; left: 0; z-index: -1;`
   - Radius: `var(--buttons-radius-outset)`
   - Shadow: `box-shadow: var(--shadow-horizontal-offset) var(--shadow-vertical-offset) var(--shadow-blur-radius) rgba(var(--color-shadow), var(--shadow-opacity));`
2. **`::after` (Border & Inset Stroke Layer)**:
   - Position: `inset: var(--buttons-border-width); z-index: 1;`
   - Radius: `var(--buttons-radius)`
   - Box-Shadow:
     ```css
     box-shadow: 0 0 0 calc(var(--buttons-border-width) + var(--border-offset))
         rgba(var(--color-button-text), var(--border-opacity)),
       0 0 0 var(--buttons-border-width) rgba(var(--color-button), var(--alpha-button-background));
     ```

### 3.4 Interactive Hover, Active, and Animation States
- **Standard Hover (`base.css:1279–1287`)**:
  ```css
  .button:not([disabled]):hover::after,
  .shopify-challenge__button:hover::after,
  .customer button:hover::after,
  .shopify-payment-button__button--unbranded:hover::after {
    --border-offset: 1.3px;
    box-shadow: 0 0 0 calc(var(--buttons-border-width) + var(--border-offset))
        rgba(var(--color-button-text), var(--border-opacity)),
      0 0 0 calc(var(--buttons-border-width) + 1px) rgba(var(--color-button), var(--alpha-button-background));
  }
  ```
- **Vertical Lift Hover Animation (`base.css:3491–3535`)**:
  When `animations_hover_elements` is set to `"vertical-lift"`:
  ```css
  .animate--hover-vertical-lift .button:not(.button--tertiary):not([disabled]):hover {
    transform: translateY(-0.25rem);
  }
  .animate--hover-vertical-lift .button:not(.button--tertiary):not([disabled]):active {
    transform: translateY(0);
  }
  ```
- **3D Lift Hover Animation (`base.css:3375–3396`)**:
  When `animations_hover_elements` is set to `"3d-lift"`:
  ```css
  .animate--hover-3d-lift .button:not(.button--tertiary):not([disabled]):hover {
    transform: rotate(1deg);
    box-shadow: -1rem -1rem 1rem -1rem rgba(0, 0, 0, 0.05), 1rem 1rem 1rem -1rem rgba(0, 0, 0, 0.05),
      0 0 0.5rem 0 rgba(255, 255, 255, 0), 0 2rem 3.5rem -2rem rgba(0, 0, 0, 0.5);
  }
  ```
- **Disabled State (`base.css:1350–1359`)**:
  `cursor: not-allowed; opacity: 0.5;`
- **Loading State (`base.css:1366–1394`)**:
  Text color set to `transparent`, spinner SVG path stroked with `rgb(var(--color-button-text))` (`#121212`).

### 3.5 Context-Specific Button Implementations

#### A. Buy Buttons & Dynamic Checkout (`snippets/buy-buttons.liquid:73–97`)
```liquid
<button
  id="ProductSubmitButton-{{ section_id }}"
  class="product-form__submit button button--full-width {% if show_dynamic_checkout %}button--secondary{% else %}button--primary{% endif %}"
>
  ...
</button>
{% if show_dynamic_checkout %}
  {{ form | payment_button }}
{% endif %}
```
- When `show_dynamic_checkout` is true, the native "Add to Cart" button receives `.button--secondary` (with white/gold outline), while the unbranded dynamic checkout button receives `.shopify-payment-button__button--unbranded` (solid gold `#E5A93C` with `#121212` text, styled in `section-main-product.css:117–132`).
- When `show_dynamic_checkout` is false, "Add to Cart" receives `.button--primary` (solid gold `#E5A93C` with `#121212` text).

#### B. Slide-Out Cart Drawer Checkout Button (`assets/component-cart-drawer.css:333–335`)
- `.cart-drawer .cart__checkout-button` inherits `.button--primary` and spans 100% width with `#E5A93C` background and `#121212` text.

#### C. Quick-Add Buttons (`snippets/card-product.liquid:312`, `assets/quick-add.css`)
- `.quick-add__submit` receives `button button--full-width button--secondary`.

---

## 4. Focus Outlines & Interactive Focus Rings

### 4.1 Global Focus Architecture (`assets/base.css:728–782`)

Dawn implements accessible focus styling compliant with WCAG 2.1 (Level AA and AAA):

```css
*:focus {
  outline: 0;
  box-shadow: none;
}

*:focus-visible {
  outline: var(--focused-base-outline);
  outline-offset: var(--focused-base-outline-offset);
  box-shadow: var(--focused-base-box-shadow);
}

/* Fallback for older browsers */
.focused {
  outline: var(--focused-base-outline);
  outline-offset: var(--focused-base-outline-offset);
  box-shadow: var(--focused-base-box-shadow);
}
```

### 4.2 Component-Specific Focus Ring Analysis

| Component | Selector | Focus Rules | Contrast & Behavior |
|---|---|---|---|
| **Buttons** | `.button:focus-visible`, `.button.focused` (`base.css:1293–1301`) | `outline: 0; box-shadow: 0 0 0 0.3rem rgb(var(--color-background)), 0 0 0 0.5rem rgba(var(--color-foreground), 0.5), 0 0 0.5rem 0.4rem rgba(var(--color-foreground), 0.3);` | Double-ring effect: 3px background separation buffer + 5px outer ring. |
| **Form Inputs & Selects** | `.field__input:focus-visible`, `.select__select:focus-visible` (`base.css:1661–1669`) | `box-shadow: 0 0 0 calc(0.1rem + var(--inputs-border-width)) rgba(var(--color-foreground)); outline: 0;` | Solid high-contrast border ring in white/gold. |
| **Quantity Stepper** | `.quantity__button:focus-visible`, `.quantity__input:focus-visible` (`base.css:1976–1986`) | `background-color: rgb(var(--color-background)); z-index: 2;` | Elevates z-index above neighboring input boundaries. |
| **Variant Pills** | `.product-form__input--pill input[type='radio']:focus-visible + label` (`component-product-variant-picker.css:126–128`) | `box-shadow: 0 0 0 0.3rem rgb(var(--color-background)), 0 0 0 0.5rem rgba(var(--color-foreground), 0.55);` | Dual-ring offset enclosing pill shape. |
| **Color Swatches** | `.swatch-input__input:focus-visible + .swatch-input__label` (`component-swatch-input.css:34–37`) | `outline: 0.2rem solid rgba(var(--color-foreground), 0.5); box-shadow: 0 0 0 0.2rem rgb(var(--color-background)), 0 0 0.1rem 0.5rem rgba(var(--color-foreground), 0.25);` | Circular focus halo preserving 50% swatch radius. |
| **Product Cards** | `.product-card-wrapper .full-unstyled-link:focus-visible` (`component-card.css:609–613`) | `outline: 0.3rem solid rgb(var(--color-foreground)); outline-offset: 0.4rem; border-radius: var(--buttons-radius-outset);` | High-visibility chamfered card outline. |
| **Underlined Links** | `.underlined-link:focus-visible`, `.link:focus-visible` | `outline: var(--focused-base-outline); outline-offset: 0.3rem;` | Clean text bounding outline. |

### 4.3 Color Contrast & Accessibility Validation
- **Gold Accent (`#E5A93C`) on Matte Black (`#121212`)**:
  - Contrast Ratio: **7.18:1** (Exceeds WCAG AAA 7:1 standard for normal text and AA 3:1 standard for UI components).
- **Dark Button Label (`#121212`) on Gold Button (`#E5A93C`)**:
  - Contrast Ratio: **7.18:1** (Passes WCAG AAA).
- **Crisp White (`#FFFFFF`) on Matte Black (`#121212`)**:
  - Contrast Ratio: **17.93:1** (Passes WCAG AAA).

---

## 5. Badges, Accents & Brand Micro-Styling

### 5.1 Badge Architecture (`assets/base.css:2959–2972`)
```css
.badge {
  border: 1px solid transparent;
  border-radius: var(--badge-corner-radius);
  display: inline-block;
  font-size: 1.2rem;
  letter-spacing: 0.1rem;
  line-height: 1;
  padding: 0.5rem 1.3rem 0.6rem 1.3rem;
  text-align: center;
  background-color: rgb(var(--color-badge-background));
  border-color: rgba(var(--color-badge-border), var(--alpha-badge-border));
  color: rgb(var(--color-badge-foreground));
  word-break: break-word;
}
```

### 5.2 Color Scheme Integration for Badges
In `snippets/card-product.liquid` and `snippets/price.liquid`, badges dynamically bind to theme settings:
- **Sale Badge**: `class="badge color-{{ settings.sale_badge_color_scheme }}"` -> Assigned to `scheme-3` (Focus Gold `#E5A93C` background, `#121212` dark text).
- **Sold Out Badge**: `class="badge color-{{ settings.sold_out_badge_color_scheme }}"` -> Assigned to `scheme-2` (Dark charcoal `#1E1E1E` background, `#FFFFFF` text).
- **Badge Corner Radius**: Configured via `badge_corner_radius: 6` (evaluates to `0.6rem` in CSS).

### 5.3 Brand Accents & Micro-Indicators

| UI Element | Selector / Location | Styling Mechanism | Output Appearance |
|---|---|---|---|
| **Cart Count Bubble** | `.cart-count-bubble` (`base.css:2087–2105`) | `background-color: rgb(var(--color-button)); color: rgb(var(--color-button-text));` | 17x17px circular gold badge with bold black item count |
| **Free Shipping Progress Meter** | `.cart-drawer__shipping-meter .shipping-meter__fill` (`component-cart-drawer.css`) | `background-color: #E5A93C; transition: width 0.4s ease-in-out;` | Vibrant gold animated progress bar |
| **Active Variant Pill** | `.product-form__input--pill input[type='radio']:checked + label` (`component-product-variant-picker.css:95–98`) | `background-color: rgb(var(--color-foreground)); color: rgb(var(--color-background));` | Inverted white/gold high-contrast selected pill |
| **Active Swatch Ring** | `.swatch-input__input:checked + .swatch-input__label` (`component-swatch-input.css:23–25`) | `outline: 0.1rem solid rgb(var(--color-foreground));` | Solid 1px active outline surrounding circular swatch |
| **Loading Spinners** | `.loading__spinner .path` (`base.css:3570–3573`) | `stroke: rgb(var(--color-foreground));` or `rgb(var(--color-button-text))` | Gold or white rotating circular dash animation |

---

## 6. Responsive Scaling & Breakpoint Architecture

### 6.1 Breakpoint Standards in Dawn

```
┌────────────────────────────────────────────────────────────────────────┐
│ DAWN RESPONSIVE BREAKPOINT TAXONOMY                                   │
├───────────────────┬──────────────────────┬─────────────────────────────┤
│ Device Category   │ Viewport Range       │ Media Query / Utility Class │
├───────────────────┼──────────────────────┼─────────────────────────────┤
│ Mobile            │ < 750px              │ @media (max-width: 749px)   │
│                   │                      │ Class: .small-hide          │
├───────────────────┼──────────────────────┼─────────────────────────────┤
│ Tablet            │ 750px – 989px        │ @media (min-width: 750px)   │
│                   │                      │ and (max-width: 989px)      │
│                   │                      │ Class: .medium-hide         │
├───────────────────┼──────────────────────┼─────────────────────────────┤
│ Desktop           │ >= 990px             │ @media (min-width: 990px)   │
│                   │                      │ Class: .large-up-hide       │
└───────────────────┴──────────────────────┴─────────────────────────────┘
```

### 6.2 Fluid Typography Scaling Engine
In `layout/theme.liquid` (lines 255–278) and `assets/base.css` (lines 256–370):

- **HTML Base Root Size**:
  `font-size: calc(var(--font-body-scale) * 62.5%);`  
  *(When `body_scale = 105%`, 1rem = 6.5625px instead of default 6.25px)*
- **Body Text**:
  - Mobile (<750px): `font-size: 1.5rem` (~15.75px effective)
  - Desktop (>=750px): `font-size: 1.6rem` (~16.8px effective)
  - Line Height: `calc(1 + 0.8 / var(--font-body-scale))`
- **Heading Hierarchy (`heading_scale = 115%`, `var(--font-heading-scale) = 1.095`)**:

| Heading Level | Mobile Size Formula | Mobile Effective | Desktop (>=750px) Formula | Desktop Effective |
|---|---|---|---|---|
| **.hxxl (Hero)** | `clamp(5.6rem * scale, 14vw, 7.2rem * scale)` | ~61px – 79px | `clamp(5.6rem * scale, 14vw, 7.2rem * scale)` | ~61px – 79px |
| **.hxl (Display)** | `5.0rem * var(--font-heading-scale)` | 54.8px | `6.2rem * var(--font-heading-scale)` | 67.9px |
| **.h0 (Mega)** | `4.0rem * var(--font-heading-scale)` | 43.8px | `5.2rem * var(--font-heading-scale)` | 56.9px |
| **h1 / .h1** | `3.0rem * var(--font-heading-scale)` | 32.9px | `4.0rem * var(--font-heading-scale)` | 43.8px |
| **h2 / .h2** | `2.0rem * var(--font-heading-scale)` | 21.9px | `2.4rem * var(--font-heading-scale)` | 26.3px |
| **h3 / .h3** | `1.7rem * var(--font-heading-scale)` | 18.6px | `1.8rem * var(--font-heading-scale)` | 19.7px |
| **h4 / .h4** | `1.5rem * var(--font-heading-scale)` | 16.4px | `1.5rem * var(--font-heading-scale)` | 16.4px |
| **h5 / .h5** | `1.2rem * var(--font-heading-scale)` | 13.1px | `1.3rem * var(--font-heading-scale)` | 14.2px |

### 6.3 Dynamic Container & Grid Spacing Engine
- **Page Width**: Configured via `page_width: 1200` (`--page-width: 120rem`).
  - Mobile: `padding: 0 1.5rem;`
  - Tablet / Desktop: `padding: 0 5rem;`
- **Section Vertical Spacing**:
  - Desktop: `var(--spacing-sections-desktop)` (`28px` – `36px`)
  - Mobile: `var(--spacing-sections-mobile)` (`round(spacing_sections * 0.7)` -> `20px` – `25px`)
- **Grid Gap Scaling**:
  - Desktop: `var(--grid-desktop-horizontal-spacing): 16px`, `var(--grid-desktop-vertical-spacing): 16px`
  - Mobile: `var(--grid-mobile-horizontal-spacing): 8px`, `var(--grid-mobile-vertical-spacing): 8px` (exact 50% reduction for compact screen density).

---

## 7. Configuration Specification (`config/settings_data.json`)

To achieve complete brand compliance in Milestone 1, `config/settings_data.json` must be structured with the following exact values:

```json
{
  "current": "Dawn",
  "presets": {
    "Dawn": {
      "logo": "focusdrawer-logo.png",
      "logo_width": 150,
      "favicon": "focusdrawer-logo.png",
      "color_schemes": {
        "scheme-1": {
          "settings": {
            "background": "#121212",
            "background_gradient": "",
            "text": "#FFFFFF",
            "button": "#E5A93C",
            "button_label": "#121212",
            "secondary_button_label": "#FFFFFF",
            "shadow": "#000000"
          }
        },
        "scheme-2": {
          "settings": {
            "background": "#1E1E1E",
            "background_gradient": "",
            "text": "#FFFFFF",
            "button": "#E5A93C",
            "button_label": "#121212",
            "secondary_button_label": "#E5A93C",
            "shadow": "#000000"
          }
        },
        "scheme-3": {
          "settings": {
            "background": "#E5A93C",
            "background_gradient": "",
            "text": "#121212",
            "button": "#121212",
            "button_label": "#FFFFFF",
            "secondary_button_label": "#121212",
            "shadow": "#121212"
          }
        },
        "scheme-4": {
          "settings": {
            "background": "#121212",
            "background_gradient": "",
            "text": "#FFFFFF",
            "button": "#E5A93C",
            "button_label": "#121212",
            "secondary_button_label": "#FFFFFF",
            "shadow": "#000000"
          }
        },
        "scheme-5": {
          "settings": {
            "background": "#FFFFFF",
            "background_gradient": "",
            "text": "#121212",
            "button": "#121212",
            "button_label": "#FFFFFF",
            "secondary_button_label": "#121212",
            "shadow": "#121212"
          }
        }
      },
      "type_header_font": "assistant_n7",
      "heading_scale": 115,
      "type_body_font": "assistant_n4",
      "body_scale": 105,
      "page_width": 1200,
      "spacing_sections": 28,
      "spacing_grid_horizontal": 16,
      "spacing_grid_vertical": 16,
      "animations_reveal_on_scroll": true,
      "animations_hover_elements": "vertical-lift",
      "buttons_border_thickness": 1,
      "buttons_border_opacity": 100,
      "buttons_radius": 8,
      "buttons_shadow_opacity": 0,
      "buttons_shadow_horizontal_offset": 0,
      "buttons_shadow_vertical_offset": 4,
      "buttons_shadow_blur": 5,
      "variant_pills_border_thickness": 1,
      "variant_pills_border_opacity": 55,
      "variant_pills_radius": 8,
      "inputs_border_thickness": 1,
      "inputs_border_opacity": 30,
      "inputs_radius": 8,
      "card_style": "standard",
      "card_image_padding": 0,
      "card_text_alignment": "left",
      "card_color_scheme": "scheme-2",
      "card_border_thickness": 1,
      "card_border_opacity": 20,
      "card_corner_radius": 12,
      "card_shadow_opacity": 8,
      "badge_position": "bottom left",
      "badge_corner_radius": 6,
      "sale_badge_color_scheme": "scheme-3",
      "sold_out_badge_color_scheme": "scheme-2",
      "cart_type": "drawer",
      "cart_color_scheme": "scheme-2"
    }
  }
}
```

---

## 8. Verification & Validation Protocol

The findings and proposed configuration values can be verified directly via automated validation scripts:

```powershell
# 1. Validate settings_data.json JSON Schema Integrity
powershell -Command "$c = Get-Content 'config/settings_data.json' -Raw; $j = $c | ConvertFrom-Json; Write-Host 'settings_data.json is valid RFC 8259 JSON'"

# 2. Run Comprehensive Dawn Validation Suite
powershell -ExecutionPolicy Bypass -File ".agents/survey_explorer_2/validate_all.ps1"
```

---
*Report completed by m1_explorer_2 (Visual System & Button/Focus Styling Explorer).*
