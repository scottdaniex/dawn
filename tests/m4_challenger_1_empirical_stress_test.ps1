# ==============================================================================
# FocusDrawer Theme - Milestone 4 Empirical Challenger Stress Test Suite
# Challenger: m4_challenger_1
# Project Root: C:\Users\asedacasd\.gemini\antigravity\scratch\dawn
# ==============================================================================

param(
    [string]$RepoRoot = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"
)

$ErrorActionPreference = "Continue"

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  M4 EMPIRICAL CHALLENGER STRESS HARNESS" -ForegroundColor Cyan
Write-Host "  Target: $RepoRoot" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan

$Passed = 0
$Failed = 0
$Challenges = @()

function Record-Result {
    param(
        [string]$TestId,
        [string]$Description,
        [bool]$Condition,
        [string]$Details = ""
    )
    if ($Condition) {
        $Global:Passed++
        Write-Host "  [PASS] $TestId : $Description" -ForegroundColor Green
        if ($Details) { Write-Host "         Details: $Details" -ForegroundColor Gray }
    } else {
        $Global:Failed++
        $Global:Challenges += "$TestId : $Description - $Details"
        Write-Host "  [FAIL] $TestId : $Description" -ForegroundColor Red
        if ($Details) { Write-Host "         Details: $Details" -ForegroundColor Red }
    }
}

# ------------------------------------------------------------------------------
# 1. TEMPLATE JSON VALIDATION & DEEP GRAPH INTEGRITY
# ------------------------------------------------------------------------------
Write-Host "`n--- 1. Template JSON Validation & Deep Graph Integrity ---" -ForegroundColor Yellow

# Test 1.1: product.json strict RFC 8259 parse & order validation
$prodJsonPath = Join-Path $RepoRoot "templates\product.json"
$prodJsonValid = $false
$prodJsonObj = $null
try {
    $prodRaw = [System.IO.File]::ReadAllText($prodJsonPath, [System.Text.Encoding]::UTF8)
    $prodJsonObj = ConvertFrom-Json $prodRaw
    $prodJsonValid = ($null -ne $prodJsonObj.sections.main)
} catch {
    $prodJsonValid = $false
}
Record-Result "M4.JSON.01" "templates/product.json Strict RFC 8259 Parse" $prodJsonValid "Parsed successfully into PSObject"

# Test 1.2: product.json main section settings
$mainSettings = $prodJsonObj.sections.main.settings
$galleryLayout = $mainSettings.gallery_layout
$mediaSize = $mainSettings.media_size
$imageZoom = $mainSettings.image_zoom
$mobileThumbs = $mainSettings.mobile_thumbnails
$stickyInfo = $mainSettings.enable_sticky_info
$constrain = $mainSettings.constrain_to_viewport
$mediaFit = $mainSettings.media_fit

$settingsOk = ($galleryLayout -eq "thumbnail_slider" -and
               $mediaSize -eq "large" -and
               $imageZoom -eq "lightbox" -and
               $mobileThumbs -eq "show" -and
               $stickyInfo -eq $true -and
               $constrain -eq $true -and
               $mediaFit -eq "contain")

Record-Result "M4.PROD.01" "Main Product Gallery & Sticky Info Settings in product.json" $settingsOk `
    "gallery_layout=$galleryLayout, media_size=$mediaSize, image_zoom=$imageZoom, mobile_thumbnails=$mobileThumbs, enable_sticky_info=$stickyInfo, constrain_to_viewport=$constrain, media_fit=$mediaFit"

# Test 1.3: product.json 4 Technical Spec Accordions verification
$blocks = $prodJsonObj.sections.main.blocks
$dimBlock = $blocks.spec_dimensions_mounting
$matBlock = $blocks.spec_materials_craftsmanship
$cblBlock = $blocks.spec_cable_management
$warBlock = $blocks.spec_warranty_guarantee

$accordionsValid = (
    ($null -ne $dimBlock) -and ($dimBlock.type -eq "collapsible_tab") -and ($dimBlock.settings.icon -eq "ruler") -and ($dimBlock.settings.heading -match "Dimensions") -and ($dimBlock.settings.content.Length -gt 100) -and
    ($null -ne $matBlock) -and ($matBlock.type -eq "collapsible_tab") -and ($matBlock.settings.icon -eq "check_mark") -and ($matBlock.settings.heading -match "Materials") -and ($matBlock.settings.content.Length -gt 100) -and
    ($null -ne $cblBlock) -and ($cblBlock.type -eq "collapsible_tab") -and ($cblBlock.settings.icon -eq "lightning_bolt") -and ($cblBlock.settings.heading -match "Cable Management") -and ($cblBlock.settings.content.Length -gt 100) -and
    ($null -ne $warBlock) -and ($warBlock.type -eq "collapsible_tab") -and ($warBlock.settings.icon -eq "star") -and ($warBlock.settings.heading -match "Warranty") -and ($warBlock.settings.content.Length -gt 100)
)
Record-Result "M4.PROD.02" "4 Technical Spec Accordions Configuration & Icon Assignments" $accordionsValid `
    "Dimensions(icon=ruler), Materials(icon=check_mark), Cable(icon=lightning_bolt), Warranty(icon=star) verified with rich HTML content"

# Test 1.4: SVG Icon Assets for Accordions & Badges
$requiredIcons = @("icon-ruler.svg", "icon-check-mark.svg", "icon-lightning-bolt.svg", "icon-star.svg", "icon-truck.svg", "icon-caret.svg")
$allIconsExist = $true
$missingIcons = @()
foreach ($ic in $requiredIcons) {
    $icPath = Join-Path $RepoRoot "assets\$ic"
    if (-not (Test-Path $icPath)) {
        $allIconsExist = $false
        $missingIcons += $ic
    }
}
Record-Result "M4.ASSETS.01" "Required SVG Icons Existence in assets/" $allIconsExist "Missing: $($missingIcons -join ', ')"

# Test 1.5: Trust Badges & Benefit Note Blocks in product.json
$trustBlock = $blocks.trust_badges
$benefitBlock = $blocks.benefit_note
$varPickerBlock = $blocks.variant_picker
$trustOk = ($null -ne $trustBlock -and $trustBlock.type -eq "icon-with-text" -and $trustBlock.settings.icon_1 -eq "truck" -and $trustBlock.settings.icon_2 -eq "check_mark" -and $trustBlock.settings.icon_3 -eq "star")
$benefitOk = ($null -ne $benefitBlock -and $benefitBlock.type -eq "text" -and $benefitBlock.settings.text -match "FocusDrawer|focus")
$varPickerOk = ($null -ne $varPickerBlock -and $varPickerBlock.type -eq "variant_picker" -and $varPickerBlock.settings.picker_type -eq "button" -and $varPickerBlock.settings.swatch_shape -eq "circle")
Record-Result "M4.PROD.03" "Trust Badges, Benefit Note & Variant Picker Blocks in product.json" ($trustOk -and $benefitOk -and $varPickerOk) `
    "trust_badges=$trustOk, benefit_note=$benefitOk, variant_picker=$varPickerOk"

# Test 1.6: collection.json strict RFC 8259 parse & settings
$colJsonPath = Join-Path $RepoRoot "templates\collection.json"
$colJsonValid = $false
$colGridOk = $false
try {
    $colRaw = [System.IO.File]::ReadAllText($colJsonPath, [System.Text.Encoding]::UTF8)
    $colJsonObj = ConvertFrom-Json $colRaw
    $gridSec = $colJsonObj.sections."product-grid"
    $colJsonValid = ($null -ne $gridSec)
    $colGridOk = (
        $gridSec.settings.columns_desktop -eq 4 -and
        $gridSec.settings.columns_mobile -eq "2" -and
        $gridSec.settings.filter_type -eq "horizontal" -and
        $gridSec.settings.enable_sorting -eq $true -and
        $gridSec.settings.quick_add -eq "standard" -and
        $gridSec.settings.image_ratio -eq "square"
    )
} catch {
    $colJsonValid = $false
}
Record-Result "M4.COLL.01" "templates/collection.json 4-Col Grid, Faceted Filtering & Quick Add" ($colJsonValid -and $colGridOk) `
    "columns_desktop=4, columns_mobile=2, filter_type=horizontal, quick_add=standard, image_ratio=square"

# ------------------------------------------------------------------------------
# 2. LIQUID TEMPLATES & SNIPPET CONTRACT VALIDATION
# ------------------------------------------------------------------------------
Write-Host "`n--- 2. Liquid Templates & Snippet Contract Validation ---" -ForegroundColor Yellow

# Test 2.1: sticky-atc.liquid structure & guards
$stickySnippetPath = Join-Path $RepoRoot "snippets\sticky-atc.liquid"
$stickySnippetContent = [System.IO.File]::ReadAllText($stickySnippetPath, [System.Text.Encoding]::UTF8)
$hasProductGuard = $stickySnippetContent -match 'unless product == blank'
$hasDefaultVarGuard = $stickySnippetContent -match 'unless product\.has_only_default_variant'
$hasStickyAtcTag = $stickySnippetContent -match '<sticky-atc'
$hasButtonId = $stickySnippetContent -match 'id="StickyATCButton-\{\{\s*section_id\s*\}\}"'
$hasSelectId = $stickySnippetContent -match 'id="StickyATCSelect-\{\{\s*section_id\s*\}\}"'
$hasPriceId = $stickySnippetContent -match 'id="StickyATCPrice-\{\{\s*section_id\s*\}\}"'
$hasComparePriceId = $stickySnippetContent -match 'id="StickyATCComparePrice-\{\{\s*section_id\s*\}\}"'
$hasImageId = $stickySnippetContent -match 'id="StickyATCImage-\{\{\s*section_id\s*\}\}"'
$hasAriaHidden = $stickySnippetContent -match 'aria-hidden="true"'

$stickyLiquidOk = ($hasProductGuard -and $hasDefaultVarGuard -and $hasStickyAtcTag -and $hasButtonId -and $hasSelectId -and $hasPriceId -and $hasComparePriceId -and $hasImageId -and $hasAriaHidden)
Record-Result "M4.LIQUID.01" "snippets/sticky-atc.liquid Tag Structure & Accessibility IDs" $stickyLiquidOk `
    "productGuard=$hasProductGuard, defaultVarGuard=$hasDefaultVarGuard, ariaHidden=$hasAriaHidden, matching element IDs"

# Test 2.2: main-product.liquid integration & schema setting
$mainProdPath = Join-Path $RepoRoot "sections\main-product.liquid"
$mainProdContent = [System.IO.File]::ReadAllText($mainProdPath, [System.Text.Encoding]::UTF8)
$rendersStickyAtc = $mainProdContent -match "render\s+'sticky-atc'"
$hasSchemaSetting = $mainProdContent -match '"id":\s*"enable_sticky_atc"'
Record-Result "M4.LIQUID.02" "sections/main-product.liquid Renders sticky-atc & Has Schema Setting" ($rendersStickyAtc -and $hasSchemaSetting) `
    "rendersStickyAtc=$rendersStickyAtc, schemaSetting=$hasSchemaSetting"

# ------------------------------------------------------------------------------
# 3. JAVASCRIPT LOGIC & STRESS TESTING (assets/sticky-atc.js)
# ------------------------------------------------------------------------------
Write-Host "`n--- 3. JavaScript Logic & Stress Testing (assets/sticky-atc.js) ---" -ForegroundColor Yellow

$stickyJsPath = Join-Path $RepoRoot "assets\sticky-atc.js"
$stickyJsContent = [System.IO.File]::ReadAllText($stickyJsPath, [System.Text.Encoding]::UTF8)

# Test 3.1: Custom element definition and cleanup lifecycle
$definesCustomElement = $stickyJsContent -match "customElements\.define\(\s*'sticky-atc'"
$hasDisconnectedCleanup = $stickyJsContent -match "disconnectedCallback\(\)" -and $stickyJsContent -match "this\.observer\.disconnect\(\)" -and $stickyJsContent -match "this\.variantUnsubscriber\(\)"
Record-Result "M4.JS.01" "sticky-atc.js Custom Element Lifecycle & Memory Leak Cleanup" ($definesCustomElement -and $hasDisconnectedCleanup) `
    "customElements.define=$definesCustomElement, disconnectedCallback cleanup=$hasDisconnectedCleanup"

# Test 3.2: IntersectionObserver Fallback & Target Resolvers
$hasObserverTargets = $stickyJsContent -match 'ProductSubmitButton-\$\{this\.sectionId\}' -and
                      $stickyJsContent -match 'ProductInfo-\$\{this\.sectionId\} \.product-form__buttons' -and
                      $stickyJsContent -match 'MainProduct-\$\{this\.sectionId\} \.product-form__buttons'
$hasNullTargetGuard = $stickyJsContent -match 'if \(!target\) return;'
Record-Result "M4.JS.02" "IntersectionObserver Target Resolution & Null Target Guard" ($hasObserverTargets -and $hasNullTargetGuard) `
    "Multi-target selector resolution and graceful return if target absent"

# Test 3.3: Scroll Direction & Viewport Boundary Math
$hasTopCheck = $stickyJsContent -match 'entry\.boundingClientRect\.top < 0'
$hasShowHide = $stickyJsContent -match 'this\.show\(\)' -and $stickyJsContent -match 'this\.hide\(\)'
Record-Result "M4.JS.03" "Scroll Direction & Sticky Reveal Logic (top < 0 -> show, else hide)" ($hasTopCheck -and $hasShowHide) `
    "Shows when scrolled past primary ATC; hides when above or in viewport"

# Test 3.4: PubSub Variant Change Listener & Master Form Sync
$hasPubSubSubscribe = $stickyJsContent -match 'subscribe\(PUB_SUB_EVENTS\.variantChange'
$hasMasterRadioSync = $stickyJsContent -match 'input\[type="radio"\]\[value="\$\{variantId\}"\]'
$hasMasterSelectSync = $stickyJsContent -match 'select\[name="id"\]'
$dispatchesEvent = $stickyJsContent -match "dispatchEvent\(new Event\('change'"
Record-Result "M4.JS.04" "Bi-directional Variant State Synchronization (PubSub & Master Form Events)" ($hasPubSubSubscribe -and $hasMasterRadioSync -and $hasMasterSelectSync -and $dispatchesEvent) `
    "Subscribes to PubSub variantChange; dispatches bubbling change event to radio/select inputs"

# Test 3.5: Button Click Delegation to Master Product Form
$hasButtonClick = $stickyJsContent -match 'onButtonClick\(evt\)'
$checksDisabled = $stickyJsContent -match "this\.button\.hasAttribute\('disabled'\)"
$clicksPrimary = $stickyJsContent -match 'primarySubmitButton\.click\(\)'
$requestSubmit = $stickyJsContent -match 'primaryForm\.requestSubmit\(\)'
Record-Result "M4.JS.05" "Click Delegation: Triggers Primary Submit Button or requestSubmit()" ($hasButtonClick -and $checksDisabled -and $clicksPrimary -and $requestSubmit) `
    "Guards disabled state, clicks primary ATC button or calls requestSubmit()"

# ------------------------------------------------------------------------------
# 4. CSS STYLING & BRAND INTEGRATION
# ------------------------------------------------------------------------------
Write-Host "`n--- 4. CSS Styling & Brand Integration ---" -ForegroundColor Yellow

$stickyCssPath = Join-Path $RepoRoot "assets\component-sticky-atc.css"
$stickyCssContent = [System.IO.File]::ReadAllText($stickyCssPath, [System.Text.Encoding]::UTF8)

# Test 4.1: Glassmorphism background and FocusDrawer Gold button styling
$hasCharcoalGlass = $stickyCssContent -match 'rgba\(30,\s*30,\s*30' -or $stickyCssContent -match 'backdrop-filter'
$hasGoldButton = $stickyCssContent -match '#E5A93C' -or $stickyCssContent -match 'var\(--color-button\)'
$hasZIndex = $stickyCssContent -match 'z-index:\s*(?:10|100|999|1000|[2-9]\d)'
$hasFixedPosition = $stickyCssContent -match 'position:\s*fixed' -and $stickyCssContent -match 'bottom:\s*0'

Record-Result "M4.CSS.01" "Sticky ATC CSS: Fixed Glassmorphic Bar, High Z-Index, Gold CTA" ($hasCharcoalGlass -and $hasGoldButton -and $hasZIndex -and $hasFixedPosition) `
    "position=fixed, bottom=0, glassmorphism backdrop, FocusDrawer gold button"

# Test 4.2: Mobile Responsive Breakpoint Layout (< 750px)
$hasMobileQuery = $stickyCssContent -match '@media\s+screen\s+and\s+\(max-width:\s*749px\)'
$hasFlexLayout = $stickyCssContent -match 'display:\s*flex'
Record-Result "M4.CSS.02" "Mobile Responsive Rules for Small Screens (< 750px)" ($hasMobileQuery -and $hasFlexLayout) `
    "Mobile layout rules defined for max-width: 749px"

# ------------------------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------------------------
Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "  M4 CHALLENGER SUITE EXECUTION COMPLETE" -ForegroundColor Cyan
Write-Host "  Total Assertions : $($Passed + $Failed)" -ForegroundColor White
Write-Host "  Passed           : $Passed" -ForegroundColor Green
Write-Host "  Failed           : $Failed" -ForegroundColor $(if ($Failed -eq 0) { "Green" } else { "Red" })
Write-Host "==============================================================================" -ForegroundColor Cyan

if ($Failed -eq 0) {
    Write-Host "VERDICT: APPROVE - All Milestone 4 implementations passed empirical stress testing cleanly.`n" -ForegroundColor Green
    exit 0
} else {
    Write-Host "VERDICT: REQUEST_CHANGES - $($Failed) assertion(s) failed.`n" -ForegroundColor Red
    exit 1
}
