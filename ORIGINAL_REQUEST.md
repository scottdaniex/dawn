# Original User Request

## 2026-09-01T12:17:14Z

Customize and brand the Shopify Dawn theme in `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn` for FocusDrawer, a premium productivity and desk setup brand (under-desk focus drawers, clean cable management, workspace organizers). Integrate the brand logo, a dark-smoke/white/gold palette, and develop high-converting home, product, and collection templates.

Working directory: C:\Users\asedacasd\.gemini\antigravity\scratch\dawn
Integrity mode: development

## Requirements

### R1. Brand Identity & Visual System
Integrate the FocusDrawer logo (`assets/focusdrawer-logo.png`) into the header and favicon settings. Configure global color schemes and typography in `config/settings_data.json` and theme stylesheets using the brand colors: matte black/dark charcoal background, crisp white typography, and vibrant gold accent (#E5A93C) for buttons, badges, and call-to-actions.

### R2. Home Page Showcase
Build a modular, visually compelling homepage layout tailored for productivity desk gear. Include an impactful hero section showcasing the under-desk drawer, a 3-pillar value proposition section (Declutter, Focus, Ergonomics), a featured products grid with quick-add functionality, interactive feature comparison or dimension highlights, and customer testimonials.

### R3. High-Converting Product Page
Customize the product template (`templates/product.json` and related sections) to showcase FocusDrawer products with high-resolution image galleries, dynamic variant selectors, sticky "Add to Cart" button on scroll, and expandable accordion drawers for technical specifications (dimensions, mounting instructions, materials, warranty).

### R4. Navigation, Cart & Usability
Implement a branded announcement bar (e.g., free shipping on workspace bundles), responsive mobile drawer navigation, and seamless slide-out cart (cart drawer) styled with the brand palette and free shipping progress meter.

## Acceptance Criteria

### Schema & Syntax Validation
- [ ] All Liquid files (`sections/*.liquid`, `snippets/*.liquid`) and templates have valid Liquid syntax with properly closed tags.
- [ ] All Liquid section `{% schema %}` blocks and JSON template files (`templates/*.json`, `config/settings_data.json`) contain strictly valid, parseable JSON.

### Brand & Assets
- [ ] Logo file `assets/focusdrawer-logo.png` is properly linked in default theme settings and displays crisply in both desktop and mobile headers.
- [ ] Primary buttons, focus states, and accents uniformly use the FocusDrawer gold accent color.
- [ ] Typography and spacing scale consistently across all standard breakpoints (mobile, tablet, desktop).

### Page Templates & Functionality
- [ ] Homepage renders complete hero, value proposition, featured product, and review sections with coherent FocusDrawer placeholder copy and imagery.
- [ ] Product page displays gallery, variant options, accordion specs, and sticky ATC without console or layout errors.
- [ ] Cart drawer opens and updates smoothly when items are added.
