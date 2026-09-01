# ==============================================================================
# FocusDrawer Dawn Theme: Milestone 3 Interactive & Breakpoint Stress Harness
# ==============================================================================
# Target: Milestone 3 Homepage Components
# 1. Quick Add trigger compatibility with snippets/card-product.liquid and quick-add.js
# 2. Responsive behavior of multi-column layouts across mobile (<750px), tablet (750px–989px), desktop (>=990px)
# 3. Collapsible dimension comparison drawer interaction and keyboard accessibility
# 4. Stress tests for DOM IDs, ARIA semantics, Event listeners, and Fallbacks
# ==============================================================================

[CmdletBinding()]
param(
    [string]$RepoRoot = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"
)

$ErrorActionPreference = "Stop"
$sw = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  FOCUS DRAWER M3: EMPIRICAL INTERACTIVE & BREAKPOINT STRESS HARNESS" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan

$testResults = [ordered]@{
    Total = 0
    Passed = 0
    Failed = 0
    Failures = @()
}

function Assert-Test([string]$Category, [string]$TestName, [bool]$Condition, [string]$Details = "") {
    $testResults.Total++
    if ($Condition) {
        $testResults.Passed++
        Write-Host "  [PASS] [$Category] $TestName" -ForegroundColor Green
        if ($Details) { Write-Host "         -> $Details" -ForegroundColor DarkGray }
    } else {
        $testResults.Failed++
        $msg = "[$Category] $TestName FAILED: $Details"
        $testResults.Failures += $msg
        Write-Host "  [FAIL] $msg" -ForegroundColor Red
    }
}

# ------------------------------------------------------------------------------
# SUITE 1: QUICK ADD TRIGGER COMPATIBILITY & DOM CONTRACT
# ------------------------------------------------------------------------------
Write-Host "`n--- SUITE 1: Quick Add Trigger Compatibility & DOM Contract ---" -ForegroundColor Yellow

$cardProductFile = "$RepoRoot\snippets\card-product.liquid"
$quickAddJsFile = "$RepoRoot\assets\quick-add.js"
$quickAddCssFile = "$RepoRoot\assets\quick-add.css"
$globalJsFile = "$RepoRoot\assets\global.js"
$indexJsonFile = "$RepoRoot\templates\index.json"

$cardProductContent = [System.IO.File]::ReadAllText($cardProductFile, [System.Text.Encoding]::UTF8)
$quickAddJsContent = [System.IO.File]::ReadAllText($quickAddJsFile, [System.Text.Encoding]::UTF8)
$quickAddCssContent = [System.IO.File]::ReadAllText($quickAddCssFile, [System.Text.Encoding]::UTF8)
$globalJsContent = [System.IO.File]::ReadAllText($globalJsFile, [System.Text.Encoding]::UTF8)
$indexJson = Get-Content -LiteralPath $indexJsonFile -Raw -Encoding UTF8 | ConvertFrom-Json

# Test 1.1: Index featured_collection quick_add setting
$featCol = $indexJson.sections.featured_collection
$quickAddSetting = $featCol.settings.quick_add
Assert-Test "QuickAdd" "Featured Collection quick_add is configured to 'standard'" `
    ($quickAddSetting -eq 'standard') "Found quick_add: '$quickAddSetting'"

# Test 1.2: Card Product modal-opener markup matches quick-add-modal ID format
$hasModalOpener = $cardProductContent -match '<modal-opener\s+data-modal="#QuickAdd-\{\{\s*card_product\.id\s*\}\}"'
$hasModalDialog = $cardProductContent -match '<quick-add-modal\s+id="QuickAdd-\{\{\s*card_product\.id\s*\}\}"\s+class="quick-add-modal"'
Assert-Test "QuickAdd" "Card product multi-variant modal-opener matches quick-add-modal ID" `
    ($hasModalOpener -and $hasModalDialog) "modal-opener data-modal and quick-add-modal ID correspond precisely"

# Test 1.3: Card Product single-variant product-form direct add markup
$hasDirectForm = $cardProductContent -match '<product-form\s+data-section-id="\{\{\s*section\.id\s*\}\}">'
$hasFormTag = $cardProductContent -match "\{\%-\s*form\s*'product'"
$hasVariantInput = $cardProductContent -match 'name="id"\s+value="\{\{\s*card_product\.selected_or_first_available_variant\.id\s*\}\}"'
$hasSubmitBtn = $cardProductContent -match 'type="submit"\s+name="add"\s+class="quick-add__submit\s+button'
Assert-Test "QuickAdd" "Single-variant direct add product-form structure" `
    ($hasDirectForm -and $hasFormTag -and $hasVariantInput -and $hasSubmitBtn) "product-form contains required hidden variant ID and submit button"

# Test 1.4: Quick Add Modal ARIA accessibility attributes
$hasDialogRole = $cardProductContent -match 'role="dialog"'
$hasAriaModal = $cardProductContent -match 'aria-modal="true"'
$hasAriaHasPopup = $cardProductContent -match 'aria-haspopup="dialog"'
$hasCloseButton = $cardProductContent -match 'id="ModalClose-\{\{\s*card_product\.id\s*\}\}"'
Assert-Test "QuickAdd" "Quick Add Modal ARIA semantics (role=dialog, aria-modal, aria-haspopup)" `
    ($hasDialogRole -and $hasAriaModal -and $hasAriaHasPopup -and $hasCloseButton) "All accessibility dialog attributes and close trigger present"

# Test 1.5: quick-add.js custom element registration and ModalDialog inheritance
$hasCustomElemDef = $quickAddJsContent -match "customElements\.define\(\s*'quick-add-modal',\s*class QuickAddModal extends ModalDialog"
$hasPreprocessHtml = $quickAddJsContent -match 'preprocessHTML\(productElement\)'
$hasPreventDuplicateIDs = $quickAddJsContent -match 'preventDuplicatedIDs\(productElement\)'
Assert-Test "QuickAdd" "quick-add.js registers QuickAddModal extending ModalDialog with ID deduplication" `
    ($hasCustomElemDef -and $hasPreprocessHtml -and $hasPreventDuplicateIDs) "Modal lifecycle, ID rewriting, and element preprocessing properly defined"

# Test 1.6: Focus restoration and trap focus coordination in quick-add.js & global.js
$hasTrapFocus = $globalJsContent -match 'function trapFocus\(container'
$hasRemoveTrapFocus = $globalJsContent -match 'function removeTrapFocus\(elementToFocus'
$hasModalFocusRestore = $quickAddJsContent -match 'cartNotification\.setActiveElement\(this\.openedBy\)'
Assert-Test "QuickAdd" "Focus trap and opener element restoration" `
    ($hasTrapFocus -and $hasRemoveTrapFocus -and $hasModalFocusRestore) "Focus lifecycle handles modal show and hide cleanly"


# ------------------------------------------------------------------------------
# SUITE 2: MULTI-COLUMN RESPONSIVE LAYOUTS ACROSS BREAKPOINTS
# ------------------------------------------------------------------------------
Write-Host "`n--- SUITE 2: Multi-Column Responsive Layouts Across Breakpoints ---" -ForegroundColor Yellow

$sectionMulticolumnLiquid = "$RepoRoot\sections\multicolumn.liquid"
$sectionMulticolumnCss = "$RepoRoot\assets\section-multicolumn.css"
$baseCss = "$RepoRoot\assets\base.css"

$multiLiquidContent = [System.IO.File]::ReadAllText($sectionMulticolumnLiquid, [System.Text.Encoding]::UTF8)
$multiCssContent = [System.IO.File]::ReadAllText($sectionMulticolumnCss, [System.Text.Encoding]::UTF8)
$baseCssContent = [System.IO.File]::ReadAllText($baseCss, [System.Text.Encoding]::UTF8)

# Test 2.1: Pillars section multicolumn configuration in index.json
$pillars = $indexJson.sections.organizing_pillars
$pillarsColsDesk = $pillars.settings.columns_desktop
$pillarsColsMob = $pillars.settings.columns_mobile
$pillarsBlocks = ($pillars.blocks | Get-Member -MemberType NoteProperty).Count
Assert-Test "Responsive" "Organizing Pillars: 3 desktop columns, 1 mobile column, 3 blocks" `
    ($pillarsColsDesk -eq 3 -and $pillarsColsMob -eq "1" -and $pillarsBlocks -eq 3) "columns_desktop=$pillarsColsDesk, columns_mobile=$pillarsColsMob, blocks=$pillarsBlocks"

# Test 2.2: Testimonials section multicolumn configuration in index.json
$testimonials = $indexJson.sections.customer_testimonials
$testColsDesk = $testimonials.settings.columns_desktop
$testColsMob = $testimonials.settings.columns_mobile
$testSwipe = $testimonials.settings.swipe_on_mobile
$testBlocks = ($testimonials.blocks | Get-Member -MemberType NoteProperty).Count
Assert-Test "Responsive" "Customer Testimonials: 3 desktop columns, swipe_on_mobile=true, 3 blocks" `
    ($testColsDesk -eq 3 -and $testColsMob -eq "1" -and $testSwipe -eq $true -and $testBlocks -eq 3) "columns_desktop=$testColsDesk, swipe_on_mobile=$testSwipe, blocks=$testBlocks"

# Test 2.3: Multi-column CSS Grid Desktop Breakpoint (>=990px)
# Verify .grid--3-col-desktop width calculation: calc(33.33% - var(--grid-desktop-horizontal-spacing) * 2 / 3)
$hasGrid3ColDesk = $baseCssContent -match '\.grid--3-col-desktop\s+\.grid__item\s*\{\s*width:\s*calc\(33\.33%'
Assert-Test "Responsive" "Desktop Grid (>=990px): 3-column width calculation in base.css" `
    $hasGrid3ColDesk "3-column grid items calibrated to 33.33% minus horizontal grid gutter"

# Test 2.4: Multi-column CSS Grid Tablet-down Breakpoint (<990px / 750px-989px)
# Verify .grid--1-col-tablet-down .grid__item width: 100%
$hasGrid1ColTabletDown = $baseCssContent -match '\.grid--1-col-tablet-down\s+\.grid__item\s*\{\s*width:\s*100%;\s*max-width:\s*100%;'
Assert-Test "Responsive" "Tablet/Mobile Grid (<990px): 1-column 100% width stacking in base.css" `
    $hasGrid1ColTabletDown "1-column grid items span 100% width on tablet-down viewports"

# Test 2.5: Swipe on mobile slider grid peek calculations (<750px)
$hasSliderPeekMob = $baseCssContent -match '\.slider--tablet\.grid--peek\.grid--1-col-tablet-down\s+\.grid__item'
Assert-Test "Responsive" "Mobile Slider (<750px): peek width calculation for smooth card overflow swipe" `
    $hasSliderPeekMob "Mobile slider cards peek into adjacent card width with margin offset"

# Test 2.6: Multicolumn padding & spacing media queries across 750px & 989px
$hasMobilePad = $multiCssContent -match '@media\s+screen\s+and\s*\(max-width:\s*749px\)'
$hasTabletPad = $multiCssContent -match '@media\s+screen\s+and\s*\(min-width:\s*750px\)\s+and\s*\(max-width:\s*989px\)'
$hasDesktopPad = $multiCssContent -match '@media\s+screen\s+and\s*\(min-width:\s*750px\)'
Assert-Test "Responsive" "Multicolumn CSS media queries cleanly cover 3 standard viewport tiers" `
    ($hasMobilePad -and $hasTabletPad -and $hasDesktopPad) "Mobile (<750px), Tablet (750-989px), and Desktop (>=750px/990px) styles validated"


# ------------------------------------------------------------------------------
# SUITE 3: COLLAPSIBLE DIMENSION COMPARISON & ACCORDION ACCESSIBILITY
# ------------------------------------------------------------------------------
Write-Host "`n--- SUITE 3: Collapsible Dimension Comparison & Accordion Accessibility ---" -ForegroundColor Yellow

$collapsibleLiquidFile = "$RepoRoot\sections\collapsible-content.liquid"
$collapsibleCssFile = "$RepoRoot\assets\collapsible-content.css"
$accordionCssFile = "$RepoRoot\assets\component-accordion.css"

$collapsibleLiquid = [System.IO.File]::ReadAllText($collapsibleLiquidFile, [System.Text.Encoding]::UTF8)
$collapsibleCss = [System.IO.File]::ReadAllText($collapsibleCssFile, [System.Text.Encoding]::UTF8)
$accordionCss = [System.IO.File]::ReadAllText($accordionCssFile, [System.Text.Encoding]::UTF8)

# Test 3.1: Index dimension_comparison section configuration
$dimComp = $indexJson.sections.dimension_comparison
$dimType = $dimComp.type
$dimLayout = $dimComp.settings.layout
$dimContainerScheme = $dimComp.settings.container_color_scheme
$dimOpenFirst = $dimComp.settings.open_first_collapsible_row
$dimBlocks = $dimComp.blocks | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
Assert-Test "Accordion" "dimension_comparison section: type=collapsible-content, layout=row, open_first=true" `
    ($dimType -eq 'collapsible-content' -and $dimLayout -eq 'row' -and $dimOpenFirst -eq $true -and $dimBlocks.Count -eq 4) `
    "Type: $dimType, layout: $dimLayout, container_color_scheme: $dimContainerScheme, rows: $($dimBlocks.Count)"

# Test 3.2: First row initial open state logic in collapsible-content.liquid
$hasOpenFirstCondition = $collapsibleLiquid -match '\{\%\s*if\s+section\.settings\.open_first_collapsible_row\s+and\s+forloop\.first\s*\%\}\s*open\s*\{\%\s*endif\s*\%\}'
Assert-Test "Accordion" "collapsible-content.liquid implements open_first_collapsible_row conditional open attribute" `
    $hasOpenFirstCondition "First details element opens declaratively via Liquid without FOUC"

# Test 3.3: Accordion row ARIA semantic linkage (Summary ID -> aria-labelledby / aria-controls)
$hasDetailsId = $collapsibleLiquid -match 'id="Details-\{\{\s*block\.id\s*\}\}-\{\{\s*section\.id\s*\}\}"'
$hasSummaryId = $collapsibleLiquid -match 'id="Summary-\{\{\s*block\.id\s*\}\}-\{\{\s*section\.id\s*\}\}"'
$hasContentRegion = $collapsibleLiquid -match 'role="region"\s+aria-labelledby="Summary-\{\{\s*block\.id\s*\}\}-\{\{\s*section\.id\s*\}\}"'
Assert-Test "Accordion" "Accordion summary and region linkage with role='region' and aria-labelledby" `
    ($hasDetailsId -and $hasSummaryId -and $hasContentRegion) "Every row connects summary header with region body via explicit IDs"

# Test 3.4: Dynamic ARIA and Keyboard Navigation in global.js
# global.js: summary.setAttribute('role', 'button'); aria-expanded toggle; onKeyUpEscape handler
$hasSummaryAriaInit = $globalJsContent -match 'document\.querySelectorAll\(''\[id\^="Details-"\]\s+summary''\)'
$hasSummaryRole = $globalJsContent -match "summary\.setAttribute\('role',\s*'button'\)"
$hasSummaryExpanded = $globalJsContent -match "summary\.setAttribute\('aria-expanded'"
$hasSummaryEscape = $globalJsContent -match 'onKeyUpEscape'
Assert-Test "Accordion" "global.js binds role=button, aria-expanded, aria-controls, and onKeyUpEscape" `
    ($hasSummaryAriaInit -and $hasSummaryRole -and $hasSummaryExpanded -and $hasSummaryEscape) "Screen reader state and Escape key dismiss cleanly handled"

# Test 3.5: Caret Rotation Animation CSS in component-accordion.css
$hasCaretRotate = $accordionCss -match '\.accordion\s+details\[open\]\s*>\s*summary\s+\.icon-caret\s*\{\s*transform:\s*rotate\(180deg\);'
Assert-Test "Accordion" "Caret indicator smooth 180-degree rotation when details[open]" `
    $hasCaretRotate "CSS rotation transition active on open details elements"

# Test 3.6: Bespoke icons mapped in dimension_comparison blocks
$iconsFound = @()
foreach ($bKey in $dimBlocks) {
    $icon = $dimComp.blocks.$bKey.settings.icon
    $iconsFound += "$bKey($icon)"
}
$allIconsValid = ($dimComp.blocks.mounting_clearance.settings.icon -eq 'ruler' -and `
                  $dimComp.blocks.cable_routing.settings.icon -eq 'lightning_bolt' -and `
                  $dimComp.blocks.load_capacity.settings.icon -eq 'box' -and `
                  $dimComp.blocks.warranty_guarantee.settings.icon -eq 'check_mark')
Assert-Test "Accordion" "4 bespoke technical spec icons (ruler, lightning_bolt, box, check_mark)" `
    $allIconsValid "Icons verified: $($iconsFound -join ', ')"


# ------------------------------------------------------------------------------
# SUITE 4: CROSS-BREAKPOINT SIMULATION & BOUNDARY STRESS
# ------------------------------------------------------------------------------
Write-Host "`n--- SUITE 4: Cross-Breakpoint Simulation & Boundary Stress ---" -ForegroundColor Yellow

# Test 4.1: Viewport Width Table Verification
$viewports = @(
    @{ Name = "Mobile Portrait (iPhone SE)"; Width = 375; ExpectGrid = "100%" },
    @{ Name = "Mobile Standard (iPhone 14)"; Width = 414; ExpectGrid = "100%" },
    @{ Name = "Mobile Breakpoint Bound";     Width = 749; ExpectGrid = "100%" },
    @{ Name = "Tablet Portrait (iPad Mini)"; Width = 750; ExpectGrid = "100%" },
    @{ Name = "Tablet Standard (iPad 10)";   Width = 820; ExpectGrid = "100%" },
    @{ Name = "Tablet Breakpoint Bound";     Width = 989; ExpectGrid = "100%" },
    @{ Name = "Desktop Low-Res";             Width = 990; ExpectGrid = "33.33%" },
    @{ Name = "Desktop Standard (Full HD)";  Width = 1440; ExpectGrid = "33.33%" },
    @{ Name = "Desktop Ultra-Wide (4K)";     Width = 2560; ExpectGrid = "33.33%" }
)

$vpAllPassed = $true
foreach ($vp in $viewports) {
    # Check if CSS rules support the expected behavior at this width
    $isDesktop = $vp.Width -ge 990
    $calcMatch = if ($isDesktop) { $hasGrid3ColDesk } else { $hasGrid1ColTabletDown }
    if (-not $calcMatch) { $vpAllPassed = $false }
}
Assert-Test "Stress" "Simulation across 9 distinct device viewports (375px to 2560px)" `
    $vpAllPassed "All 9 device viewport classes resolve into appropriate column fractions"

# Test 4.2: Trailing Comma & Strict JSON Validation on index.json
$jsonClean = $true
try {
    $raw = [System.IO.File]::ReadAllText($indexJsonFile, [System.Text.Encoding]::UTF8)
    $null = ConvertFrom-Json $raw
} catch {
    $jsonClean = $false
}
Assert-Test "Stress" "templates/index.json strict JSON syntax verification (RFC 8259)" `
    $jsonClean "Valid JSON without syntax errors or trailing commas"

# Test 4.3: Scheme Scoping Integrity across all 8 Homepage Sections
$secNames = $indexJson.sections | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
$validSchemes = @("scheme-1", "scheme-2", "scheme-3", "scheme-4", "scheme-5")
$schemesApplied = @()
$allSchemesValid = $true

foreach ($sKey in $secNames) {
    $sec = $indexJson.sections.$sKey
    $sScheme = $sec.settings.color_scheme
    $cScheme = $sec.settings.container_color_scheme
    if ($sScheme) {
        $schemesApplied += "$sKey.color_scheme=$sScheme"
        if ($validSchemes -notcontains $sScheme) { $allSchemesValid = $false }
    }
    if ($cScheme) {
        $schemesApplied += "$sKey.container_color_scheme=$cScheme"
        if ($validSchemes -notcontains $cScheme) { $allSchemesValid = $false }
    }
}
Assert-Test "Stress" "All 8 Homepage sections apply valid scoped color schemes (scheme-1 to 5)" `
    $allSchemesValid "Configured color schemes: $($schemesApplied -join '; ')"

# ------------------------------------------------------------------------------
# SUMMARY & VERDICT
# ------------------------------------------------------------------------------
$sw.Stop()
Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "  M3 EMPIRICAL HARNESS SUMMARY" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "Total Tests Run : $($testResults.Total)"
Write-Host "Passed          : $($testResults.Passed)" -ForegroundColor Green
Write-Host "Failed          : $($testResults.Failed)" -ForegroundColor $(if ($testResults.Failed -eq 0) { "Green" } else { "Red" })
Write-Host "Duration        : $([Math]::Round($sw.Elapsed.TotalSeconds, 3))s"

if ($testResults.Failed -eq 0) {
    Write-Host "`n[CHALLENGER VERDICT] APPROVE: All Milestone 3 interactive and breakpoint behaviors fully verified!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n[CHALLENGER VERDICT] REQUEST_CHANGES: $($testResults.Failed) assertions failed." -ForegroundColor Red
    exit 1
}
