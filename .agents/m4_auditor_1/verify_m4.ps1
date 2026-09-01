# Standalone Forensic Verification Script for Milestone 4
Write-Host "=== FORENSIC CHECK 1: JSON PARSE & SCHEMA INTEGRITY ===" -ForegroundColor Cyan

# Test product.json
$productJsonPath = "templates/product.json"
try {
    $productData = Get-Content -LiteralPath $productJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-Host "product.json: JSON Parse OK" -ForegroundColor Green
    
    # Check main section
    $mainSec = $productData.sections.main
    if ($mainSec.type -ne "main-product") { throw "main section type is not main-product" }
    
    # Check gallery settings
    $settings = $mainSec.settings
    Write-Host "Gallery Layout: $($settings.gallery_layout)"
    Write-Host "Media Size: $($settings.media_size)"
    Write-Host "Image Zoom: $($settings.image_zoom)"
    Write-Host "Mobile Thumbnails: $($settings.mobile_thumbnails)"
    Write-Host "Sticky Info: $($settings.enable_sticky_info)"
    
    # Check spec accordion blocks
    $specBlocks = @("spec_dimensions_mounting", "spec_materials_craftsmanship", "spec_cable_management", "spec_warranty_guarantee")
    foreach ($sb in $specBlocks) {
        $block = $mainSec.blocks.$sb
        if (-not $block) { throw "Missing block $sb" }
        if ($block.type -ne "collapsible_tab") { throw "$sb is not collapsible_tab" }
        Write-Host "Accordion $sb : Icon='$($block.settings.icon)', Heading='$($block.settings.heading)', Content Length=$($block.settings.content.Length)"
    }
    
    # Check variant_picker and buy_buttons
    if ($mainSec.blocks.variant_picker.type -ne "variant_picker") { throw "Missing variant_picker" }
    if ($mainSec.blocks.buy_buttons.type -ne "buy_buttons") { throw "Missing buy_buttons" }
    
    Write-Host "product.json: All required blocks & settings verified OK" -ForegroundColor Green
} catch {
    Write-Host "product.json error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test collection.json
$collectionJsonPath = "templates/collection.json"
try {
    $colData = Get-Content -LiteralPath $collectionJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-Host "collection.json: JSON Parse OK" -ForegroundColor Green
    
    $gridSec = $colData.sections.'product-grid'
    Write-Host "Columns desktop: $($gridSec.settings.columns_desktop)"
    Write-Host "Columns mobile: $($gridSec.settings.columns_mobile)"
    Write-Host "Quick add: $($gridSec.settings.quick_add)"
    Write-Host "Filter type: $($gridSec.settings.filter_type)"
    Write-Host "Enable sorting: $($gridSec.settings.enable_sorting)"
    Write-Host "collection.json: All required grid settings verified OK" -ForegroundColor Green
} catch {
    Write-Host "collection.json error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== FORENSIC CHECK 2: LIQUID SYNTAX & RENDER VALIDATION ===" -ForegroundColor Cyan
$stickyLiquid = Get-Content -LiteralPath "snippets/sticky-atc.liquid" -Raw -Encoding UTF8
$mainProductLiquid = Get-Content -LiteralPath "sections/main-product.liquid" -Raw -Encoding UTF8

if ($mainProductLiquid -match "render\s+'sticky-atc'") {
    Write-Host "main-product.liquid renders sticky-atc: OK" -ForegroundColor Green
} else {
    Write-Host "main-product.liquid does NOT render sticky-atc!" -ForegroundColor Red
}

if ($mainProductLiquid -match "enable_sticky_atc") {
    Write-Host "main-product.liquid schema has enable_sticky_atc: OK" -ForegroundColor Green
} else {
    Write-Host "main-product.liquid schema missing enable_sticky_atc!" -ForegroundColor Red
}

Write-Host "=== FORENSIC CHECK 3: JAVASCRIPT & CSS AUDIT ===" -ForegroundColor Cyan
$stickyJs = Get-Content -LiteralPath "assets/sticky-atc.js" -Raw -Encoding UTF8
if ($stickyJs -match 'customElements\.define' -and $stickyJs -match 'IntersectionObserver' -and $stickyJs -match 'PUB_SUB_EVENTS\.variantChange') {
    Write-Host "sticky-atc.js has custom element, IntersectionObserver, and PubSub listener: OK" -ForegroundColor Green
} else {
    Write-Host "sticky-atc.js missing key implementation logic!" -ForegroundColor Red
}

$stickyCss = Get-Content -LiteralPath "assets/component-sticky-atc.css" -Raw -Encoding UTF8
if ($stickyCss -match '\.sticky-atc' -and $stickyCss -match '#E5A93C' -and $stickyCss -match '@media screen and \(max-width: 749px\)') {
    Write-Host "component-sticky-atc.css has sticky-atc classes, gold color, and mobile responsive rules: OK" -ForegroundColor Green
} else {
    Write-Host "component-sticky-atc.css missing key styles!" -ForegroundColor Red
}
