# FocusDrawer Theme: Milestone 1 (Brand Identity & Visual System) Technical Specification Report

**Author**: `m1_explorer_1` (Brand Identity & Theme Settings Explorer)  
**Target Codebase**: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn`  
**Brand**: FocusDrawer (Premium Desk Ergonomics & Productivity Storage)  
**Date**: 2026-09-01  
**Status**: Investigation Complete — Ready for Implementation  

---

## 1. Executive Summary & Scope

This report provides the exact, copy-paste-ready specifications and configurations required to implement **Milestone 1: Brand Identity & Visual System (R1)** for the FocusDrawer Shopify Dawn theme.

FocusDrawer is a high-end workspace productivity and ergonomics brand specializing in sleek under-desk focus drawers, clean cable raceways, and modular desk organizers. The visual system embodies precision, minimalism, and deep-work focus through a curated dark palette:
- **Matte Charcoal / Deep Black (`#121212`)**: Core immersive workspace canvas
- **Elevated Dark Charcoal Surface (`#1E1E1E`)**: Elevated cards, drawers, and modal containers
- **Crisp Typography White (`#FFFFFF`)**: High-contrast, crystal-clear headings and body copy
- **Focus Gold Accent (`#E5A93C`)**: High-conversion call-to-actions, badges, focus rings, and active state highlights
- **Subtle Surface Border (`#2D2D2D` / 10–20% opacity)**: Architectural structure and separation

All recommendations have been verified against Shopify Online Store 2.0 architecture (Dawn v16.0.0), dynamic CSS Custom Property inheritance in `layout/theme.liquid`, and RFC 8259 JSON validation standards.

---

## 2. Global Color Schemes (`config/settings_data.json`)

### 2.1 FocusDrawer Palette Architecture
Dawn translates color schemes into runtime CSS variables (`--color-background`, `--color-foreground`, `--color-button`, `--color-button-text`, `--color-secondary-button-text`, `--color-badge-background`, etc.) in `layout/theme.liquid`.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ FOCUSDRAWER 5-SCHEME ARCHITECTURE MATRIX                                               │
├──────────┬──────────────────┬─────────────┬───────────┬──────────────┬─────────────────┤
│ Scheme   │ Semantic Name    │ Background  │ Text      │ Primary CTA  │ Button Label    │
├──────────┼──────────────────┼─────────────┼───────────┼──────────────┼─────────────────┤
│ scheme-1 │ Dark Matte Core  │ #121212     │ #FFFFFF   │ #E5A93C      │ #121212         │
│ scheme-2 │ Elevated Surface │ #1E1E1E     │ #FFFFFF   │ #E5A93C      │ #121212         │
│ scheme-3 │ Gold Accent Bar  │ #E5A93C     │ #121212   │ #121212      │ #FFFFFF         │
│ scheme-4 │ Deep Foundation  │ #121212     │ #FFFFFF   │ #E5A93C      │ #121212         │
│ scheme-5 │ Clean Light Doc  │ #FFFFFF     │ #121212   │ #121212      │ #FFFFFF         │
└──────────┴──────────────────┴─────────────┴───────────┴──────────────┴─────────────────┘
```

### 2.2 Exact Color Scheme Definitions in `config/settings_data.json`

Target file: `config/settings_data.json`  
Target block: `current.presets.Dawn.color_schemes` (lines 7–63)

```json
"color_schemes": {
  "scheme-1": {
    "settings": {
      "background": "#121212",
      "background_gradient": "",
      "text": "#FFFFFF",
      "button": "#E5A93C",
      "button_label": "#121212",
      "secondary_button_label": "#E5A93C",
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
}
```

---

## 3. Typography Scale, Body Scale & Spacing System

### 3.1 Typography Configuration
- **Header Font (`type_header_font`)**: `"assistant_n7"` (Bold, modern geometric sans-serif for sharp technical headers).
- **Heading Scale (`heading_scale`)**: `115` (115% — elevates hero & section titles to command visual attention).
- **Body Font (`type_body_font`)**: `"assistant_n4"` (Clean, highly legible body sans-serif).
- **Body Scale (`body_scale`)**: `105` (105% — optimized for reading specs, dimensions, and conversion copy).

### 3.2 Layout & Spacing Settings
- **Page Width (`page_width`)**: `1200` (1200px desktop max-width).
- **Section Spacing (`spacing_sections`)**: `28` (Generates `--spacing-sections-desktop: 28px` and `--spacing-sections-mobile: 20px`).
- **Grid Spacing Horizontal (`spacing_grid_horizontal`)**: `16` (Desktop 16px, Mobile 8px).
- **Grid Spacing Vertical (`spacing_grid_vertical`)**: `16` (Desktop 16px, Mobile 8px).
- **Reveal on Scroll (`animations_reveal_on_scroll`)**: `true`.
- **Hover Animations (`animations_hover_elements`)**: `"vertical-lift"`.

---

## 4. Brand Logo & Favicon Integration

### 4.1 Asset Location
The FocusDrawer logo asset is located at `assets/focusdrawer-logo.png`.

### 4.2 Settings Configuration (`config/settings_data.json`)
In `config/settings_data.json`:
- `"logo"`: `"shopify:\/\/shop_images\/focusdrawer-logo.png"` (or `"focusdrawer-logo.png"`)
- `"logo_width"`: `160` (160px desktop width, scaled cleanly on mobile)
- `"favicon"`: `"shopify:\/\/shop_images\/focusdrawer-logo.png"` (or `"focusdrawer-logo.png"`)

### 4.3 Robust Liquid Fallback Hardening
To ensure the logo and favicon render 100% reliably in local development, test environments, and live storefronts (even if CDN image picker objects are unpopulated in settings):

#### 1. Header Logo Fallback (`sections/header.liquid`)
In `sections/header.liquid`, when `settings.logo != blank`, it renders the dynamic image tag; when blank, instead of plain text fallback, render `assets/focusdrawer-logo.png`:
```liquid
{%- if settings.logo != blank -%}
  <div class="header__heading-logo-wrapper">
    {%- assign logo_alt = settings.logo.alt | default: shop.name | escape -%}
    {%- assign logo_height = settings.logo_width | divided_by: settings.logo.aspect_ratio -%}
    {% capture sizes %}(max-width: {{ settings.logo_width | times: 2 }}px) 50vw, {{ settings.logo_width }}px{% endcapture %}
    {% capture widths %}{{ settings.logo_width }}, {{ settings.logo_width | times: 1.5 | round }}, {{ settings.logo_width | times: 2 }}{% endcapture %}
    {{
      settings.logo
      | image_url: width: 600
      | image_tag:
        class: 'header__heading-logo motion-reduce',
        widths: widths,
        height: logo_height,
        width: settings.logo_width,
        alt: logo_alt,
        sizes: sizes,
        preload: true
    }}
  </div>
{%- else -%}
  <div class="header__heading-logo-wrapper">
    <img
      src="{{ 'focusdrawer-logo.png' | asset_url }}"
      alt="{{ shop.name | escape }}"
      class="header__heading-logo motion-reduce"
      width="{{ settings.logo_width | default: 160 }}"
      height="auto"
      loading="eager"
    >
  </div>
{%- endif -%}
```

#### 2. Favicon Fallback (`layout/theme.liquid`)
In `layout/theme.liquid` lines 10–13:
```liquid
{%- if settings.favicon != blank -%}
  <link rel="icon" type="image/png" href="{{ settings.favicon | image_url: width: 32, height: 32 }}">
{%- else -%}
  <link rel="icon" type="image/png" href="{{ 'focusdrawer-logo.png' | asset_url }}">
{%- endif -%}
```

---

## 5. Buttons, Focus Rings, Cards, Inputs & Badges

### 5.1 Design Tokens in `config/settings_data.json`

| Setting Key | Target Value | Purpose |
|---|---|---|
| `buttons_border_thickness` | `1` | 1px precision border |
| `buttons_border_opacity` | `100` | Full opacity crisp border |
| `buttons_radius` | `8` | 8px modern chamfered button radius |
| `buttons_shadow_opacity` | `0` | Clean flat finish with hover glow |
| `variant_pills_border_thickness` | `1` | 1px border for variant option pills |
| `variant_pills_border_opacity` | `55` | Subtle inactive border |
| `variant_pills_radius` | `8` | Consistent with button radius |
| `inputs_border_thickness` | `1` | 1px input fields |
| `inputs_border_opacity` | `55` | Subtle input border |
| `inputs_radius` | `8` | 8px rounded corners for forms |
| `card_style` | `"standard"` | Clean borderless card content |
| `card_color_scheme` | `"scheme-2"` | Elevated dark charcoal `#1E1E1E` background |
| `card_corner_radius` | `12` | 12px rounded cards |
| `collection_card_color_scheme` | `"scheme-2"` | Elevated charcoal collection cards |
| `collection_card_corner_radius` | `12` | 12px collection card corners |
| `blog_card_color_scheme` | `"scheme-2"` | Elevated charcoal blog cards |
| `blog_card_corner_radius` | `12` | 12px blog card corners |
| `badge_corner_radius` | `6` | 6px rounded badges |
| `badge_position` | `"bottom left"` | Consistent bottom-left badge placement |
| `sale_badge_color_scheme` | `"scheme-3"` | Focus Gold (`#E5A93C`) background with dark `#121212` text |
| `sold_out_badge_color_scheme` | `"scheme-2"` | Charcoal (`#1E1E1E`) background with white `#FFFFFF` text |
| `cart_type` | `"drawer"` | Frictionless AJAX slide-out cart drawer |
| `cart_color_scheme` | `"scheme-2"` | Elevated charcoal `#1E1E1E` drawer surface |
| `brand_headline` | `"FocusDrawer — Reclaim Your Workspace"` | Brand statement in footer/drawers |
| `brand_description` | `"<p>Precision under-desk focus drawers, clean cable management, and modular workspace organizers designed to eliminate clutter and elevate daily focus.</p>"` | Brand copy |

### 5.2 CSS Customizations in `assets/base.css`

#### 1. Focus Ring Tokens (Lines 11–13 of `assets/base.css`)
Replace default subtle foreground outline with FocusDrawer Gold:
```css
:root {
  --alpha-button-background: 1;
  --alpha-button-border: 1;
  --alpha-link: 0.85;
  --alpha-badge-border: 0.1;
  --focused-base-outline: 0.2rem solid #E5A93C;
  --focused-base-outline-offset: 0.3rem;
  --focused-base-box-shadow: 0 0 0 0.3rem rgb(var(--color-background)), 0 0 0.5rem 0.4rem rgba(229, 169, 60, 0.4);
}
```

#### 2. Primary Button Hover Glow & Focus (Lines 1279–1305 of `assets/base.css`)
Ensure button hover provides a subtle gold glow and crisp focus state:
```css
.button:not([disabled]):hover {
  box-shadow: 0 4px 16px rgba(229, 169, 60, 0.25);
  transform: translateY(-1px);
  transition: transform var(--duration-short) ease, box-shadow var(--duration-short) ease;
}

.button:focus-visible,
.button:focus,
.button.focused,
.shopify-payment-button__button--unbranded:focus-visible,
.shopify-payment-button__button--unbranded:focus {
  outline: 0;
  box-shadow: 0 0 0 0.3rem rgb(var(--color-background)), 0 0 0 0.5rem #E5A93C,
    0 0 0.5rem 0.4rem rgba(229, 169, 60, 0.4);
}
```

### 5.3 Variant Pill Active State (`assets/component-product-variant-picker.css`)
In `assets/component-product-variant-picker.css` (lines 95–98):
```css
.product-form__input--pill input[type='radio']:checked + label {
  background-color: #E5A93C;
  color: #121212;
  border-color: #E5A93C;
  font-weight: 600;
}
```

---

## 6. Complete Target `config/settings_data.json`

Below is the complete, validated JSON content for `config/settings_data.json`:

```json
{
  "current": "Dawn",
  "presets": {
    "Dawn": {
      "logo": "shopify:\/\/shop_images\/focusdrawer-logo.png",
      "logo_width": 160,
      "favicon": "shopify:\/\/shop_images\/focusdrawer-logo.png",
      "customer_account_menu": "customer-account-main-menu",
      "color_schemes": {
        "scheme-1": {
          "settings": {
            "background": "#121212",
            "background_gradient": "",
            "text": "#FFFFFF",
            "button": "#E5A93C",
            "button_label": "#121212",
            "secondary_button_label": "#E5A93C",
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
      "variant_pills_shadow_opacity": 0,
      "variant_pills_shadow_horizontal_offset": 0,
      "variant_pills_shadow_vertical_offset": 4,
      "variant_pills_shadow_blur": 5,
      "inputs_border_thickness": 1,
      "inputs_border_opacity": 55,
      "inputs_radius": 8,
      "inputs_shadow_opacity": 0,
      "inputs_shadow_horizontal_offset": 0,
      "inputs_shadow_vertical_offset": 4,
      "inputs_shadow_blur": 5,
      "card_style": "standard",
      "card_image_padding": 0,
      "card_text_alignment": "left",
      "card_color_scheme": "scheme-2",
      "card_border_thickness": 0,
      "card_border_opacity": 10,
      "card_corner_radius": 12,
      "card_shadow_opacity": 8,
      "card_shadow_horizontal_offset": 0,
      "card_shadow_vertical_offset": 4,
      "card_shadow_blur": 14,
      "collection_card_style": "standard",
      "collection_card_image_padding": 0,
      "collection_card_text_alignment": "left",
      "collection_card_color_scheme": "scheme-2",
      "collection_card_border_thickness": 0,
      "collection_card_border_opacity": 10,
      "collection_card_corner_radius": 12,
      "collection_card_shadow_opacity": 0,
      "collection_card_shadow_horizontal_offset": 0,
      "collection_card_shadow_vertical_offset": 4,
      "collection_card_shadow_blur": 5,
      "blog_card_style": "standard",
      "blog_card_image_padding": 0,
      "blog_card_text_alignment": "left",
      "blog_card_color_scheme": "scheme-2",
      "blog_card_border_thickness": 0,
      "blog_card_border_opacity": 10,
      "blog_card_corner_radius": 12,
      "blog_card_shadow_opacity": 0,
      "blog_card_shadow_horizontal_offset": 0,
      "blog_card_shadow_vertical_offset": 4,
      "blog_card_shadow_blur": 5,
      "text_boxes_border_thickness": 0,
      "text_boxes_border_opacity": 10,
      "text_boxes_radius": 12,
      "text_boxes_shadow_opacity": 0,
      "text_boxes_shadow_horizontal_offset": 0,
      "text_boxes_shadow_vertical_offset": 4,
      "text_boxes_shadow_blur": 5,
      "media_border_thickness": 1,
      "media_border_opacity": 5,
      "media_radius": 12,
      "media_shadow_opacity": 0,
      "media_shadow_horizontal_offset": 0,
      "media_shadow_vertical_offset": 4,
      "media_shadow_blur": 5,
      "popup_border_thickness": 1,
      "popup_border_opacity": 10,
      "popup_corner_radius": 12,
      "popup_shadow_opacity": 5,
      "popup_shadow_horizontal_offset": 0,
      "popup_shadow_vertical_offset": 4,
      "popup_shadow_blur": 5,
      "drawer_border_thickness": 1,
      "drawer_border_opacity": 10,
      "drawer_shadow_opacity": 0,
      "drawer_shadow_horizontal_offset": 0,
      "drawer_shadow_vertical_offset": 4,
      "drawer_shadow_blur": 5,
      "badge_position": "bottom left",
      "badge_corner_radius": 6,
      "sale_badge_color_scheme": "scheme-3",
      "sold_out_badge_color_scheme": "scheme-2",
      "brand_headline": "FocusDrawer — Reclaim Your Workspace",
      "brand_description": "<p>Precision under-desk focus drawers, clean cable management, and modular workspace organizers designed to eliminate clutter and elevate daily focus.</p>",
      "brand_image_width": 100,
      "social_twitter_link": "",
      "social_facebook_link": "",
      "social_pinterest_link": "",
      "social_instagram_link": "",
      "social_tiktok_link": "",
      "social_tumblr_link": "",
      "social_snapchat_link": "",
      "social_youtube_link": "",
      "social_vimeo_link": "",
      "predictive_search_enabled": true,
      "predictive_search_show_vendor": false,
      "predictive_search_show_price": false,
      "currency_code_enabled": true,
      "cart_type": "drawer",
      "show_vendor": false,
      "show_cart_note": false,
      "cart_drawer_collection": "",
      "cart_color_scheme": "scheme-2",
      "sections": {
        "main-password-header": {
          "type": "main-password-header",
          "settings": {
            "color_scheme": "scheme-1"
          }
        },
        "main-password-footer": {
          "type": "main-password-footer",
          "settings": {
            "color_scheme": "scheme-1"
          }
        }
      }
    }
  }
}
```

---

## 7. Action Plan for Implementer (`m1_worker_1`)

1. **Modify `config/settings_data.json`**:
   - Replace presets with the complete FocusDrawer settings JSON shown above.
2. **Update `layout/theme.liquid`**:
   - Add favicon fallback asset check around line 10.
3. **Update `sections/header.liquid`**:
   - Add header logo fallback asset check around lines 208 and 250.
4. **Update `assets/base.css`**:
   - Update `--focused-base-outline` and `--focused-base-box-shadow` to FocusDrawer Gold (`#E5A93C`).
   - Add hover glow and active focus transitions to `.button`.
5. **Update `assets/component-product-variant-picker.css`**:
   - Add active variant pill state with gold background `#E5A93C` and dark text `#121212`.
6. **Execute Verification**:
   - Run JSON schema validator and verify clean compilation.

---
*Report completed by `m1_explorer_1`. All findings verified.*
