# Investigation Report: Navigation & Announcement Bar Customization (Milestone 2 - R4)

**Document Version**: 1.0.0  
**Author**: `m2_explorer_1` (Navigation & Announcement Explorer)  
**Target Repository**: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn`  
**Brand**: FocusDrawer (Premium Desk Organization & Productivity Gear)  
**Milestone**: M2 (Navigation, Cart Drawer & Free Shipping Meter)  
**Status**: Complete  

---

## 1. Executive Summary

This investigation report details the exact architectural structure, configuration settings, Liquid templates, and CSS styling required to implement the **Branded Top Announcement Bar** and **Responsive Mobile Navigation Drawer** (Requirement R4) for FocusDrawer.

The implementation builds directly on Milestone 1's established 5-scheme visual system:
- **Announcement Bar**: Utilizes `scheme-3` (Vibrant Gold `#E5A93C` background with high-contrast `#121212` dark text) to create an eye-catching promotional banner highlighting bundle free shipping and the 30-day setup guarantee.
- **Mobile Menu Drawer**: Utilizes `scheme-2` (Elevated Dark Charcoal `#1E1E1E` surface) with gold active link indicators (`border-left: 3px solid #E5A93C`), subtle hover glides, dark backdrop blur (`backdrop-filter: blur(8px)`), and polished typography hierarchy.

---

## 2. Touchpoints & Target Files

| # | File Path | Scope of Modification | Rationale |
|---|-----------|-----------------------|-----------|
| 1 | `sections/header-group.json` | Update announcement copy, link, and `menu_color_scheme` to `scheme-2` | Sets brand promotional text and assigns elevated surface scheme to drawer nav. |
| 2 | `sections/announcement-bar.liquid` | Verify Liquid markup, schema validation, and arrow icon integration | Ensures RFC 8259 valid schema, single/multi-message support, and accessibility. |
| 3 | `snippets/header-drawer.liquid` | Verify nested menu rendering, focus trap, and ARIA attributes | Guarantees accessible keyboard navigation, slide sub-menus, and social link bindings. |
| 4 | `assets/component-menu-drawer.css` | Add gold active state, hover transitions, backdrop blur, and charcoal borders | Delivers bespoke FocusDrawer ergonomics and brand aesthetic on mobile. |
| 5 | `assets/component-list-menu.css` | Enhance desktop active menu links with gold indicators | Harmonizes desktop header dropdowns with the mobile drawer active states. |

---

## 3. Detailed Component Analysis & Implementation Specifications

### 3.1 Branded Announcement Bar

#### File: `sections/header-group.json`
The announcement bar in `sections/header-group.json` currently contains generic placeholder text. It must be updated to the high-converting FocusDrawer launch offer.

**Proposed `sections/header-group.json` configuration**:
```json
{
  "name": "t:sections.header.name",
  "type": "header",
  "sections": {
    "announcement-bar": {
      "type": "announcement-bar",
      "settings": {
        "color_scheme": "scheme-3",
        "show_line_separator": true,
        "show_social": false,
        "auto_rotate": false,
        "change_slides_speed": 5,
        "enable_country_selector": false,
        "enable_language_selector": false
      },
      "blocks": {
        "announcement-bar-0": {
          "type": "announcement",
          "settings": {
            "text": "FREE SHIPPING ON WORKSPACE BUNDLES OVER $50 ✦ 30-DAY SETUP GUARANTEE",
            "text_alignment": "center",
            "color_scheme": "scheme-3",
            "link": "shopify://collections/all"
          }
        }
      },
      "block_order": [
        "announcement-bar-0"
      ]
    },
    "header": {
      "type": "header",
      "settings": {
        "color_scheme": "scheme-1",
        "menu_color_scheme": "scheme-2",
        "logo_position": "middle-left",
        "menu": "main-menu",
        "menu_type_desktop": "dropdown",
        "sticky_header_type": "on-scroll-up",
        "show_line_separator": true,
        "enable_country_selector": false,
        "enable_language_selector": false,
        "mobile_logo_position": "center",
        "margin_bottom": 0,
        "padding_top": 16,
        "padding_bottom": 16
      }
    }
  },
  "order": [
    "announcement-bar",
    "header"
  ]
}
```

#### Key Functional & Visual Features:
1. **Color Scheme Integration**: Bound to `scheme-3` (`#E5A93C` gold background, `#121212` text). All text, link underlines, and arrow SVGs automatically inherit the high-contrast dark foreground.
2. **Promotional Copy**: `"FREE SHIPPING ON WORKSPACE BUNDLES OVER $50 ✦ 30-DAY SETUP GUARANTEE"` clearly communicates both the free shipping threshold and risk-free trial.
3. **Interactive Link & Arrow**: Renders `<a href="shopify://collections/all">` with `.animate-arrow` icon transition on hover.

---

### 3.2 Mobile Navigation Drawer (`header-drawer.liquid` & `component-menu-drawer.css`)

#### Current State vs Required FocusDrawer Styling:
- **Background & Palette**: Switched to `scheme-2` (`#1E1E1E` elevated charcoal background with `#FFFFFF` text), creating strong visual layering against the `#121212` body background.
- **Active Navigation Link**: When a user is on the active collection/page, the link receives a vibrant gold accent bar (`border-left: 3px solid #E5A93C`), gold font color (`color: #E5A93C`), and subtle translucent gold background tint (`rgba(229, 169, 60, 0.08)`).
- **Interactive Hover Glide**: Hovering any menu item shifts the item slightly (`padding-left: 3.4rem`) with gold transition, providing tactile feedback.
- **Backdrop Blur Overlay**: When the drawer opens, the background scrim uses `rgba(0, 0, 0, 0.7)` with `backdrop-filter: blur(8px)` to eliminate visual distraction from background page content.

#### Proposed CSS Rules for `assets/component-menu-drawer.css`:

```css
/* ==========================================================================
   FocusDrawer Mobile Navigation Drawer Enhancements
   ========================================================================== */

/* Enhanced Scrim Overlay with Backdrop Blur */
.js menu-drawer > details > summary::before,
.js menu-drawer > details[open]:not(.menu-opening) > summary::before {
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

/* Elevated Charcoal Surface & Gold Accent Border */
@media screen and (min-width: 750px) {
  .menu-drawer {
    width: 40rem;
    border-right: 1px solid rgba(229, 169, 60, 0.15);
    box-shadow: 10px 0 30px rgba(0, 0, 0, 0.6);
  }
}

/* Menu Item Typography & Smooth Transitions */
.menu-drawer__menu-item {
  padding: 1.2rem 3rem;
  text-decoration: none;
  font-size: 1.7rem;
  letter-spacing: 0.04rem;
  font-weight: 500;
  transition: color var(--duration-short) ease, background-color var(--duration-short) ease, padding-left var(--duration-short) ease;
}

/* Active Menu Item State with FocusDrawer Gold Accent Bar */
.menu-drawer__menu-item--active {
  color: #E5A93C !important;
  background-color: rgba(229, 169, 60, 0.08);
  border-left: 3px solid #E5A93C;
  padding-left: calc(3rem - 3px);
  font-weight: 600;
}

.menu-drawer__menu-item--active:hover {
  background-color: rgba(229, 169, 60, 0.12);
  color: #F2BA55 !important;
}

/* Interactive Hover & Focus States */
.menu-drawer__menu-item:hover,
.menu-drawer__menu-item:focus,
.menu-drawer__close-button:hover,
.menu-drawer__close-button:focus {
  color: #E5A93C;
  background-color: rgba(229, 169, 60, 0.05);
  padding-left: 3.4rem;
}

/* Submenu Back Button & Header */
.menu-drawer__close-button {
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  padding: 1.4rem 3rem;
  font-weight: 600;
  letter-spacing: 0.05rem;
  transition: color var(--duration-short) ease, background-color var(--duration-short) ease;
}

/* Drawer Utility Links & Social Row */
.menu-drawer__utility-links {
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  background-color: rgba(0, 0, 0, 0.25);
  padding: 2rem 3rem;
}

.menu-drawer .list-social__link {
  transition: color var(--duration-short) ease, transform var(--duration-short) ease;
}

.menu-drawer .list-social__link:hover {
  color: #E5A93C;
  transform: translateY(-2px);
}
```

---

### 3.3 Desktop Dropdown Navigation (`component-list-menu.css`)

To ensure desktop dropdown menus harmonize with the gold active indicator in the drawer navigation:

#### Proposed CSS Rules for `assets/component-list-menu.css`:
```css
/* Desktop Active Menu Link Gold Indicator */
.header__active-menu-item {
  color: #E5A93C;
  font-weight: 600;
  text-decoration: underline;
  text-decoration-color: #E5A93C;
  text-underline-offset: 0.5rem;
  text-decoration-thickness: 0.2rem;
}

.list-menu__item--active {
  color: #E5A93C !important;
  text-decoration: underline;
  text-decoration-color: #E5A93C;
  text-underline-offset: 0.4rem;
}
```

---

## 4. Verification & Validation Plan

### 4.1 Automated Validation Commands

```powershell
# 1. Validate JSON syntax of header-group.json
powershell -Command "$content = Get-Content 'sections/header-group.json' -Raw; $json = $content | ConvertFrom-Json; Write-Host 'header-group.json is strictly valid RFC 8259 JSON'"

# 2. Validate section schema in announcement-bar.liquid
powershell -Command "$content = Get-Content 'sections/announcement-bar.liquid' -Raw; if ($content -match '(?s)\{%-?\s*schema\s*-?%\}(.*?)\{%-?\s*endschema\s*-?%\}') { $matches[1] | ConvertFrom-Json | Out-Null; Write-Host 'announcement-bar schema is valid JSON' }"

# 3. Run the automated 4-tier E2E test harness
powershell -ExecutionPolicy Bypass -File tests/run_e2e_tests.ps1
```

### 4.2 Acceptance Criteria Matrix

| Criterion | Target | Verification Check |
|-----------|--------|-------------------|
| Announcement Text | `"FREE SHIPPING ON WORKSPACE BUNDLES OVER $50 ✦ 30-DAY SETUP GUARANTEE"` | Present in `sections/header-group.json` block settings. |
| Announcement Scheme | `scheme-3` | Applied to `utility-bar` in `sections/header-group.json`. |
| Drawer Menu Scheme | `scheme-2` | Applied to `menu_color_scheme` in `sections/header-group.json`. |
| Mobile Active State | Gold bar (`#E5A93C`) & font highlight | Evaluated via CSS rule `.menu-drawer__menu-item--active`. |
| Mobile Backdrop Scrim | Blur + 70% dark scrim | Evaluated via CSS rule `backdrop-filter: blur(8px)`. |
| Tag & Stack Balance | 100% Balanced Liquid tags | Verified via Core Validator Engine 3 in `tests/run_e2e_tests.ps1`. |

---

## 5. Conclusion & Worker Implementation Instructions

The implementation plan is ready for `m2_worker_1` (or relevant milestone implementer):
1. **Update `sections/header-group.json`**: Apply the exact JSON snippet in Section 3.1.
2. **Update `assets/component-menu-drawer.css`**: Append/integrate the gold active states, hover transitions, and backdrop blur rules in Section 3.2.
3. **Update `assets/component-list-menu.css`**: Add gold active state styling in Section 3.3.
4. **Execute `tests/run_e2e_tests.ps1`**: Confirm all tests pass without errors.
