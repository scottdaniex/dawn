# FocusDrawer Shopify Theme Customization: Comprehensive Specification Report

**Document Version**: 1.0.0  
**Author**: `survey_spec_miner_1` (Requirements & Schema Spec Miner)  
**Target Repository**: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn`  
**Brand**: FocusDrawer (Premium Productivity & Workspace Desk Gear)  
**Integrity Mode**: Development  

---

## Executive Summary

This specification report details the complete functional, visual, structural, schema, and syntax requirements to brand and customize the Shopify Dawn theme (version 16.0.0) for **FocusDrawer**. FocusDrawer specializes in premium under-desk focus drawers, sleek cable management systems, and workspace organizers.

The visual system is anchored around a sophisticated palette: **Matte Black / Dark Charcoal (`#121212` / `#1E1E1E`)**, **Crisp White (`#FFFFFF`)**, and **Vibrant Gold Accent (`#E5A93C`)** for call-to-actions, badges, focus outlines, and interactive highlights.

---

## Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Brand & Visual System | Brand Logo Integration | Primary brand logo in header across desktop and mobile, with retina scaling and custom width. | `assets/focusdrawer-logo.png`, `settings.logo`, `settings.logo_width` (default 160px) | `<img>` tag with responsive `srcset` and `sizes`, or styled brand SVG/image fallback | Falls back to `shop.name` text if logo image is missing or empty | `sections/header.liquid`, `config/settings_schema.json` |
| 2 | Brand & Visual System | Favicon Configuration | 32x32px favicon icon rendered in `<head>` for browser tab identification. | `settings.favicon` (points to `focusdrawer-logo.png` or dedicated favicon asset) | `<link rel="icon" type="image/png" href="...">` | Omitted cleanly if `settings.favicon` is blank | `layout/theme.liquid`, `config/settings_schema.json` |
| 3 | Brand & Visual System | Color Scheme 1 (Dark Matte Core) | Primary page scheme: matte black background (`#121212`), crisp white typography (`#FFFFFF`), gold CTA button (`#E5A93C`), dark button text (`#121212`). | Color values in `config/settings_data.json` under `scheme-1` | CSS variables `--color-background`, `--color-foreground`, `--color-button`, `--color-button-text` | Defaults to light fallback if scheme definition is missing | `config/settings_data.json`, `layout/theme.liquid` |
| 4 | Brand & Visual System | Color Scheme 2 (Elevated Charcoal Surface) | Section/card contrast scheme: dark charcoal background (`#1E1E1E`), white typography (`#FFFFFF`), gold accents (`#E5A93C`). | Color values in `config/settings_data.json` under `scheme-2` | CSS variables applied to `.color-scheme-2` sections, cards, and drawers | Falls back to root scheme if undefined | `config/settings_data.json`, `layout/theme.liquid` |
| 5 | Brand & Visual System | Color Scheme 3 (Gold Accent Highlight) | High-impact accent scheme: vibrant gold background (`#E5A93C`), dark text (`#121212`), dark buttons (`#121212`) with white text (`#FFFFFF`). | Color values in `config/settings_data.json` under `scheme-3` | CSS variables applied to announcement bar, promotional badges, highlight callouts | Falls back to parent container scheme | `config/settings_data.json`, `layout/theme.liquid` |
| 6 | Brand & Visual System | Color Scheme 4 (Deep Charcoal Footer/Header) | Deep charcoal surface (`#121212` / `#181818`), white text (`#FFFFFF`), gold button (`#E5A93C`), subtle border lines. | Color values in `config/settings_data.json` under `scheme-4` | CSS variables applied to header, footer, modal dialogs | Renders default colors if missing | `config/settings_data.json`, `sections/footer.liquid` |
| 7 | Brand & Visual System | Color Scheme 5 (Clean Contrast Light) | High-contrast clean white surface (`#FFFFFF`), charcoal text (`#121212`), gold accents (`#E5A93C`). | Color values in `config/settings_data.json` under `scheme-5` | CSS variables applied to documentation/invoice/spec sheets | Renders root scheme if undefined | `config/settings_data.json` |
| 8 | Brand & Visual System | Typography Hierarchy | Clean modern sans-serif typography (Assistant / custom font), calibrated heading scale (115%) and body scale (105%). | `settings.type_header_font`, `settings.type_body_font`, `heading_scale`, `body_scale` | CSS `@font-face` declarations and `--font-heading-*`, `--font-body-*` variables | System fallback fonts (`sans-serif`, `Segoe UI`, `Helvetica Neue`) | `layout/theme.liquid`, `config/settings_schema.json` |
| 9 | Brand & Visual System | Gold Button & Focus Styling | Uniform gold styling for `.button--primary`, hover states with gold glow/contrast border, and accessible gold focus rings. | CSS rules in `assets/base.css`, CSS vars `--color-button`, `--color-button-text` | Stylized interactive buttons with micro-transitions and accessible outline | Fallback to browser default outline | `assets/base.css`, `layout/theme.liquid` |
| 10 | Home Page Showcase | Impactful Hero Banner | Modular hero section showcasing under-desk focus drawers, high-res desk setup visuals, dual CTA buttons ("Shop Focus Drawer", "Explore Setup"). | `sections/image-banner.liquid`, `templates/index.json` block settings (`heading`, `text`, `buttons`) | Full-width or boxed hero banner with overlay opacity, typography, and button links | Placeholder SVG rendered if image is missing | `sections/image-banner.liquid`, `templates/index.json` |
| 11 | Home Page Showcase | 3-Pillar Value Proposition | Structured 3-column section highlighting "Declutter", "Focus", and "Ergonomics" with descriptive copy and action links. | `sections/multicolumn.liquid`, `templates/index.json` columns blocks (`title`, `text`, `link_label`, `link`) | 3-column responsive grid with circular/square icons/media and crisp value statements | Empty column classes applied if blocks lack text | `sections/multicolumn.liquid`, `templates/index.json` |
| 12 | Home Page Showcase | Featured Products Grid & Quick-Add | Responsive grid (4 desktop / 2 mobile) displaying flagship FocusDrawer models with instant "Quick Add" button. | `sections/featured-collection.liquid`, settings: `products_to_show: 6`, `quick_add: "standard"`, `columns_desktop: 4` | Product cards with hover image flip, price, sale badges, and slide-out / modal quick-add trigger | Fallback placeholders rendered if collection is empty | `sections/featured-collection.liquid`, `snippets/card-product.liquid` |
| 13 | Home Page Showcase | Interactive Feature Comparison / Dimensions | Collapsible accordion or multirow section detailing drawer depth, mounting clearance, cable routing channels, and load capacity. | `sections/collapsible-content.liquid` or `sections/multirow.liquid`, row blocks with icons (`ruler`, `box`, `lightning_bolt`) | Expandable accordion rows with smoothly animating carets and responsive media | Gracefully collapses to text-only if media is absent | `sections/collapsible-content.liquid` |
| 14 | Home Page Showcase | Customer Testimonials | Modular testimonial section featuring verified reviews from software engineers, creators, and remote professionals. | `sections/multicolumn.liquid` or `sections/rich-text.liquid`, blocks with star ratings and user quotes | Styled quote cards with author attribution and subtle charcoal card container | Suppresses empty quote cards | `sections/multicolumn.liquid`, `templates/index.json` |
| 15 | Product Page | High-Resolution Media Gallery | Thumbnail slider layout (`gallery_layout: "thumbnail_slider"`, `mobile_thumbnails: "show"`, `media_size: "large"`, lightbox zoom). | `sections/main-product.liquid`, `snippets/product-media-gallery.liquid`, product media items | Interactive carousel with thumbnails, full-screen zoom lightbox, video support | Shows placeholder graphic if product has no images | `sections/main-product.liquid`, `snippets/product-media-gallery.liquid` |
| 16 | Product Page | Dynamic Variant Selector | Pill buttons and swatch inputs for finishes (Matte Black, Stealth Charcoal, Walnut Accent, Silver Anodized) and sizes (Compact, Pro, Ultra-Wide). | `variant_picker` block in `templates/product.json`, `snippets/product-variant-picker.liquid`, `snippets/swatch-input.liquid` | Radio button pills with gold active ring, real-time price & SKU update | Disables unavailable variant combinations with strikethrough | `snippets/product-variant-picker.liquid`, `assets/product-info.js` |
| 17 | Product Page | Sticky "Add to Cart" on Scroll | Sticky desktop info column (`enable_sticky_info: true`) and/or persistent sticky ATC bottom bar on scroll for instant conversion. | `sections/main-product.liquid` settings, CSS sticky container, JS scroll observer | Sticky product form / purchase bar anchored to viewport on desktop/mobile scroll | Hides smoothly when main purchase form is in active view | `sections/main-product.liquid`, `assets/product-info.js` |
| 18 | Product Page | Accordion Technical Specs Drawers | Expandable collapsible tabs for: 1. Dimensions & Mounting Instructions (`ruler`), 2. Materials & Craftsmanship (`check_mark`), 3. Cable Management (`lightning_bolt`), 4. Warranty & Guarantee (`star`). | `collapsible_tab` blocks in `templates/product.json`, settings (`heading`, `icon`, `content`) | Accordion drawers with custom SVG icons, accessible `<details>`/`<summary>` markup | Stays closed by default; maintains accessible keyboard navigation | `sections/main-product.liquid`, `templates/product.json` |
| 19 | Product Page | Trust & Guarantee Badges | Highlighting "30-Day Setup Guarantee", "Free Express Delivery", "Lifetime Hardware Warranty" beneath ATC buttons. | `icon_with_text` or `collapsible_tab` or `text` subtitle blocks in `main-product.liquid` | Clean inline badge strip with gold accent icons and trust micro-copy | Cleanly collapses if text is empty | `sections/main-product.liquid`, `templates/product.json` |
| 20 | Navigation & Cart | Branded Announcement Bar | Top notification bar highlighting "Free shipping on workspace bundles over $50 | 30-Day Setup Guarantee" with link to catalog. | `sections/announcement-bar.liquid`, `sections/header-group.json`, `settings.color_scheme: "scheme-3"` | Sticky or static utility bar with gold contrast, arrow icon, and optional multi-message slider | Hidden if no announcement blocks exist | `sections/announcement-bar.liquid`, `sections/header-group.json` |
| 21 | Navigation & Cart | Responsive Mobile Drawer Nav | Slide-out mobile drawer menu with smooth backdrop blur, clear categorization (Drawers, Cable Management, Desk Organizers, Bundles). | `snippets/header-drawer.liquid`, `assets/component-menu-drawer.css`, mobile menu links | Accessible side drawer with accordion sub-menus, search bar, and social links | Traps focus inside drawer when open; closes on ESC or overlay click | `snippets/header-drawer.liquid`, `sections/header.liquid` |
| 22 | Navigation & Cart | Slide-Out Cart Drawer | Frictionless slide-out cart (`cart_type: "drawer"`) rendered globally without full-page reloads. | `settings.cart_type: "drawer"`, `snippets/cart-drawer.liquid`, `assets/cart-drawer.js` | Modal slide-out drawer on right edge with live cart items, qty spinners, line item removal | Automatically falls back to `/cart` page if JavaScript is disabled | `snippets/cart-drawer.liquid`, `layout/theme.liquid` |
| 23 | Navigation & Cart | Free Shipping Progress Meter | Dynamic interactive progress bar displaying amount needed to unlock free shipping ($50 / workspace bundle threshold). | `snippets/cart-drawer.liquid`, `cart.total_price`, threshold calculation in Liquid / JS | Visual progress meter with gold bar fill (`#E5A93C`), remaining balance countdown, unlocked celebration state | Displays "You've unlocked FREE shipping!" when cart exceeds $50.00 | `snippets/cart-drawer.liquid`, `assets/cart.js` |
| 24 | Collection Template | Modular Collection Grid & Filters | Faceted filtering (drawer size, mounting type, finish) with sorting, sticky filter drawer, and quick-add support. | `templates/collection.json`, `sections/main-collection-product-grid.liquid`, `snippets/facets.liquid` | Responsive product grid with active facet chips, price range slider, and sort dropdown | Displays "No products found" state with clear-all filters CTA | `templates/collection.json`, `sections/main-collection-product-grid.liquid` |

---

## Edge Cases

| # | Feature | Input / Scenario | Observed / Required Behavior |
|---|---------|------------------|------------------------------|
| 1 | Logo Rendering | `settings.logo` is blank or local development environment lacks Shopify CDN image upload | Theme must provide fallback to render `assets/focusdrawer-logo.png` or styled SVG brand text so the header displays the FocusDrawer brand crisply rather than generic plain text. |
| 2 | Color Schemes | User switches between high-contrast dark scheme (`#121212`) and lighter surface schemes (`#1E1E1E`, `#FFFFFF`) | CSS variable contrast math (`background_color_brightness`) automatically calculates appropriate contrast borders and text opacity to prevent low-contrast illegible text. |
| 3 | Free Shipping Meter | Cart is empty (`cart.item_count == 0` or `cart.total_price == 0`) | Free shipping bar displays full threshold message ("Add $50.00 more for Free Shipping") with 0% bar fill, without crashing on division by zero. |
| 4 | Free Shipping Meter | Cart total exceeds free shipping threshold (`cart.total_price >= 5000`) | Progress bar caps at 100% width, displays success message ("🎉 You've unlocked FREE Shipping on your workspace setup!"), and changes progress track color to solid gold. |
| 5 | Free Shipping Meter | Currency change or multi-currency localization active | Progress meter calculates remaining threshold using localized currency formatting (`remaining | money`) and respects active exchange rates. |
| 6 | Sticky Add to Cart | User scrolls rapidly past the main product form on mobile or small screens | Sticky ATC bar smoothly slides up from the bottom with active variant thumbnail, title, price, and CTA; closes smoothly when scrolling back to the top form. |
| 7 | Variant Availability | Selected variant is Sold Out or Unavailable | Sticky ATC and main buy button simultaneously disable with text "Sold Out", variant pills show strike-through line, dynamic checkout buttons hide automatically. |
| 8 | Collapsible Specs Drawers | Very long technical specification table or missing page handle in accordion block | Accordion content wraps inside responsive `.rte` container with scrollable table container to prevent horizontal viewport overflow on mobile. |
| 9 | Mobile Drawer Navigation | Deep nested multi-level navigation menu (Grandchild links) | Header drawer handles nested `<details>` or sliding sub-menus without clipping or losing scroll position; close button and back button remain permanently visible. |
| 10 | Quick Add to Cart | Product has multiple required variant options (e.g. Size + Color finish) | Clicking "Quick Add" on homepage or collection card opens variant selection modal rather than blindly adding default variant to cart. |
| 11 | Cart Drawer Live Update | User updates item quantity to 0 or clicks "Remove" | Item row smoothly fades out, subtotal updates instantly via AJAX pub/sub event (`PUB_SUB_EVENTS.cartUpdate`), free shipping meter updates dynamically without full reload. |
| 12 | Schema JSON Validation | Section or preset JSON containing trailing commas or single quotes | Strict schema parser check fails if invalid JSON is introduced; all `{% schema %}` and `templates/*.json` files must strictly adhere to RFC 8259 valid JSON. |

---

## Detailed Requirement Specifications

### R1. Brand Identity & Visual System

#### 1.1 Color System Architecture
The FocusDrawer theme visual system utilizes a 5-scheme palette designed for sleek desk ergonomics and premium aesthetics:

```
┌────────────────────────────────────────────────────────────────────────┐
│ FOCUSDRAWER BRAND PALETTE                                              │
├───────────────────┬──────────────┬─────────────────────────────────────┤
│ Color Name        │ Hex Code     │ Semantic Purpose                    │
├───────────────────┼──────────────┼─────────────────────────────────────┤
│ Core Matte Black  │ #121212      │ Primary background (Scheme 1, 4)    │
│ Elevated Charcoal │ #1E1E1E      │ Secondary cards/drawers (Scheme 2)  │
│ Surface Border    │ #2D2D2D      │ Subtle structural separators        │
│ Crisp White       │ #FFFFFF      │ Primary headings & body text        │
│ Muted Smoke       │ #A0A0A0      │ Subtitles, captions, metadata       │
│ Focus Gold Accent │ #E5A93C      │ Primary CTAs, active pills, badges  │
│ Gold Hover / Glow │ #F2BA55      │ Interactive hover states            │
│ Dark Button Text  │ #121212      │ High-contrast text on gold buttons  │
└───────────────────┴──────────────┴─────────────────────────────────────┘
```

#### 1.2 Preset Color Scheme Definitions (`config/settings_data.json`)
```json
{
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
  }
}
```

#### 1.3 Global Settings Fields
- **Logo**: `assets/focusdrawer-logo.png`
- **Logo Width**: `160px` (desktop), `120px` (mobile)
- **Buttons**:
  - `buttons_radius`: `8px` (modern sleek chamfer)
  - `buttons_border_thickness`: `1px`
  - `buttons_border_opacity`: `100%`
  - Primary button background: `#E5A93C`, label: `#121212`
- **Variant Pills**:
  - `variant_pills_radius`: `8px`
  - Active variant border: `#E5A93C`
- **Cards**:
  - `card_corner_radius`: `12px`
  - `card_color_scheme`: `scheme-2`
  - `card_border_thickness`: `1px`
  - `card_border_opacity`: `20%`
- **Badges**:
  - `sale_badge_color_scheme`: `scheme-3` (Gold badge with black text)
  - `sold_out_badge_color_scheme`: `scheme-2` (Dark charcoal badge)
  - `badge_corner_radius`: `6px`

---

### R2. Home Page Showcase Specification

#### 2.1 Section Composition (`templates/index.json`)
The homepage layout must feature a clear productivity narrative:

1. **Hero Showcase Section (`image-banner`)**:
   - **Heading**: "Engineered for Focus. Built for Clean Desks."
   - **Subheading**: "Precision under-desk organizers and cable management systems that declutter your workflow and keep essentials within effortless reach."
   - **Button 1 (Primary)**: "Shop Under-Desk Drawers" (`shopify://collections/all`)
   - **Button 2 (Secondary)**: "Explore Workspace Bundles" (`shopify://collections/all`)
   - **Color Scheme**: `scheme-1` or `scheme-2`

2. **Brand Intro / Mission Statement (`rich-text`)**:
   - **Caption**: "THE FOCUSDRAWER STANDARD"
   - **Heading**: "Zero clutter. Total workflow momentum."
   - **Body Copy**: "We engineer aerospace-grade under-desk focus drawers, hidden cable raceways, and modular desk organizers built to eliminate visual friction and turn any desk into a high-output cockpit."
   - **Color Scheme**: `scheme-2`

3. **3-Pillar Value Proposition (`multicolumn`)**:
   - **Section Heading**: "Designed Around How You Work"
   - **Pillar 1: Declutter**:
     - **Title**: "Eliminate Visual Noise"
     - **Text**: "Clear your desktop surface completely. Seamless under-desk mounting keeps your daily carry, notebooks, and tools out of sight yet instantly accessible."
     - **Link**: "Explore Storage Solutions"
   - **Pillar 2: Focus**:
     - **Title**: "Stay in Flow State"
     - **Text**: "No more searching through drawers or tangled cords. Everything has a dedicated, tactile home so your attention stays locked on deep work."
     - **Link**: "See the Focus Setup"
   - **Pillar 3: Ergonomics**:
     - **Title**: "Engineered Ergonomics"
     - **Text**: "Ultra-slim low-profile design maximizes knee clearance with smooth ball-bearing slides and zero-sag solid steel mounting brackets."
     - **Link**: "View Technical Specs"
   - **Color Scheme**: `scheme-1`

4. **Featured Products Collection (`featured-collection`)**:
   - **Heading**: "Flagship Focus Gear"
   - **Description**: "Discover our best-selling under-desk drawers, modular trays, and integrated cable routing kits."
   - **Products to Show**: `6`
   - **Columns Desktop**: `4`, **Columns Mobile**: `2`
   - **Quick Add**: `"standard"` (allows direct slide-out add to cart or option modal)
   - **Image Ratio**: `"square"`
   - **Color Scheme**: `scheme-2`

5. **Interactive Feature & Dimension Highlights (`collapsible-content` or `multirow`)**:
   - **Heading**: "Built to Exacting Tolerances"
   - **Caption**: "TECHNICAL HIGHLIGHTS"
   - **Row 1**: "Universal Under-Desk Mounting" — "Attaches in under 5 minutes with included high-strength 3M VHB adhesive pads or heavy-duty wood screws for any standing or fixed desk."
   - **Row 2**: "Integrated Rear Cable Pass-Through" — "Dedicated silicone grommets allow you to charge phones, hard drives, and wireless peripherals directly inside the closed drawer."
   - **Row 3**: "Heavy-Duty 25 lb Load Rating" — "Cold-rolled solid steel chassis with silent dual ball-bearing glides engineered for over 50,000 smooth cycles."
   - **Color Scheme**: `scheme-1`

6. **Customer Testimonials (`multicolumn`)**:
   - **Heading**: "Trusted by High-Output Setups"
   - **Column 1**: "★★★★★ 'The single best upgrade to my standing desk. Everything from my iPad to hard drives lives cleanly under the desk now.' — *Alex M., Lead Software Engineer*"
   - **Column 2**: "★★★★★ 'Build quality is insane. Solid matte steel, zero wobble, and the cable pass-through is pure genius.' — *David K., Industrial Designer*"
   - **Column 3**: "★★★★★ 'I finally have a completely clear desk surface. The focus improvement is real.' — *Elena R., Founder & Creator*"
   - **Color Scheme**: `scheme-2`

7. **Newsletter / Launch Offer (`newsletter`)**:
   - **Heading**: "Join the Focus Setup Club"
   - **Paragraph**: "Subscribe for workspace optimization blueprints, new product drops, and exclusive bundle offers."
   - **Color Scheme**: `scheme-4`

---

### R3. High-Converting Product Page Specification

#### 3.1 Product Template Architecture (`templates/product.json`)
The product page must be optimized for conversion, technical transparency, and ergonomic confidence:

- **Section: `main-product`**:
  - `color_scheme`: `scheme-1` (Dark Matte Black)
  - `gallery_layout`: `thumbnail_slider`
  - `media_size`: `large`
  - `mobile_thumbnails`: `show`
  - `enable_sticky_info`: `true`
  - `image_zoom`: `lightbox`
  - `hide_variants`: `true`

#### 3.2 Main Product Blocks & Ordering
1. **`vendor`**: "FOCUSDRAWER" (uppercase caption)
2. **`title`**: `<h1>{{ product.title }}</h1>`
3. **`price`**: Large formatted price, sale badge, installments
4. **`benefit_note` (text block)**: "✦ Engineered with 25 lb load capacity & rear charging pass-through."
5. **`variant_picker`**:
   - `picker_type`: `"button"` (Pills with gold accent selected state)
   - `swatch_shape`: `"circle"` (Matte Black, Stealth Grey, Walnut, Anodized Silver)
6. **`quantity_selector`**: Chamfered quantity stepper
7. **`buy_buttons`**:
   - Primary "Add to Cart" button in FocusDrawer Gold (`#E5A93C`)
   - `show_dynamic_checkout`: `true`
8. **`description`**: Rich text product description
9. **`collapsible_tab` (Dimensions & Desk Mounting)**:
   - `heading`: "Dimensions & Desk Compatibility"
   - `icon`: `"ruler"`
   - `content`: "<p><strong>Exterior Dimensions:</strong> 18.5\" W x 11.8\" D x 2.2\" H<br/><strong>Interior Usable Space:</strong> 17.2\" W x 10.5\" D x 1.9\" H<br/><strong>Mounting Clearance Required:</strong> Minimum 19\" x 12\" flat under-desk surface.<br/><strong>Hardware Included:</strong> 6x heavy-duty wood screws + optional 3M VHB heavy-load adhesive strips.</p>"
10. **`collapsible_tab` (Materials & Craftsmanship)**:
    - `heading`: "Materials & Build Quality"
    - `icon`: `"box"`
    - `content`: "<p>Constructed from premium 1.2mm cold-rolled aerospace steel with a scratch-resistant matte powder-coated finish. Features dual-stage precision steel ball-bearing rails with smooth soft-stop bumpers.</p>"
11. **`collapsible_tab` (Cable Routing & Charging)**:
    - `heading`: "Cable Pass-Through & Tech Storage"
    - `icon`: `"lightning_bolt"`
    - `content`: "<p>Equipped with dual rear rubberized cable grommets allowing power cords, USB-C cables, and charging hubs to pass directly into the drawer. Keep devices charging silently out of view.</p>"
12. **`collapsible_tab` (Warranty & 30-Day Guarantee)**:
    - `heading`: "Lifetime Warranty & 30-Day Setup Trial"
    - `icon`: `"star"`
    - `content`: "<p>Every FocusDrawer product is backed by our Lifetime Hardware Warranty against defects and our 30-Day 'Clean Desk' Risk-Free Trial. If your setup isn't noticeably cleaner, return it for a 100% refund.</p>"
13. **`share`**: Social share drawer

#### 3.3 Sticky ATC Specification
- Desktop: `enable_sticky_info: true` locks product form during media exploration.
- Mobile / Viewport scroll: Persistent sticky buy bar attaches when the main form scrolls out of view, displaying variant summary, price, and gold "Add to Cart" CTA.

---

### R4. Navigation, Cart & Usability Specification

#### 4.1 Header & Announcement Bar
- **Announcement Bar (`sections/announcement-bar.liquid`)**:
  - Text: `"FREE SHIPPING ON WORKSPACE BUNDLES OVER $50 ✦ 30-DAY SETUP GUARANTEE"`
  - `color_scheme`: `scheme-3` (Gold bar with black text for immediate urgency) or `scheme-1`
  - Link: `shopify://collections/all`
  - Centered alignment with arrow indicator.
- **Header (`sections/header.liquid`)**:
  - `color_scheme`: `scheme-4` (Deep matte black)
  - `logo_position`: `"middle-left"`
  - `sticky_header_type`: `"on-scroll-up"`
  - `mobile_logo_position`: `"center"`
  - `menu_type_desktop`: `"dropdown"`
  - Menu Items: **Drawers**, **Cable Management**, **Desk Organizers**, **Bundles**, **About FocusDrawer**.

#### 4.2 Slide-Out Cart Drawer (`snippets/cart-drawer.liquid`)
- `cart_type`: `"drawer"` in `config/settings_data.json`.
- `cart_color_scheme`: `scheme-2` (Elevated dark charcoal background).
- **Free Shipping Progress Meter Integration**:
  - Target Threshold: `$50.00` (5000 cents in Liquid / currency units).
  - Logic:
    ```liquid
    {% assign free_shipping_threshold = 5000 %}
    {% assign cart_total = cart.total_price %}
    {% assign amount_left = free_shipping_threshold | minus: cart_total %}
    {% assign progress_percent = cart_total | times: 100 | divided_by: free_shipping_threshold %}
    {% if progress_percent > 100 %}{% assign progress_percent = 100 %}{% endif %}

    <div class="cart-drawer__shipping-meter">
      <div class="shipping-meter__message">
        {% if amount_left <= 0 %}
          <span>🎉 You've unlocked <strong>FREE Shipping</strong>!</span>
        {% else %}
          <span>Add <strong>{{ amount_left | money }}</strong> more to unlock <strong>FREE Shipping</strong></span>
        {% endif %}
      </div>
      <div class="shipping-meter__bar">
        <div class="shipping-meter__fill" style="width: {{ progress_percent }}%;"></div>
      </div>
    </div>
    ```
  - **Styling**:
    - Bar container: `#2A2A2A` background, `6px` border-radius, `8px` height.
    - Bar fill: `#E5A93C` vibrant gold with smooth `transition: width 0.3s ease`.
    - Text: `#FFFFFF` with bold gold highlights.
- **Checkout Button**: Full-width FocusDrawer Gold (`#E5A93C`) button with bold black label (`#121212`) and clear total display.

---

## Acceptance Criteria & Syntax Validation Plan

### A1. Liquid Syntax & Tag Closure
- All Liquid templates (`templates/*.json`, `templates/*.liquid`), sections (`sections/*.liquid`), and snippets (`snippets/*.liquid`) must have balanced Liquid control flow (`{% if %}` / `{% endif %}`, `{% for %}` / `{% endfor %}`, `{% form %}` / `{% endform %}`).
- No broken HTML tags or malformed Liquid filters.

### A2. Strict JSON Schema Validation
- `config/settings_data.json` must be valid RFC 8259 JSON, parseable by standard JSON linters.
- All `{% schema %}` blocks inside `sections/*.liquid` must contain strictly valid JSON with valid setting types (`text`, `textarea`, `inline_richtext`, `richtext`, `image_picker`, `select`, `checkbox`, `range`, `color`, `color_scheme`, `header`, `paragraph`).
- All template JSON files (`templates/index.json`, `templates/product.json`, `templates/collection*.json`) must be valid JSON with correct section types, block orders, and matching block schemas.

### A3. Brand Assets & Logo Integration
- `assets/focusdrawer-logo.png` must be referenced in `config/settings_data.json` (`"logo": "focusdrawer-logo.png"` or fallback in `header.liquid`).
- Logo must display crisply without pixelation or aspect-ratio distortion on mobile (<750px), tablet (750px-989px), and desktop (>=990px).

### A4. Styling & Color Palette Uniformity
- Gold accent `#E5A93C` uniformly applied to:
  - Primary CTA buttons (`.button--primary`, `.product-form__submit`, `.cart__checkout-button`)
  - Free shipping progress meter bar fill (`.shipping-meter__fill`)
  - Sale badges (`.badge--sale`)
  - Selected variant pill outlines (`.product-form__input input[type=radio]:checked + label`)
  - Focus indicators (`:focus-visible` rings)
- Backgrounds uniformly render dark matte charcoal (`#121212` / `#1E1E1E`) with crisp white (`#FFFFFF`) typography.

### A5. Responsive Breakpoint Consistency
- **Mobile (< 750px)**: 1-column value props, 2-column featured product grid, collapsible navigation drawer, full-width sticky ATC button.
- **Tablet (750px - 989px)**: 2-column grid, responsive product media gallery, optimized drawer width.
- **Desktop (>= 990px)**: 4-column product grid, 3-column value props, side-by-side sticky product layout, desktop navigation dropdowns.

---

## Verification & Validation Commands

To verify JSON validity and Liquid syntax across all modified files, execute the following commands in PowerShell:

```powershell
# 1. Validate config/settings_data.json
powershell -Command "$content = Get-Content 'config/settings_data.json' -Raw; $json = $content | ConvertFrom-Json; Write-Host 'settings_data.json is valid JSON'"

# 2. Validate templates/index.json
powershell -Command "$content = Get-Content 'templates/index.json' -Raw; $json = $content | ConvertFrom-Json; Write-Host 'templates/index.json is valid JSON'"

# 3. Validate templates/product.json
powershell -Command "$content = Get-Content 'templates/product.json' -Raw; $json = $content | ConvertFrom-Json; Write-Host 'templates/product.json is valid JSON'"

# 4. Validate sections schema blocks
powershell -Command "Get-ChildItem 'sections/*.liquid' | ForEach-Object { $raw = Get-Content $_.FullName -Raw; if ($raw -match '\{%\s*schema\s*%\}([\s\S]*?)\{%\s*endschema\s*%\}') { try { $matches[1] | ConvertFrom-Json | Out-Null; Write-Host ($_.Name + ': schema JSON valid') } catch { Write-Error ($_.Name + ': schema JSON INVALID') } } }"
```
