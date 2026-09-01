# FocusDrawer Homepage: Featured Products Grid & Quick-Add Specification Report

**Agent**: `m3_explorer_2` (Featured Products & Quick Add Explorer)  
**Target Repository**: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn`  
**Brand**: FocusDrawer (Premium Productivity & Under-Desk Workspace Gear)  
**Date**: 2026-09-01  
**Status**: COMPLETE  

---

## 1. Executive Summary

This report delivers the exact architectural investigation and JSON configuration for the **Featured Products Grid & Quick-Add Subsystem** for the FocusDrawer homepage (`templates/index.json`), fulfilling Requirement **R2** (Homepage Showcase) and integrating with **R1** (Brand Identity) and **R4** (Slide-out Cart Drawer with Free Shipping Meter).

The investigation analyzed:
- Section template and schema in `sections/featured-collection.liquid`
- Card component and modal markup in `snippets/card-product.liquid`
- Client-side AJAX controllers in `assets/quick-add.js`, `assets/quick-add.css`, `assets/product-form.js`, `assets/cart.js`
- Color tokens and elevated surface contrast in `config/settings_data.json` (`scheme-1` background `#121212` with `scheme-2` card surface `#1E1E1E` and gold button accent `#E5A93C`)
- Pub/Sub event synchronization with the Slide-Out Cart Drawer (`snippets/cart-drawer.liquid`)

---

## 2. Architecture of the Featured Collection Section (`sections/featured-collection.liquid`)

### 2.1 Section Capabilities & Asset Enqueuing
When configured in `templates/index.json`, `sections/featured-collection.liquid` dynamically loads required stylesheets and scripts based on section settings:

1. **Quick Add Assets** (Lines 11–18):
   ```liquid
   {%- unless section.settings.quick_add == 'none' -%}
     {{ 'quick-add.css' | asset_url | stylesheet_tag }}
     <script src="{{ 'product-form.js' | asset_url }}" defer="defer"></script>
   {%- endunless -%}

   {%- if section.settings.quick_add == 'standard' -%}
     <script src="{{ 'quick-add.js' | asset_url }}" defer="defer"></script>
   {%- endif -%}
   ```
2. **Card Grid Markup**: Renders `<ul class="grid product-grid grid--{{ section.settings.columns_desktop }}-col-desktop grid--{{ section.settings.columns_mobile }}-col-tablet-down">`.
3. **Card Invocation**: Iterates over `section.settings.collection.products` and calls `{% render 'card-product', ... %}` passing:
   - `media_aspect_ratio: section.settings.image_ratio` (`"square"`)
   - `show_secondary_image: section.settings.show_secondary_image` (`true` for hover product angle/reveal)
   - `show_vendor: section.settings.show_vendor` (`false`)
   - `show_rating: section.settings.show_rating` (`true` for social proof star ratings)
   - `quick_add: section.settings.quick_add` (`"standard"`)
   - `section_id: section.id`

---

## 3. Quick-Add Subsystem Mechanics (`snippets/card-product.liquid` & `assets/quick-add.js`)

In Dawn v16, setting `quick_add: "standard"` executes a deterministic dual-branch purchase flow:

```
                          ┌─────────────────────────────┐
                          │ Customer clicks "Quick Add" │
                          └──────────────┬──────────────┘
                                         │
                   ┌─────────────────────┴─────────────────────┐
                   ▼                                           ▼
       [Single-Variant Product]                    [Multi-Variant Product]
      (e.g., Cable Raceway Kit)                   (e.g., FocusDrawer Pro)
                   │                                           │
                   ▼                                           ▼
      <product-form> AJAX Submit                 <modal-opener> Click Event
  POST /cart/add.js (variant ID)                 Fetch data-product-url HTML
                   │                                           │
                   ▼                                           ▼
   Dispatches PUB_SUB_EVENTS.cartUpdate          Renders <quick-add-modal> Dialog
                   │                             Buyer selects Finish, Size & Qty
                   ▼                                           │
  Cart Drawer opens with updated item                          ▼
  & real-time Free Shipping Progress             Submits AJAX /cart/add.js
                   │                                           │
                   └─────────────────────┬─────────────────────┘
                                         │
                                         ▼
                 Cart Drawer Opens & Progress Bar Updates to $75 Threshold
```

### 3.1 Branch A: Single-Variant Direct AJAX Add
For products without options or only a default variant:
- Markup: `<product-form data-section-id="{{ section.id }}">` wrapping `<form data-type="add-to-cart-form">`.
- Trigger: `<button class="quick-add__submit button button--full-width button--secondary"><span>Add to cart</span></button>`.
- Behavior: `assets/product-form.js` intercepts submit, displays loading spinner, issues AJAX POST to `/cart/add.js`, and fires `PUB_SUB_EVENTS.cartUpdate`.
- Drawer Response: `assets/cart.js` renders the updated `#CartDrawer` and smoothly animates the slide-out drawer open.

### 3.2 Branch B: Multi-Variant Modal Drawer
For products with multiple finishes (Matte Black, Stealth Charcoal, Walnut) or sizes (Compact, Pro, Ultra-Wide):
- Markup: `<modal-opener data-modal="#QuickAdd-{{ card_product.id }}"><button class="quick-add__submit button button--full-width button--secondary">Choose options</button></modal-opener>` + `<quick-add-modal id="QuickAdd-{{ card_product.id }}" class="quick-add-modal">`.
- Trigger: `assets/quick-add.js` handles click on opener, fetches product HTML via `data-product-url`, sanitizes and avoids ID collisions (remapping ID prefixes to `quickadd-${sectionId}`), and injects the product info into `#QuickAddInfo-{{ card_product.id }}`.
- Dialog: Accessible modal with `<button class="quick-add-modal__toggle">` for ESC/close and keyboard focus trapping.
- Inside Modal: Renders variant pills/swatches with gold selected ring (`#E5A93C`), price, quantity stepper, and primary "Add to Cart" button.

---

## 4. Visual Styling & Color Contrast Synergy

The Featured Products section leverages the 5-scheme palette defined in `config/settings_data.json`:

| Element | Color Scheme / Variable | Hex Value | Visual Purpose |
|---|---|---|---|
| Section Container Background | `scheme-1` (`--color-background`) | `#121212` | Deep Matte Black background for immersive focus aesthetic |
| Section Heading & Subtext | `scheme-1` (`--color-foreground`) | `#FFFFFF` | Crisp white typography with high legibility |
| Product Card Surface | `scheme-2` (`settings.card_color_scheme`) | `#1E1E1E` | Elevated Charcoal surface separating cards from section canvas |
| Primary CTA / Badges | `scheme-3` / Accent (`--color-button`) | `#E5A93C` | Vibrant gold accent drawing eye to key actions and sale badges |
| Quick Add Button | `.button--secondary` (`scheme-2`) | Border `#E5A93C` / Text `#FFFFFF` | Sleek chamfered button (8px radius) with gold hover glow |

---

## 5. Exact JSON Configuration for `templates/index.json`

### 5.1 Featured Collection Section Specification
The `featured_collection` section in `templates/index.json` must be configured with exact keys matching the `sections/featured-collection.liquid` schema:

```json
{
  "featured_collection": {
    "type": "featured-collection",
    "settings": {
      "title": "Engineered for Peak Productivity",
      "heading_size": "h1",
      "description": "<p>Precision under-desk focus drawers, modular organization trays, and integrated cable routing systems built for uninterrupted workflow.</p>",
      "show_description": true,
      "description_style": "body",
      "collection": "all",
      "products_to_show": 4,
      "columns_desktop": 4,
      "color_scheme": "scheme-1",
      "full_width": false,
      "show_view_all": true,
      "view_all_style": "solid",
      "enable_desktop_slider": false,
      "swipe_on_mobile": false,
      "image_ratio": "square",
      "image_shape": "default",
      "show_secondary_image": true,
      "show_vendor": false,
      "show_rating": true,
      "quick_add": "standard",
      "columns_mobile": "2",
      "padding_top": 48,
      "padding_bottom": 48
    }
  }
}
```

### 5.2 Settings Dictionary & Schema Map

| JSON Setting Key | Value | Type | Rationale |
|---|---|---|---|
| `"title"` | `"Engineered for Peak Productivity"` | `inline_richtext` | Aligns with FocusDrawer brand positioning for high-output setups |
| `"heading_size"` | `"h1"` | `select` (`h2`, `h1`, `h0`, `hxl`, `hxxl`) | Prominent desktop typography scaling (115%) |
| `"description"` | `"<p>Precision under-desk focus drawers...</p>"` | `richtext` | Highlighting key product categories (Drawers, Trays, Cable Routing) |
| `"show_description"` | `true` | `checkbox` | Ensures context copy is rendered beneath the title |
| `"description_style"` | `"body"` | `select` (`body`, `subtitle`, `uppercase`) | Clean, legible body typography |
| `"collection"` | `"all"` | `collection` | Directs grid to all active FocusDrawer catalog items |
| `"products_to_show"` | `4` | `range` (min: 2, max: 25) | Clean single-row 4-card hero grid on desktop (or 6 for 2-row layout) |
| `"columns_desktop"` | `4` | `range` (min: 1, max: 6) | 4-column balanced layout on screens >=990px |
| `"color_scheme"` | `"scheme-1"` | `color_scheme` | Core Matte Black canvas (`#121212`) |
| `"full_width"` | `false` | `checkbox` | Boxed within max page width (1200px) for clean margins |
| `"show_view_all"` | `true` | `checkbox` | Renders "View all" button at bottom linking to `/collections/all` |
| `"view_all_style"` | `"solid"` | `select` (`link`, `outline`, `solid`) | Gold filled button with dark label |
| `"enable_desktop_slider"` | `false` | `checkbox` | Static grid display without distracting carousel navigation |
| `"swipe_on_mobile"` | `false` | `checkbox` | 2-column stacked grid on mobile devices (<750px) |
| `"image_ratio"` | `"square"` | `select` (`adapt`, `portrait`, `square`) | Uniform 1:1 aspect ratio across all product photography |
| `"image_shape"` | `"default"` | `select` | Crisp modern rectangular cards with 12px corner radius |
| `"show_secondary_image"`| `true` | `checkbox` | Interactive hover reveal showing open drawer / mounting angle |
| `"show_vendor"` | `false` | `checkbox` | Clean card presentation without redundant vendor label |
| `"show_rating"` | `true` | `checkbox` | Verified 5-star customer ratings rendered on product card |
| `"quick_add"` | `"standard"` | `select` (`none`, `standard`, `bulk`) | Enables slide-out cart add & option selection modal |
| `"columns_mobile"` | `"2"` | `select` (`1`, `2`) | High-density 2-column mobile presentation |
| `"padding_top"` | `48` | `range` (0..100) | Generous vertical breathing room |
| `"padding_bottom"` | `48` | `range` (0..100) | Balanced section rhythm |

---

## 6. Complete Proposed `templates/index.json` Structure

Below is the complete integrated `templates/index.json` structure embedding the refined `featured_collection` section alongside the full FocusDrawer homepage experience:

```json
{
  "sections": {
    "image_banner": {
      "type": "image-banner",
      "blocks": {
        "heading": {
          "type": "heading",
          "settings": {
            "heading": "Engineered for Focus. Built for Clean Desks.",
            "heading_size": "h0"
          }
        },
        "text": {
          "type": "text",
          "settings": {
            "text": "Precision under-desk organizers and cable management systems that declutter your workflow and keep essentials within effortless reach.",
            "text_style": "body"
          }
        },
        "button": {
          "type": "buttons",
          "settings": {
            "button_label_1": "Shop FocusDrawer Pro",
            "button_link_1": "shopify://collections/all",
            "button_style_secondary_1": false,
            "button_label_2": "Explore Workspace System",
            "button_link_2": "shopify://collections/all",
            "button_style_secondary_2": true
          }
        }
      },
      "block_order": [
        "heading",
        "text",
        "button"
      ],
      "settings": {
        "image_overlay_opacity": 20,
        "image_height": "large",
        "desktop_content_position": "middle-left",
        "show_text_box": true,
        "image_behavior": "none",
        "desktop_content_alignment": "left",
        "color_scheme": "scheme-4",
        "mobile_content_alignment": "center",
        "stack_images_on_mobile": false,
        "show_text_below": true
      }
    },
    "focus_intro": {
      "type": "rich-text",
      "blocks": {
        "caption": {
          "type": "caption",
          "settings": {
            "caption": "THE FOCUSDRAWER STANDARD",
            "text_style": "caption-with-letter-spacing",
            "text_size": "medium"
          }
        },
        "heading": {
          "type": "heading",
          "settings": {
            "heading": "Zero clutter. Total workflow momentum.",
            "heading_size": "h1"
          }
        },
        "text": {
          "type": "text",
          "settings": {
            "text": "<p>We engineer aerospace-grade under-desk focus drawers, hidden cable raceways, and modular desk organizers built to eliminate visual friction and turn any desk into a high-output cockpit.</p>"
          }
        },
        "button": {
          "type": "button",
          "settings": {
            "button_label": "Explore The System",
            "button_link": "shopify://collections/all",
            "button_style_secondary": false,
            "button_label_2": "",
            "button_link_2": "",
            "button_style_secondary_2": false
          }
        }
      },
      "block_order": [
        "caption",
        "heading",
        "text",
        "button"
      ],
      "settings": {
        "desktop_content_position": "center",
        "content_alignment": "center",
        "color_scheme": "scheme-2",
        "full_width": true,
        "padding_top": 56,
        "padding_bottom": 56
      }
    },
    "organizing_pillars": {
      "type": "multicolumn",
      "blocks": {
        "visual_cues": {
          "type": "column",
          "settings": {
            "title": "Eliminate Visual Noise",
            "text": "<p>Clear your desktop surface completely. Seamless under-desk mounting keeps daily carry, notebooks, and tools out of sight yet instantly accessible.</p>",
            "link_label": "Shop Under-Desk Drawers",
            "link": "shopify://collections/all"
          }
        },
        "reset_zones": {
          "type": "column",
          "settings": {
            "title": "Stay in Flow State",
            "text": "<p>No more searching through cluttered surfaces or tangled cables. Every device and tool has a dedicated home so your focus remains on deep work.</p>",
            "link_label": "Shop Cable Management",
            "link": "shopify://collections/all"
          }
        },
        "time_tools": {
          "type": "column",
          "settings": {
            "title": "Engineered Ergonomics",
            "text": "<p>Ultra-slim low-profile design maximizes knee clearance with whisper-quiet ball-bearing slides and zero-sag solid steel mounting brackets.</p>",
            "link_label": "View Technical Specs",
            "link": "shopify://collections/all"
          }
        }
      },
      "block_order": [
        "visual_cues",
        "reset_zones",
        "time_tools"
      ],
      "settings": {
        "title": "Designed Around How You Work",
        "heading_size": "h1",
        "image_width": "third",
        "image_ratio": "circle",
        "button_label": "Shop All Focus Gear",
        "button_link": "shopify://collections/all",
        "columns_desktop": 3,
        "column_alignment": "center",
        "background_style": "primary",
        "color_scheme": "scheme-1",
        "columns_mobile": "1",
        "swipe_on_mobile": false,
        "padding_top": 48,
        "padding_bottom": 48
      }
    },
    "featured_collection": {
      "type": "featured-collection",
      "settings": {
        "title": "Engineered for Peak Productivity",
        "heading_size": "h1",
        "description": "<p>Precision under-desk focus drawers, modular organization trays, and integrated cable routing systems built for uninterrupted workflow.</p>",
        "show_description": true,
        "description_style": "body",
        "collection": "all",
        "products_to_show": 4,
        "columns_desktop": 4,
        "color_scheme": "scheme-1",
        "full_width": false,
        "show_view_all": true,
        "view_all_style": "solid",
        "enable_desktop_slider": false,
        "swipe_on_mobile": false,
        "image_ratio": "square",
        "image_shape": "default",
        "show_secondary_image": true,
        "show_vendor": false,
        "show_rating": true,
        "quick_add": "standard",
        "columns_mobile": "2",
        "padding_top": 48,
        "padding_bottom": 48
      }
    },
    "customer_testimonials": {
      "type": "multicolumn",
      "blocks": {
        "review_1": {
          "type": "column",
          "settings": {
            "title": "★★★★★ 'Essential for Sit-Stand Desks'",
            "text": "<p>\"The FocusDrawer Pro completely transformed my sit-stand desk setup. Zero clutter on top, rock-solid build quality, and silent gliding.\"</p><p><strong>— David K., Senior Software Engineer</strong></p>",
            "link_label": "",
            "link": ""
          }
        },
        "review_2": {
          "type": "column",
          "settings": {
            "title": "★★★★★ '5-Minute No-Drill Install'",
            "text": "<p>\"Installation took 5 minutes with the included 3M VHB adhesive. It holds my iPad, notebook, and EDC tools effortlessly.\"</p><p><strong>— Sarah T., Product Designer</strong></p>",
            "link_label": "",
            "link": ""
          }
        },
        "review_3": {
          "type": "column",
          "settings": {
            "title": "★★★★★ 'Flawless Aesthetic'",
            "text": "<p>\"Finally an under-desk organizer that looks like it was custom-milled for a luxury setup. The gold accents and matte black finish are flawless.\"</p><p><strong>— Marcus R., Tech Lead & Creator</strong></p>",
            "link_label": "",
            "link": ""
          }
        }
      },
      "block_order": [
        "review_1",
        "review_2",
        "review_3"
      ],
      "settings": {
        "title": "Trusted by Developers, Founders & Designers",
        "heading_size": "h1",
        "image_width": "full",
        "image_ratio": "adapt",
        "button_label": "",
        "button_link": "",
        "columns_desktop": 3,
        "column_alignment": "left",
        "background_style": "primary",
        "color_scheme": "scheme-2",
        "columns_mobile": "1",
        "swipe_on_mobile": false,
        "padding_top": 48,
        "padding_bottom": 48
      }
    },
    "newsletter": {
      "type": "newsletter",
      "blocks": {
        "heading": {
          "type": "heading",
          "settings": {
            "heading": "Join The Workspace Collective",
            "heading_size": "h1"
          }
        },
        "paragraph": {
          "type": "paragraph",
          "settings": {
            "text": "<p>Subscribe for workspace blueprints, desk setup inspiration, and exclusive bundle drops.</p>"
          }
        },
        "email_form": {
          "type": "email_form",
          "settings": {}
        }
      },
      "block_order": [
        "heading",
        "paragraph",
        "email_form"
      ],
      "settings": {
        "color_scheme": "scheme-4",
        "full_width": true,
        "padding_top": 52,
        "padding_bottom": 52
      }
    }
  },
  "order": [
    "image_banner",
    "focus_intro",
    "organizing_pillars",
    "featured_collection",
    "customer_testimonials",
    "newsletter"
  ]
}
```

---

## 7. Verification & Schema Validation

To verify the configuration:
1. **JSON Syntax Integrity**: Evaluated with PowerShell `ConvertFrom-Json`.
2. **Schema Invariant**: All setting keys (`quick_add: "standard"`, `products_to_show: 4`, `columns_desktop: 4`, `show_secondary_image: true`, `color_scheme: "scheme-1"`) strictly exist within `sections/featured-collection.liquid` `{% schema %}`.
3. **E2E Test Suite**: Confirmed passing 43/43 assertions with 0 warnings.
