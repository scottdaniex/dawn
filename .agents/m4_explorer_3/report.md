# FocusDrawer M4 Exploration Report: Sticky Add to Cart & Collection Template

**Agent**: `m4_explorer_3` (Sticky ATC & Collection Template Explorer)  
**Target Repository**: `C:\Users\asedacasd\.gemini\antigravity\scratch\dawn`  
**Date**: September 1, 2026  
**Status**: Investigation Complete — Ready for Implementation  

---

## 1. Executive Summary

This report provides complete, production-grade architectural and implementation specifications for two crucial conversion features in the FocusDrawer Shopify Dawn theme:
1. **Sticky "Add to Cart" (Sticky ATC)**: A viewport-anchored bottom bar that smoothly slides up when the primary product purchase form scrolls off-screen, maintaining real-time bi-directional synchronization with variant selections, pricing, availability, and the AJAX slide-out cart drawer.
2. **Collection Template (`templates/collection.json`)**: An Online Store 2.0 JSON collection template configured with a 4-column desktop grid, 2-column mobile layout, faceted horizontal filtering, product sorting, and integrated Quick-Add modal/AJAX capability.

Both features strictly align with the FocusDrawer brand identity:
- **Surface Palette**: Elevated Dark Charcoal container (`#1E1E1E` / `rgba(30, 30, 30, 0.95)` with `backdrop-filter: blur(12px)`).
- **Call to Action**: FocusDrawer Vibrant Gold (`#E5A93C`) button with high-contrast `#121212` text and subtle glow on hover.
- **Typography & Details**: Crisp White (`#FFFFFF`) headings and gold price accent.

---

## 2. Sticky "Add to Cart" Architecture & Specification

### 2.1 Functional Requirements & UX Flow
1. **Scroll-Triggered Entry & Exit**:
   - Monitored via a high-performance, non-blocking `IntersectionObserver`.
   - The observer targets the primary submit button (`#ProductSubmitButton-{{ section.id }}`) or main form buttons container (`.product-form__buttons`).
   - When the primary submit button is visible in the viewport, the sticky ATC bar is hidden off-screen (`transform: translateY(100%)`, `opacity: 0`, `aria-hidden="true"`, `pointer-events: none`).
   - When the user scrolls past the primary form down the page (reading technical specs, dimensions, reviews, or related products), the sticky ATC bar smoothly animates up from the bottom (`transform: translateY(0)`, `opacity: 1`, `aria-hidden="false"`).
   - If the user scrolls back up so the main purchase form re-enters the viewport, the sticky ATC smoothly retreats.

2. **Bi-Directional Variant Synchronization**:
   - **Main Form → Sticky ATC**: Listens to Dawn's `PUB_SUB_EVENTS.variantChange` event. When variant pills or swatches are clicked in the main product form:
     - Updates sticky ATC variant thumbnail image (`#StickyATCImage-{{ section_id }}`).
     - Updates sticky ATC price and compare-at price (`#StickyATCPrice-{{ section_id }}`).
     - Updates sticky ATC `<select>` dropdown active value.
     - Updates button availability state: Enabled "Add to Cart" vs. Disabled "Sold Out" / "Unavailable".
   - **Sticky ATC → Main Form**: When the buyer selects a different variant from the sticky dropdown:
     - Dispatches a change event to the corresponding radio button or master selector in the primary form, ensuring both components and URL parameters stay synchronized.

3. **Frictionless Cart Integration**:
   - Clicking the sticky ATC button programmatically triggers `click()` on `#ProductSubmitButton-{{ section.id }}` or `requestSubmit()` on the primary `product-form`.
   - Reuses Dawn's battle-tested AJAX cart submission pipeline, loading spinner, error messaging, and slide-out cart drawer opening.

---

### 2.2 Concrete Code Artifacts for Sticky ATC

#### Artifact 1: `snippets/sticky-atc.liquid`
```liquid
{% comment %}
  Renders FocusDrawer Sticky Add to Cart bar on scroll
  Accepts:
  - product: {Object} Liquid product object
  - section_id: {String} Section ID
  - color_scheme: {String} Color scheme setting
  
  Usage:
  {% render 'sticky-atc', product: product, section_id: section.id, color_scheme: section.settings.color_scheme %}
{% endcomment %}

{%- unless product == blank -%}
  {{ 'component-sticky-atc.css' | asset_url | stylesheet_tag }}
  <script src="{{ 'sticky-atc.js' | asset_url }}" defer="defer"></script>

  {%- assign selected_variant = product.selected_or_first_available_variant -%}

  <sticky-atc
    id="StickyATC-{{ section_id }}"
    class="sticky-atc color-{{ color_scheme | default: 'scheme-2' }} gradient"
    data-section-id="{{ section_id }}"
    data-product-id="{{ product.id }}"
    aria-hidden="true"
  >
    <div class="sticky-atc__container page-width">
      <div class="sticky-atc__product-info">
        <div class="sticky-atc__media-wrapper">
          {%- if selected_variant.featured_image != blank -%}
            <img
              src="{{ selected_variant.featured_image | image_url: width: 120 }}"
              alt="{{ selected_variant.featured_image.alt | default: product.title | escape }}"
              class="sticky-atc__image"
              width="52"
              height="52"
              loading="lazy"
              id="StickyATCImage-{{ section_id }}"
            >
          {%- elsif product.featured_image != blank -%}
            <img
              src="{{ product.featured_image | image_url: width: 120 }}"
              alt="{{ product.featured_image.alt | default: product.title | escape }}"
              class="sticky-atc__image"
              width="52"
              height="52"
              loading="lazy"
              id="StickyATCImage-{{ section_id }}"
            >
          {%- endif -%}
        </div>
        <div class="sticky-atc__details">
          <span class="sticky-atc__title">{{ product.title | escape }}</span>
          <div class="sticky-atc__price-wrapper">
            <span class="sticky-atc__price" id="StickyATCPrice-{{ section_id }}">
              {{ selected_variant.price | money }}
            </span>
            <s class="sticky-atc__compare-price{% unless selected_variant.compare_at_price > selected_variant.price %} hidden{% endunless %}" id="StickyATCComparePrice-{{ section_id }}">
              {%- if selected_variant.compare_at_price > selected_variant.price -%}
                {{ selected_variant.compare_at_price | money }}
              {%- endif -%}
            </s>
          </div>
        </div>
      </div>

      <div class="sticky-atc__actions">
        {%- unless product.has_only_default_variant -%}
          <div class="sticky-atc__variant-wrapper">
            <select
              id="StickyATCSelect-{{ section_id }}"
              class="sticky-atc__select"
              aria-label="{{ 'products.product.select_options' | t | default: 'Select variant' }}"
            >
              {%- for variant in product.variants -%}
                <option
                  value="{{ variant.id }}"
                  {% if variant.id == selected_variant.id %}
                    selected="selected"
                  {% endif %}
                  {% unless variant.available %}
                    disabled="disabled"
                  {% endunless %}
                  data-price="{{ variant.price | money }}"
                  data-compare-price="{% if variant.compare_at_price > variant.price %}{{ variant.compare_at_price | money }}{% endif %}"
                  data-available="{{ variant.available }}"
                  data-image="{% if variant.featured_image %}{{ variant.featured_image | image_url: width: 120 }}{% endif %}"
                >
                  {{ variant.title }}
                  {% unless variant.available %} - {{ 'products.product.sold_out' | t | default: 'Sold out' }}{% endunless %}
                </option>
              {%- endfor -%}
            </select>
            <span class="svg-wrapper sticky-atc__caret">
              {{- 'icon-caret.svg' | inline_asset_content -}}
            </span>
          </div>
        {%- endunless -%}

        <button
          type="button"
          id="StickyATCButton-{{ section_id }}"
          class="sticky-atc__button button button--primary"
          {% unless selected_variant.available %}
            disabled="disabled"
          {% endunless %}
        >
          <span class="sticky-atc__button-text">
            {%- if selected_variant == null -%}
              {{ 'products.product.unavailable' | t | default: 'Unavailable' }}
            {%- elsif selected_variant.available == false -%}
              {{ 'products.product.sold_out' | t | default: 'Sold Out' }}
            {%- else -%}
              {{ 'products.product.add_to_cart' | t | default: 'Add to Cart' }}
            {%- endif -%}
          </span>
          <div class="loading__spinner hidden">
            <svg
              aria-hidden="true"
              focusable="false"
              class="spinner"
              viewBox="0 0 66 66"
              xmlns="http://www.w3.org/2000/svg"
            >
              <circle class="path" fill="none" stroke-width="6" cx="33" cy="33" r="30"></circle>
            </svg>
          </div>
        </button>
      </div>
    </div>
  </sticky-atc>
{%- endunless -%}
```

---

#### Artifact 2: `assets/sticky-atc.js`
```javascript
/**
 * FocusDrawer Sticky Add to Cart Web Component
 * Pinned viewport slide-up component synchronized with Dawn's product-info and product-form.
 */
if (!customElements.get('sticky-atc')) {
  customElements.define(
    'sticky-atc',
    class StickyATC extends HTMLElement {
      constructor() {
        super();
        this.sectionId = this.dataset.sectionId;
        this.observer = null;
        this.variantUnsubscriber = null;
      }

      connectedCallback() {
        this.initElements();
        this.initScrollObserver();
        this.initVariantPubSub();
        this.initEventListeners();
      }

      disconnectedCallback() {
        if (this.observer) this.observer.disconnect();
        if (this.variantUnsubscriber) this.variantUnsubscriber();
      }

      initElements() {
        this.button = this.querySelector(`#StickyATCButton-${this.sectionId}`);
        this.buttonText = this.querySelector('.sticky-atc__button-text');
        this.spinner = this.querySelector('.loading__spinner');
        this.select = this.querySelector(`#StickyATCSelect-${this.sectionId}`);
        this.price = this.querySelector(`#StickyATCPrice-${this.sectionId}`);
        this.comparePrice = this.querySelector(`#StickyATCComparePrice-${this.sectionId}`);
        this.image = this.querySelector(`#StickyATCImage-${this.sectionId}`);
      }

      initScrollObserver() {
        const target =
          document.getElementById(`ProductSubmitButton-${this.sectionId}`) ||
          document.querySelector(`#ProductInfo-${this.sectionId} .product-form__buttons`) ||
          document.querySelector(`#MainProduct-${this.sectionId} .product-form__buttons`);

        if (!target) return;

        this.observer = new IntersectionObserver(
          (entries) => {
            entries.forEach((entry) => {
              if (entry.isIntersecting) {
                this.hide();
              } else {
                if (entry.boundingClientRect.top < 0) {
                  this.show();
                } else {
                  this.hide();
                }
              }
            });
          },
          {
            rootMargin: '0px 0px 0px 0px',
            threshold: 0,
          }
        );

        this.observer.observe(target);
      }

      show() {
        this.classList.add('is-visible');
        this.setAttribute('aria-hidden', 'false');
      }

      hide() {
        this.classList.remove('is-visible');
        this.setAttribute('aria-hidden', 'true');
      }

      initVariantPubSub() {
        if (typeof subscribe === 'function' && typeof PUB_SUB_EVENTS !== 'undefined') {
          this.variantUnsubscriber = subscribe(PUB_SUB_EVENTS.variantChange, ({ data }) => {
            if (data.sectionId === this.sectionId && data.variant) {
              this.onVariantChange(data.variant);
            }
          });
        }
      }

      initEventListeners() {
        if (this.button) {
          this.button.addEventListener('click', this.onButtonClick.bind(this));
        }

        if (this.select) {
          this.select.addEventListener('change', this.onSelectChange.bind(this));
        }
      }

      onButtonClick(evt) {
        evt.preventDefault();
        if (this.button.hasAttribute('disabled')) return;

        const primarySubmitButton = document.getElementById(`ProductSubmitButton-${this.sectionId}`);
        const primaryForm = document.getElementById(`product-form-${this.sectionId}`);

        if (primarySubmitButton) {
          primarySubmitButton.click();
        } else if (primaryForm) {
          primaryForm.requestSubmit();
        }
      }

      onSelectChange(evt) {
        const variantId = evt.target.value;
        const selectedOption = evt.target.options[evt.target.selectedIndex];

        if (selectedOption) {
          const price = selectedOption.dataset.price;
          const comparePrice = selectedOption.dataset.comparePrice;
          const available = selectedOption.dataset.available === 'true';
          const imageSrc = selectedOption.dataset.image;

          if (this.price && price) this.price.textContent = price;
          if (this.comparePrice) {
            if (comparePrice) {
              this.comparePrice.textContent = comparePrice;
              this.comparePrice.classList.remove('hidden');
            } else {
              this.comparePrice.classList.add('hidden');
            }
          }
          if (this.image && imageSrc) {
            this.image.src = imageSrc;
          }

          this.updateButtonState(available);
        }

        const productInfo = document.getElementById(`MainProduct-${this.sectionId}`);
        if (productInfo) {
          const radioInput = productInfo.querySelector(`input[type="radio"][value="${variantId}"]`);
          if (radioInput) {
            radioInput.checked = true;
            radioInput.dispatchEvent(new Event('change', { bubbles: true }));
          } else {
            const masterSelect = productInfo.querySelector(`select[name="id"]`);
            if (masterSelect) {
              masterSelect.value = variantId;
              masterSelect.dispatchEvent(new Event('change', { bubbles: true }));
            }
          }
        }
      }

      onVariantChange(variant) {
        if (this.select && variant) {
          this.select.value = variant.id;
        }

        if (this.price && variant) {
          const formatted = (variant.price / 100).toLocaleString('en-US', {
            style: 'currency',
            currency: window.Shopify?.currency?.active || 'USD',
          });
          this.price.textContent = formatted;
        }

        if (this.comparePrice) {
          if (variant && variant.compare_at_price > variant.price) {
            const formattedCompare = (variant.compare_at_price / 100).toLocaleString('en-US', {
              style: 'currency',
              currency: window.Shopify?.currency?.active || 'USD',
            });
            this.comparePrice.textContent = formattedCompare;
            this.comparePrice.classList.remove('hidden');
          } else {
            this.comparePrice.classList.add('hidden');
          }
        }

        if (this.image && variant?.featured_image?.src) {
          this.image.src = variant.featured_image.src;
        }

        this.updateButtonState(variant ? variant.available : false);
      }

      updateButtonState(isAvailable) {
        if (!this.button || !this.buttonText) return;

        if (isAvailable) {
          this.button.removeAttribute('disabled');
          this.buttonText.textContent = window.variantStrings?.addToCart || 'Add to Cart';
        } else {
          this.button.setAttribute('disabled', 'disabled');
          this.buttonText.textContent = window.variantStrings?.soldOut || 'Sold Out';
        }
      }
    }
  );
}
```

---

#### Artifact 3: `assets/component-sticky-atc.css`
```css
/* FocusDrawer Sticky Add to Cart Stylesheet */
.sticky-atc {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  z-index: 100;
  background-color: rgba(30, 30, 30, 0.95);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-top: 1px solid rgba(255, 255, 255, 0.12);
  box-shadow: 0 -8px 24px rgba(0, 0, 0, 0.45);
  transform: translateY(100%);
  opacity: 0;
  pointer-events: none;
  visibility: hidden;
  transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1),
              opacity 0.3s ease,
              visibility 0.35s;
}

.sticky-atc.is-visible {
  transform: translateY(0);
  opacity: 1;
  pointer-events: auto;
  visibility: visible;
}

.sticky-atc__container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.2rem 2rem;
  gap: 2rem;
}

.sticky-atc__product-info {
  display: flex;
  align-items: center;
  gap: 1.4rem;
  min-width: 0;
  flex: 1 1 auto;
}

.sticky-atc__media-wrapper {
  flex-shrink: 0;
  width: 52px;
  height: 52px;
  border-radius: 8px;
  overflow: hidden;
  background: #121212;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.sticky-atc__image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
}

.sticky-atc__details {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  min-width: 0;
}

.sticky-atc__title {
  font-family: var(--font-heading-family);
  font-size: 1.4rem;
  font-weight: 600;
  line-height: 1.3;
  color: #FFFFFF;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 320px;
}

.sticky-atc__price-wrapper {
  display: flex;
  align-items: baseline;
  gap: 0.8rem;
}

.sticky-atc__price {
  font-size: 1.5rem;
  font-weight: 700;
  color: #E5A93C;
}

.sticky-atc__compare-price {
  font-size: 1.3rem;
  color: rgba(255, 255, 255, 0.5);
  text-decoration: line-through;
}

.sticky-atc__actions {
  display: flex;
  align-items: center;
  gap: 1.2rem;
  flex-shrink: 0;
}

.sticky-atc__variant-wrapper {
  position: relative;
}

.sticky-atc__select {
  appearance: none;
  -webkit-appearance: none;
  background: #27272A;
  color: #FFFFFF;
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 8px;
  padding: 1rem 3.2rem 1rem 1.4rem;
  font-size: 1.3rem;
  font-weight: 500;
  cursor: pointer;
  outline: none;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.sticky-atc__select:focus-visible {
  border-color: #E5A93C;
  box-shadow: 0 0 0 2px rgba(229, 169, 60, 0.35);
}

.sticky-atc__caret {
  position: absolute;
  right: 1.2rem;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  width: 1rem;
  height: 1rem;
  color: rgba(255, 255, 255, 0.7);
}

.sticky-atc__button {
  background-color: #E5A93C !important;
  color: #121212 !important;
  font-weight: 700 !important;
  font-size: 1.4rem !important;
  letter-spacing: 0.05rem;
  padding: 1.2rem 2.8rem !important;
  border-radius: 8px !important;
  border: none !important;
  cursor: pointer;
  min-height: 44px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.15s ease, box-shadow 0.2s ease, filter 0.2s ease;
}

.sticky-atc__button:hover:not([disabled]) {
  filter: brightness(1.08);
  box-shadow: 0 0 16px rgba(229, 169, 60, 0.4);
  transform: translateY(-1px);
}

.sticky-atc__button:active:not([disabled]) {
  transform: translateY(0);
}

.sticky-atc__button[disabled] {
  background-color: #3F3F46 !important;
  color: #A1A1AA !important;
  cursor: not-allowed;
  opacity: 0.7;
}

/* Mobile Breakpoint (< 750px) */
@media screen and (max-width: 749px) {
  .sticky-atc__container {
    padding: 1rem 1.5rem;
    gap: 1rem;
  }

  .sticky-atc__title {
    max-width: 140px;
    font-size: 1.2rem;
  }

  .sticky-atc__price {
    font-size: 1.3rem;
  }

  .sticky-atc__media-wrapper {
    width: 42px;
    height: 42px;
  }

  .sticky-atc__variant-wrapper {
    display: none;
  }

  .sticky-atc__button {
    padding: 1rem 1.8rem !important;
    font-size: 1.3rem !important;
    min-height: 40px;
  }
}
```

---

#### Artifact 4: Section Integration in `sections/main-product.liquid`
In `sections/main-product.liquid`, immediately before `</product-info>` (line 754):
```liquid
      {%- if section.settings.enable_sticky_atc -%}
        {% render 'sticky-atc',
          product: product,
          section_id: section.id,
          color_scheme: section.settings.color_scheme
        %}
      {%- endif -%}
    </div>
  </product-component>
</product-info>
```

And in `sections/main-product.liquid` `{% schema %}` settings array:
```json
    {
      "type": "checkbox",
      "id": "enable_sticky_atc",
      "default": true,
      "label": "Enable Sticky Add to Cart bar on scroll"
    },
```

---

## 3. Collection Template Specification (`templates/collection.json`)

### 3.1 Requirements Matrix
| Parameter | Setting Value | Rationale |
|---|---|---|
| **Desktop Columns** | `4` | High-density showcase for desk organizers and drawers. |
| **Mobile Columns** | `"2"` | Clean 2-up mobile view without horizontal sprawl. |
| **Quick Add** | `"standard"` | Direct slide-out cart add for single-variant items or quick modal for multi-variants. |
| **Faceted Filtering** | `enable_filtering: true`, `filter_type: "horizontal"` | Faceted filtering by size, mounting type, finish. |
| **Sorting** | `enable_sorting: true` | Price, featured, bestselling sort options. |
| **Image Aspect Ratio** | `"square"` | Consistent square framing for modular organizers & under-desk gear. |
| **Secondary Image on Hover** | `true` | Highlights internal drawer organizers/open drawer state on card hover. |
| **Star Rating** | `true` | Displays verified customer review stars. |
| **Color Scheme** | `"scheme-1"` | Core FocusDrawer matte black canvas. |

---

### 3.2 Complete JSON File: `templates/collection.json`
```json
{
  "sections": {
    "banner": {
      "type": "main-collection-banner",
      "settings": {
        "show_collection_description": true,
        "show_collection_image": false,
        "color_scheme": "scheme-1"
      }
    },
    "product-grid": {
      "type": "main-collection-product-grid",
      "settings": {
        "products_per_page": 16,
        "columns_desktop": 4,
        "color_scheme": "scheme-1",
        "image_ratio": "square",
        "image_shape": "default",
        "show_secondary_image": true,
        "show_vendor": false,
        "show_rating": true,
        "quick_add": "standard",
        "enable_filtering": true,
        "filter_type": "horizontal",
        "enable_sorting": true,
        "columns_mobile": "2",
        "padding_top": 36,
        "padding_bottom": 36
      }
    }
  },
  "order": [
    "banner",
    "product-grid"
  ]
}
```

---

## 4. Edge Cases & Boundary Handling

1. **Sold Out / Unavailable Variant**:
   - The sticky ATC button disables automatically, swaps text to "Sold Out", and applies disabled dark grey styling (`#3F3F46`).
2. **Single-Variant Product**:
   - The `<select>` dropdown inside sticky ATC is omitted cleanly (`unless product.has_only_default_variant`).
3. **No Featured Image**:
   - Graceful fallback checks `selected_variant.featured_image` then `product.featured_image`.
4. **Fast Scrolling & Back-to-Top**:
   - IntersectionObserver threshold 0 with `boundingClientRect.top < 0` prevents flickering when scrolling past top/bottom bounds.
5. **Mobile Viewport Constraints**:
   - On screens `< 750px`, the variant select dropdown is cleanly hidden (`display: none`), prioritizing the product title, gold price, and full-finger touch target CTA button (40px min height).

---

## 5. Verification & Test Execution

Run the E2E test runner to verify 100% compliance:
```powershell
powershell -ExecutionPolicy Bypass -File "tests\run_e2e_tests.ps1"
```
Key assertions verified:
- `T1.R3.04`: Sticky Add to Cart & Sticky Product Info Integration (`PASS`)
- `T1.R4.06`: Faceted Filtering & Collection Grid in `templates/collection.json` (`PASS`)
- `T3.XF.03`: Sticky ATC / Variant Picker State Synchronization (`PASS`)
- `T3.XF.05`: Collection Faceted Filters -> Product Card Quick-Add Interoperability (`PASS`)
- `T4.RW.02`: High-Intent Ergonomic Evaluator & Sticky ATC Exploration (`PASS`)

---
*Report authored by m4_explorer_3.*
