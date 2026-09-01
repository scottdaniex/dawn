# Adversarial Review Script for Milestone 4
$ErrorActionPreference = "Stop"

Write-Host "=== RUNNING IN-DEPTH ADVERSARIAL VALIDATION FOR MILESTONE 4 ===" -ForegroundColor Cyan

# 1. Product Template Object Graph & Schema Checks
$productPath = "templates/product.json"
if (-not (Test-Path $productPath)) {
    throw "templates/product.json not found"
}
$productRaw = [System.IO.File]::ReadAllText((Resolve-Path $productPath), [System.Text.Encoding]::UTF8)
$productJson = $productRaw | ConvertFrom-Json

$mainSection = $productJson.sections.main
if ($null -eq $mainSection) {
    throw "Product main section is missing in templates/product.json"
}
if ($mainSection.type -ne "main-product") {
    throw "Product main section type is $($mainSection.type) (expected 'main-product')"
}

Write-Host "`n1. Checking Product Section Settings:" -ForegroundColor Yellow
$settings = $mainSection.settings
$galleryLayout = $settings.gallery_layout
$mediaSize = $settings.media_size
$mobileThumbnails = $settings.mobile_thumbnails
$imageZoom = $settings.image_zoom
$stickyInfo = $settings.enable_sticky_info
$constrain = $settings.constrain_to_viewport
$mediaFit = $settings.media_fit

Write-Host "   - gallery_layout: $galleryLayout"
Write-Host "   - media_size: $mediaSize"
Write-Host "   - mobile_thumbnails: $mobileThumbnails"
Write-Host "   - image_zoom: $imageZoom"
Write-Host "   - enable_sticky_info: $stickyInfo"
Write-Host "   - constrain_to_viewport: $constrain"
Write-Host "   - media_fit: $mediaFit"

if ($galleryLayout -ne "thumbnail_slider") { throw "gallery_layout is not 'thumbnail_slider'" }
if ($mediaSize -ne "large") { throw "media_size is not 'large'" }
if ($mobileThumbnails -ne "show") { throw "mobile_thumbnails is not 'show'" }
if ($imageZoom -ne "lightbox") { throw "image_zoom is not 'lightbox'" }

Write-Host "`n2. Checking Product Blocks:" -ForegroundColor Yellow
$blocks = $mainSection.blocks
$blockOrder = $mainSection.block_order

$requiredBlocks = @(
    @{ Id = "vendor"; Type = "text" },
    @{ Id = "title"; Type = "title" },
    @{ Id = "price"; Type = "price" },
    @{ Id = "benefit_note"; Type = "text" },
    @{ Id = "variant_picker"; Type = "variant_picker" },
    @{ Id = "quantity_selector"; Type = "quantity_selector" },
    @{ Id = "buy_buttons"; Type = "buy_buttons" },
    @{ Id = "trust_badges"; Type = "icon-with-text" },
    @{ Id = "description"; Type = "description" },
    @{ Id = "spec_dimensions_mounting"; Type = "collapsible_tab"; Icon = "ruler" },
    @{ Id = "spec_materials_craftsmanship"; Type = "collapsible_tab"; Icon = "check_mark" },
    @{ Id = "spec_cable_management"; Type = "collapsible_tab"; Icon = "lightning_bolt" },
    @{ Id = "spec_warranty_guarantee"; Type = "collapsible_tab"; Icon = "star" },
    @{ Id = "reviews_placeholder"; Type = "custom_liquid" },
    @{ Id = "share"; Type = "share" }
)

foreach ($rb in $requiredBlocks) {
    $bId = $rb.Id
    $blockObj = $blocks.$bId
    if ($null -eq $blockObj) {
        throw "Required block '$bId' is missing in main-product blocks"
    }
    if ($blockObj.type -ne $rb.Type) {
        throw "Block '$bId' has type '$($blockObj.type)' (expected '$($rb.Type)')"
    }
    if ($rb.Icon -and $blockObj.settings.icon -ne $rb.Icon) {
        throw "Block '$bId' has icon '$($blockObj.settings.icon)' (expected '$($rb.Icon)')"
    }
    if (-not ($blockOrder -contains $bId)) {
        throw "Block '$bId' is missing in block_order list"
    }
    Write-Host "   [PASS] Block '$bId' (type: $($rb.Type)$(if($rb.Icon){", icon: " + $rb.Icon})) verified in blocks & block_order"
}

# Check Variant Picker settings
$vpSettings = $blocks.variant_picker.settings
if ($vpSettings.picker_type -ne "button") {
    throw "variant_picker picker_type is '$($vpSettings.picker_type)' (expected 'button')"
}
if ($vpSettings.swatch_shape -ne "circle") {
    throw "variant_picker swatch_shape is '$($vpSettings.swatch_shape)' (expected 'circle')"
}
Write-Host "   [PASS] variant_picker pills and circle swatches verified"

# Check Trust Badges settings
$tbSettings = $blocks.trust_badges.settings
if ($tbSettings.icon_1 -ne "truck" -or $tbSettings.icon_2 -ne "check_mark" -or $tbSettings.icon_3 -ne "star") {
    throw "trust_badges icons mismatch"
}
Write-Host "   [PASS] trust_badges 3-item icons (truck, check_mark, star) verified"

Write-Host "`n3. Checking Collection Template (templates/collection.json):" -ForegroundColor Yellow
$colPath = "templates/collection.json"
$colRaw = [System.IO.File]::ReadAllText((Resolve-Path $colPath), [System.Text.Encoding]::UTF8)
$colJson = $colRaw | ConvertFrom-Json
$gridSettings = $colJson.sections.'product-grid'.settings

if ($gridSettings.columns_desktop -ne 4) { throw "columns_desktop is not 4" }
if ($gridSettings.columns_mobile -ne "2" -and $gridSettings.columns_mobile -ne 2) { throw "columns_mobile is not 2" }
if ($gridSettings.filter_type -ne "horizontal") { throw "filter_type is not 'horizontal'" }
if ($gridSettings.quick_add -ne "standard") { throw "quick_add is not 'standard'" }
if ($gridSettings.enable_sorting -ne $true) { throw "enable_sorting is not true" }
if ($gridSettings.image_ratio -ne "square") { throw "image_ratio is not 'square'" }
Write-Host "   [PASS] collection.json grid, filters (horizontal), sorting, quick_add, and square ratio verified"

Write-Host "`n4. Checking main-product.liquid Schema & Snippet Integration:" -ForegroundColor Yellow
$mpPath = "sections/main-product.liquid"
$mpRaw = [System.IO.File]::ReadAllText((Resolve-Path $mpPath), [System.Text.Encoding]::UTF8)
$schemaMatch = [regex]::Match($mpRaw, '(?s)\{%-?\s*schema\s*-?%\}(.*?)\{%-?\s*endschema\s*-?%\}')
$mpSchema = $schemaMatch.Groups[1].Value | ConvertFrom-Json
$hasEnableStickyAtc = $false
foreach ($s in $mpSchema.settings) {
    if ($s.id -eq "enable_sticky_atc") {
        $hasEnableStickyAtc = $true
        Write-Host "   [PASS] Schema setting 'enable_sticky_atc' found (type: $($s.type), default: $($s.default))"
        break
    }
}
if (-not $hasEnableStickyAtc) {
    throw "main-product.liquid schema does not contain 'enable_sticky_atc' setting"
}

$renderStickyMatch = $mpRaw -match "render\s+'sticky-atc'"
if (-not $renderStickyMatch) {
    throw "main-product.liquid does not render 'sticky-atc' snippet"
}
Write-Host "   [PASS] main-product.liquid renders 'sticky-atc' snippet conditionally"

Write-Host "`n5. Checking sticky-atc.liquid snippet:" -ForegroundColor Yellow
$snippetPath = "snippets/sticky-atc.liquid"
$snippetRaw = [System.IO.File]::ReadAllText((Resolve-Path $snippetPath), [System.Text.Encoding]::UTF8)
if (-not ($snippetRaw -match "<sticky-atc")) { throw "sticky-atc.liquid missing <sticky-atc> custom element" }
if (-not ($snippetRaw -match "StickyATCSelect-")) { throw "sticky-atc.liquid missing variant select dropdown" }
if (-not ($snippetRaw -match "StickyATCButton-")) { throw "sticky-atc.liquid missing ATC button" }
if (-not ($snippetRaw -match "StickyATCPrice-")) { throw "sticky-atc.liquid missing price container" }
if (-not ($snippetRaw -match "component-sticky-atc\.css")) { throw "sticky-atc.liquid does not link component-sticky-atc.css" }
if (-not ($snippetRaw -match "sticky-atc\.js")) { throw "sticky-atc.liquid does not link sticky-atc.js" }
Write-Host "   [PASS] sticky-atc.liquid tags, selectors, bindings, and assets verified"

Write-Host "`n6. Checking sticky-atc.js web component implementation:" -ForegroundColor Yellow
$jsPath = "assets/sticky-atc.js"
$jsRaw = [System.IO.File]::ReadAllText((Resolve-Path $jsPath), [System.Text.Encoding]::UTF8)
if (-not ($jsRaw -match "customElements\.define\s*\(\s*['""]sticky-atc['""]")) { throw "sticky-atc.js does not define 'sticky-atc' element" }
if (-not ($jsRaw -match "IntersectionObserver")) { throw "sticky-atc.js does not use IntersectionObserver" }
if (-not ($jsRaw -match "PUB_SUB_EVENTS\.variantChange|variantChange")) { throw "sticky-atc.js does not listen to variantChange pubsub event" }
if (-not ($jsRaw -match "onButtonClick")) { throw "sticky-atc.js missing onButtonClick handler" }
if (-not ($jsRaw -match "onSelectChange")) { throw "sticky-atc.js missing onSelectChange handler" }
if (-not ($jsRaw -match "disconnectedCallback")) { throw "sticky-atc.js missing disconnectedCallback cleanup" }
Write-Host "   [PASS] sticky-atc.js IntersectionObserver, PubSub subscription, handlers, and cleanup verified"

Write-Host "`n7. Checking CSS styling for sticky ATC and main product:" -ForegroundColor Yellow
$cssPath = "assets/component-sticky-atc.css"
$cssRaw = [System.IO.File]::ReadAllText((Resolve-Path $cssPath), [System.Text.Encoding]::UTF8)
if (-not ($cssRaw -match "#E5A93C")) { throw "component-sticky-atc.css missing FocusDrawer gold accent #E5A93C" }
if (-not ($cssRaw -match "position:\s*fixed")) { throw "component-sticky-atc.css missing position: fixed" }
if (-not ($cssRaw -match "transform:\s*translateY")) { throw "component-sticky-atc.css missing translateY transition" }
if (-not ($cssRaw -match "@media.*max-width:\s*749px")) { throw "component-sticky-atc.css missing mobile responsive media query" }
Write-Host "   [PASS] component-sticky-atc.css gold button #E5A93C, fixed positioning, and mobile responsive rules verified"

Write-Host "`n=== ALL ADVERSARIAL MILESTONE 4 CHECKS PASSED CLEANLY! ===" -ForegroundColor Green
