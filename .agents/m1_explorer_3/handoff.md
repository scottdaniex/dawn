# FocusDrawer Dawn Customization: Header & Brand Asset Integration Handoff

**Author**: `m1_explorer_3` (Header & Brand Asset Integration Explorer)  
**Milestone**: M1 (Brand Identity & Visual System)  
**Recipient**: Milestone Planner & Implementation Agents (`orchestrator_1`, `m1_planner`, `m1_coder`)  
**Date**: 2026-09-01  
**Status**: Complete (Hard Handoff)  

---

## 1. Observation

Direct observations and evidence gathered during the codebase inspection:

### 1.1 Brand Asset Properties (`assets/focusdrawer-logo.png`)
- Command:
  ```powershell
  Add-Type -AssemblyName System.Drawing
  $img = [System.Drawing.Image]::FromFile((Resolve-Path 'assets\focusdrawer-logo.png'))
  [PSCustomObject]@{ Width = $img.Width; Height = $img.Height; PixelFormat = $img.PixelFormat.ToString(); SizeBytes = (Get-Item 'assets\focusdrawer-logo.png').Length }
  ```
- Output:
  ```
  Width Height PixelFormat     SizeBytes
  ----- ------ -----------     ---------
   1024   1024 Format32bppArgb    603432
  ```
- The logo is a square (1:1) 1024×1024 32-bit ARGB PNG with alpha transparency.

### 1.2 Logo Rendering in `sections/header.liquid`
- **Location 1 (Lines 188–209)**:
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
    <span class="h2">{{ shop.name }}</span>
  {%- endif -%}
  ```
- **Location 2 (Lines 231–252)**: Exact duplicate for `middle-center` logo alignment.
- **Location 3 (Lines 466–468)**: JSON-LD Organization structured data:
  ```liquid
  {% if settings.logo %}
    "logo": {{ settings.logo | image_url: width: 500 | prepend: "https:" | json }},
  {% endif %}
  ```

### 1.3 Favicon Rendering in `layout/theme.liquid`
- **Lines 10–12**:
  ```liquid
  {%- if settings.favicon != blank -%}
    <link rel="icon" type="image/png" href="{{ settings.favicon | image_url: width: 32, height: 32 }}">
  {%- endif -%}
  ```
- In `layout/password.liquid` (lines 10–12) and `templates/gift_card.liquid` (lines 13–15), identical conditional blocks exist.

### 1.4 Header Color Scheme & Navigation Subsystems
- In `sections/header-group.json` (lines 31–48):
  `color_scheme` is set to `"scheme-1"`, and `menu_color_scheme` is set to `"scheme-1"`.
- In `snippets/header-drawer.liquid` (line 23):
  `<div id="menu-drawer" class="gradient menu-drawer motion-reduce color-{{ section.settings.menu_color_scheme }}">`
- In `snippets/header-dropdown-menu.liquid` (line 30):
  `class="header__submenu list-menu list-menu--disclosure color-{{ section.settings.menu_color_scheme }} ..."`
- In `snippets/header-mega-menu.liquid` (line 30):
  `class="mega-menu__content color-{{ section.settings.menu_color_scheme }} ..."`

---

## 2. Logic Chain

1. **Brand Image Resolution**:
   - `assets/focusdrawer-logo.png` is 1024×1024 px (aspect ratio 1.0).
   - Displaying at 140px to 180px in desktop header and 100px to 120px in mobile header provides >5x pixel density over standard 1x displays, delivering optimal retina sharpness on mobile (OLED/Retina) and 4K desktop screens.
2. **Fallback Requirement**:
   - In offline or development preview environments where `settings.logo` has not been uploaded to a remote Shopify media CDN, `settings.logo != blank` evaluates to `false`.
   - Adding an `{%- elsif 'focusdrawer-logo.png' != blank -%}` clause pointing to `{{ 'focusdrawer-logo.png' | asset_url }}` ensures the logo is always rendered without requiring prior manual merchant upload in Shopify Admin.
3. **Favicon Delivery**:
   - The same fallback logic applied in `layout/theme.liquid`, `layout/password.liquid`, and `templates/gift_card.liquid` ensures browsers immediately load the FocusDrawer favicon from `assets/focusdrawer-logo.png`.
4. **Color Scheme Harmonization**:
   - Binding `sections/header-group.json` to `color_scheme: "scheme-1"` and `menu_color_scheme: "scheme-1"` (or `"scheme-2"`) ensures that as soon as `scheme-1` is configured with `#121212` matte black background, `#FFFFFF` text, and `#E5A93C` gold accent in `config/settings_data.json`, the entire header, mobile drawer menu, dropdowns, and mega menus inherit the dark brand visual system without extra CSS overrides.

---

## 3. Caveats

1. **Shopify Image Tag Filter on Strings**:
   - The Shopify Liquid `image_tag` filter expects an Image object when calculating dynamic `srcset`. For static asset fallbacks, an explicit `<img>` tag with `src="{{ 'focusdrawer-logo.png' | asset_url }}"`, `width="{{ settings.logo_width | default: 150 }}"`, `height="{{ settings.logo_width | default: 150 }}"`, `loading="eager"`, and `fetchpriority="high"` is the most robust and standard approach.
2. **Schema Restrictions**:
   - Theme schema `{% schema %}` blocks must remain valid JSON without template interpolations. All fallback logic must reside in the Liquid template markup outside the schema block.

---

## 4. Conclusion

1. **Header Logo Integration**:
   - Update `sections/header.liquid` to include the fallback to `assets/focusdrawer-logo.png` for both `middle-center` and standard logo positions, as well as the JSON-LD Organization metadata block.
2. **Favicon Integration**:
   - Update `layout/theme.liquid`, `layout/password.liquid`, and `templates/gift_card.liquid` with the `assets/focusdrawer-logo.png` fallback.
3. **Theme Settings & Header Group**:
   - Set `"logo": "focusdrawer-logo.png"`, `"logo_width": 150`, and `"favicon": "focusdrawer-logo.png"` in `config/settings_data.json`.
   - Verify `sections/header-group.json` has `color_scheme: "scheme-1"`, `menu_color_scheme: "scheme-1"`, and announcement bar `color_scheme: "scheme-3"`.

---

## 5. Verification Method

To verify the header, logo, and favicon integration on the host system:

1. **Execute Complete Theme Test Suite**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn\.agents\survey_explorer_2\validate_all.ps1"
   ```
2. **Verify JSON & Schema Parsing**:
   ```powershell
   $jsonFiles = Get-ChildItem -Path . -Recurse -Filter "*.json" | Where-Object { $_.FullName -notmatch '\\.git' -and $_.FullName -notmatch '\\.agents' }
   foreach ($f in $jsonFiles) { [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8) | ConvertFrom-Json | Out-Null }
   Write-Host "All JSON files valid."
   ```
3. **Verify Liquid Delimiter and Tag Balance**:
   Inspect `sections/header.liquid` and `layout/theme.liquid` using Suite 3 of `validate_all.ps1`.
4. **Verify Logo Asset Presence & Dimensions**:
   ```powershell
   Add-Type -AssemblyName System.Drawing
   $img = [System.Drawing.Image]::FromFile((Resolve-Path 'assets\focusdrawer-logo.png'))
   if ($img.Width -eq 1024 -and $img.Height -eq 1024) { Write-Host "Logo asset dimensions verified." }
   $img.Dispose()
   ```
