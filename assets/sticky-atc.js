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

        const productInfo = document.getElementById(`MainProduct-${this.sectionId}`) || document.getElementById(`ProductInfo-${this.sectionId}`);
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
