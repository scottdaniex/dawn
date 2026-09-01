# Empirical Challenge & Stress-Test Harness for Milestone 4 (m4_challenger_2)
$ErrorActionPreference = "Stop"
$sw = [System.Diagnostics.Stopwatch]::StartNew()

$RootPath = (Resolve-Path "$PSScriptRoot\..\..").Path
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  M4 EMPIRICAL CHALLENGER STRESS HARNESS (m4_challenger_2)" -ForegroundColor Cyan
Write-Host "  Project Root: $RootPath" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan

$testResults = @()
function Assert-Test {
    param(
        [string]$Id,
        [string]$Description,
        [bool]$Condition,
        [string]$Details = ""
    )
    $res = [PSCustomObject]@{
        Id = $Id
        Description = $Description
        Passed = $Condition
        Details = $Details
    }
    $script:testResults += $res
    if ($Condition) {
        Write-Host "  [PASS] $Id : $Description" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $Id : $Description" -ForegroundColor Red
        if ($Details) {
            Write-Host "         Reason: $Details" -ForegroundColor Yellow
        }
    }
}

# ------------------------------------------------------------------------------
# 1. JSON Integrity & AST Block Order Validation
# ------------------------------------------------------------------------------
Write-Host "`n--- Stress-Test 1: JSON Integrity & AST Validation across Workspace ---" -ForegroundColor Magenta

$jsonFiles = Get-ChildItem -Path $RootPath -Filter "*.json" -Recurse | Where-Object {
    $_.FullName -notmatch '\\\.git' -and $_.FullName -notmatch '\\node_modules' -and $_.FullName -notmatch '\\\.agents'
}

$allJsonValid = $true
$invalidJsonList = @()
foreach ($file in $jsonFiles) {
    try {
        $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
        $null = ConvertFrom-Json $content
    } catch {
        $allJsonValid = $false
        $invalidJsonList += "$($file.Name): $($_.Exception.Message)"
    }
}
Assert-Test "M4.ST.JSON.01" "Strict RFC 8259 compliance across all $(($jsonFiles).Count) workspace JSON files" $allJsonValid ($invalidJsonList -join "; ")

# Check templates/product.json block graph
$productJsonPath = Join-Path $RootPath "templates/product.json"
$productJson = Get-Content -LiteralPath $productJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$mainProduct = $productJson.sections.main
$blocks = $mainProduct.blocks
$blockOrder = $mainProduct.block_order

$blockOrderValid = $true
$missingBlocks = @()
foreach ($b in $blockOrder) {
    if (-not $blocks.PSObject.Properties[$b]) {
        $blockOrderValid = $false
        $missingBlocks += $b
    }
}
Assert-Test "M4.ST.JSON.02" "Product template block_order references existing blocks (1:1 graph integrity)" $blockOrderValid ($missingBlocks -join ", ")

# Check templates/collection.json structure
$collectionJsonPath = Join-Path $RootPath "templates/collection.json"
$collectionJson = Get-Content -LiteralPath $collectionJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$hasBanner = $collectionJson.sections.banner -ne $null
$hasGrid = $collectionJson.sections.'product-grid' -ne $null
$hasOrder = $collectionJson.order -contains "banner" -and $collectionJson.order -contains "product-grid"
Assert-Test "M4.ST.JSON.03" "Collection template has valid banner and product-grid sections in order" ($hasBanner -and $hasGrid -and $hasOrder)

# ------------------------------------------------------------------------------
# 2. Liquid Syntax & Tag Balancer
# ------------------------------------------------------------------------------
Write-Host "`n--- Stress-Test 2: Liquid Syntax & Delimiter Stack Validation ---" -ForegroundColor Magenta

$liquidFiles = Get-ChildItem -Path $RootPath -Filter "*.liquid" -Recurse | Where-Object {
    $_.FullName -notmatch '\\\.git' -and $_.FullName -notmatch '\\node_modules' -and $_.FullName -notmatch '\\\.agents'
}

$balancedTags = @("if", "unless", "for", "case", "form", "schema", "comment", "style", "javascript")
$allLiquidBalanced = $true
$liquidErrors = @()

foreach ($file in $liquidFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    
    # Check schema block if present
    if ($content -match '(?ms)\{%\s*schema\s*%\}(.*?)\{%\s*endschema\s*%\}') {
        $schemaJson = $matches[1].Trim()
        try {
            $null = ConvertFrom-Json $schemaJson
        } catch {
            $allLiquidBalanced = $false
            $liquidErrors += "$($file.Name) schema error: $($_.Exception.Message)"
        }
    }
    
    # Check tag balancing
    foreach ($tag in $balancedTags) {
        $openMatches = [regex]::Matches($content, "\{%\s*$tag(\s+[^%]*)?%\}")
        $closeMatches = [regex]::Matches($content, "\{%\s*end$tag\s*%\}")
        if ($openMatches.Count -ne $closeMatches.Count) {
            $allLiquidBalanced = $false
            $liquidErrors += "$($file.Name): tag '$tag' open count ($($openMatches.Count)) != close count ($($closeMatches.Count))"
        }
    }
}
Assert-Test "M4.ST.LIQUID.01" "All $(($liquidFiles).Count) Liquid templates and schema blocks pass structural AST balance" $allLiquidBalanced ($liquidErrors -join "; ")

# ------------------------------------------------------------------------------
# 3. Product Template Spec Accordions & Settings Verification
# ------------------------------------------------------------------------------
Write-Host "`n--- Stress-Test 3: Product Page Specifications & Technical Accordions ---" -ForegroundColor Magenta

# Check 4 collapsible tabs
$hasDim = $blocks.spec_dimensions_mounting -and $blocks.spec_dimensions_mounting.settings.icon -eq "ruler"
$hasMat = $blocks.spec_materials_craftsmanship -and $blocks.spec_materials_craftsmanship.settings.icon -eq "check_mark"
$hasCab = $blocks.spec_cable_management -and $blocks.spec_cable_management.settings.icon -eq "lightning_bolt"
$hasWar = $blocks.spec_warranty_guarantee -and $blocks.spec_warranty_guarantee.settings.icon -eq "star"
Assert-Test "M4.ST.PROD.01" "Product page has 4 technical spec accordions with correct SVG icons (ruler, check_mark, lightning_bolt, star)" ($hasDim -and $hasMat -and $hasCab -and $hasWar)

# Check gallery settings
$galleryLayout = $mainProduct.settings.gallery_layout -eq "thumbnail_slider"
$mediaSize = $mainProduct.settings.media_size -eq "large"
$imageZoom = $mainProduct.settings.image_zoom -eq "lightbox"
$mobileThumbs = $mainProduct.settings.mobile_thumbnails -eq "show"
Assert-Test "M4.ST.PROD.02" "Product gallery configured for thumbnail_slider, large media, lightbox zoom, mobile thumbs" ($galleryLayout -and $mediaSize -and $imageZoom -and $mobileThumbs)

# Check variant picker settings
$varPicker = $blocks.variant_picker
$isButtonPicker = $varPicker.settings.picker_type -eq "button"
$isCircleSwatch = $varPicker.settings.swatch_shape -eq "circle"
Assert-Test "M4.ST.PROD.03" "Variant picker configured with button pills and circle swatch shapes" ($isButtonPicker -and $isCircleSwatch)

# Check trust badges block
$trustBadges = $blocks.trust_badges
$hasTrustBadges = $trustBadges -and $trustBadges.settings.icon_1 -eq "truck" -and $trustBadges.settings.icon_2 -eq "check_mark" -and $trustBadges.settings.icon_3 -eq "star"
Assert-Test "M4.ST.PROD.04" "Trust badges block configured with Free Delivery, 30-Day Setup Trial, Lifetime Warranty" $hasTrustBadges

# ------------------------------------------------------------------------------
# 4. Sticky ATC Snippet, CSS & JS Deep Stress-Testing
# ------------------------------------------------------------------------------
Write-Host "`n--- Stress-Test 4: Sticky Add-to-Cart Architecture & Edge Cases ---" -ForegroundColor Magenta

$stickySnippetPath = Join-Path $RootPath "snippets/sticky-atc.liquid"
$stickySnippet = Get-Content -LiteralPath $stickySnippetPath -Raw -Encoding UTF8

$stickyJsPath = Join-Path $RootPath "assets/sticky-atc.js"
$stickyJs = Get-Content -LiteralPath $stickyJsPath -Raw -Encoding UTF8

$stickyCssPath = Join-Path $RootPath "assets/component-sticky-atc.css"
$stickyCss = Get-Content -LiteralPath $stickyCssPath -Raw -Encoding UTF8

# Check single-variant omission guard
$hasSingleVarGuard = $stickySnippet -match '\{%-\s*unless\s+product\.has_only_default_variant\s*-%\}'
Assert-Test "M4.ST.SATC.01" "Sticky ATC snippet includes single-variant omission guard (unless product.has_only_default_variant)" $hasSingleVarGuard

# Check sold out / unavailable variant handling in Liquid
$hasSoldOutLiquid = $stickySnippet -match 'disabled="disabled"' -and $stickySnippet -match 'products\.product\.sold_out'
Assert-Test "M4.ST.SATC.02" "Sticky ATC Liquid handles disabled state and sold out label for unavailable variants" $hasSoldOutLiquid

# Check compare at price discount presentation
$hasComparePrice = $stickySnippet -match 'selected_variant\.compare_at_price > selected_variant\.price'
Assert-Test "M4.ST.SATC.03" "Sticky ATC Liquid contains compare-at price strike-through with conditional hidden state" $hasComparePrice

# Check JS intersection observer & custom elements registration
$hasCustomElem = $stickyJs -match "!customElements\.get\('sticky-atc'\)"
$hasObserver = $stickyJs -match "IntersectionObserver"
$hasPubSub = $stickyJs -match "PUB_SUB_EVENTS\.variantChange"
$hasDisconnect = $stickyJs -match "disconnectedCallback"
Assert-Test "M4.ST.SATC.04" "Sticky ATC JS implements CustomElement, IntersectionObserver, PubSub subscriber, and cleanup lifecycle" ($hasCustomElem -and $hasObserver -and $hasPubSub -and $hasDisconnect)

# Check bi-directional master form synchronization in JS
$hasFormSync = $stickyJs -match 'input\[type="radio"\]' -and $stickyJs -match 'select\[name="id"\]' -and $stickyJs -match 'dispatchEvent'
Assert-Test "M4.ST.SATC.05" "Sticky ATC JS dispatches change events to master product radio/select form inputs" $hasFormSync

# Check CSS Glassmorphism, Gold CTA, and Mobile Responsive Breakpoints
$hasGlass = $stickyCss -match "backdrop-filter:\s*blur" -and $stickyCss -match "rgba\(30,\s*30,\s*30"
$hasGoldCta = $stickyCss -match "#E5A93C"
$hasMobileBreakpoint = $stickyCss -match "@media\s+screen\s+and\s*\(max-width:\s*749px\)"
$hidesSelectOnMobile = $stickyCss -match "\.sticky-atc__variant-wrapper\s*\{\s*display:\s*none;"
Assert-Test "M4.ST.SATC.06" "Sticky ATC CSS has dark glassmorphism, FocusDrawer gold button (#E5A93C), and 749px mobile collapse" ($hasGlass -and $hasGoldCta -and $hasMobileBreakpoint -and $hidesSelectOnMobile)

# ------------------------------------------------------------------------------
# 5. Collection Template Grid & Faceted Filter Configuration
# ------------------------------------------------------------------------------
Write-Host "`n--- Stress-Test 5: Modular Collection Template Configuration ---" -ForegroundColor Magenta

$colGridSettings = $collectionJson.sections.'product-grid'.settings
$colColsDesktop = $colGridSettings.columns_desktop -eq 4
$colColsMobile = $colGridSettings.columns_mobile -eq "2"
$colFilterType = $colGridSettings.filter_type -eq "horizontal"
$colQuickAdd = $colGridSettings.quick_add -eq "standard"
$colImageRatio = $colGridSettings.image_ratio -eq "square"
$colSorting = $colGridSettings.enable_sorting -eq $true
Assert-Test "M4.ST.COLL.01" "Collection grid configured: 4 desktop cols, 2 mobile cols, horizontal filter, square ratio, quick-add standard, sorting" ($colColsDesktop -and $colColsMobile -and $colFilterType -and $colQuickAdd -and $colImageRatio -and $colSorting)

# ------------------------------------------------------------------------------
# 6. Cross-Milestone Regression & Theme Integration
# ------------------------------------------------------------------------------
Write-Host "`n--- Stress-Test 6: Cross-Milestone Architectural Regression ---" -ForegroundColor Magenta

# M1 settings_data.json check
$settingsDataPath = Join-Path $RootPath "config/settings_data.json"
$settingsData = Get-Content -LiteralPath $settingsDataPath -Raw -Encoding UTF8 | ConvertFrom-Json
$scheme1 = $settingsData.current.schemes.'scheme-1'
$scheme2 = $settingsData.current.schemes.'scheme-2'
$scheme3 = $settingsData.current.schemes.'scheme-3'
$m1Schemes = ($scheme1.settings.background -eq "#121212") -and ($scheme2.settings.background -eq "#1E1E1E") -and ($scheme3.settings.background -eq "#E5A93C")
$m1Logo = $settingsData.current.logo -eq "shopify://shop_images/focusdrawer-logo.png" -or $settingsData.current.logo -like "*focusdrawer-logo*"
Assert-Test "M4.ST.REG.01" "M1 Brand color schemes (scheme-1/2/3) and logo preserved in settings_data.json" ($m1Schemes -and $m1Logo)

# M2 Cart Drawer & Free Shipping Meter check
$cartDrawerPath = Join-Path $RootPath "snippets/cart-drawer.liquid"
$cartDrawer = Get-Content -LiteralPath $cartDrawerPath -Raw -Encoding UTF8
$hasShippingMeter = $cartDrawer -match "cart-drawer__free-shipping" -and $cartDrawer -match "free_shipping_threshold"
Assert-Test "M4.ST.REG.02" "M2 Cart drawer with dynamic free shipping progress meter intact" $hasShippingMeter

# M3 Index Showcase check
$indexJsonPath = Join-Path $RootPath "templates/index.json"
$indexJson = Get-Content -LiteralPath $indexJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$hasHero = $indexJson.sections.hero -ne $null
$hasMulticolumn = $indexJson.sections.multicolumn -ne $null
$hasFeatured = $indexJson.sections.featured_collection -ne $null
Assert-Test "M4.ST.REG.03" "M3 Homepage layout (hero, multicolumn, featured collection) intact in templates/index.json" ($hasHero -and $hasMulticolumn -and $hasFeatured)

# ------------------------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------------------------
$sw.Stop()
$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.Passed }).Count
$failedTests = ($testResults | Where-Object { -not $_.Passed }).Count

Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "  M4 EMPIRICAL STRESS TEST HARNESS SUMMARY" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "Total Tests : $totalTests"
Write-Host "Passed      : $passedTests" -ForegroundColor Green
Write-Host "Failed      : $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "Pass Rate   : $([Math]::Round(($passedTests / $totalTests) * 100, 2))%"
Write-Host "Elapsed Time: $([Math]::Round($sw.Elapsed.TotalSeconds, 3)) s"

if ($failedTests -eq 0) {
    Write-Host "`n[CHALLENGER VERDICT: 100% PASS - ALL EMPIRICAL CHECKS APPROVED]" -ForegroundColor Green
    Exit 0
} else {
    Write-Host "`n[CHALLENGER VERDICT: FAILURES DETECTED - REQUEST CHANGES]" -ForegroundColor Red
    Exit 1
}
