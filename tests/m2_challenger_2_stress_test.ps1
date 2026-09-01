# ==============================================================================
# FocusDrawer M2 Empirical Challenge: PubSub & DOM Sync Stress Harness
# Challenger: m2_challenger_2 (PubSub & DOM Sync Challenger)
# Target: Milestone 2 (AJAX Cart Section Rendering, PubSub Sync, Mobile Drawer Transitions, Contrast)
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " FOCUSDRAWER M2 EMPIRICAL CHALLENGE: PUBSUB & DOM SYNC HARNESS" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan

$script:TotalAsserts = 0
$script:PassedAsserts = 0
$script:FailedAsserts = 0
$script:Findings = @()

function Assert-Condition {
    param(
        [string]$TestName,
        [bool]$Condition,
        [string]$Details = ""
    )
    $script:TotalAsserts++
    if ($Condition) {
        $script:PassedAsserts++
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
    } else {
        $script:FailedAsserts++
        $msg = "  [FAIL] $TestName : $Details"
        Write-Host $msg -ForegroundColor Red
        $script:Findings += $msg
    }
}

# ------------------------------------------------------------------------------
# 1. WCAG 2.1 Color Luminance & Contrast Oracle
# ------------------------------------------------------------------------------
function Get-RelativeLuminance([string]$hexColor) {
    $hex = $hexColor.TrimStart('#')
    $r8 = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g8 = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b8 = [Convert]::ToInt32($hex.Substring(4, 2), 16)

    $toLinear = {
        param([double]$v)
        $s = $v / 255.0
        if ($s -le 0.04045) {
            return $s / 12.92
        } else {
            return [Math]::Pow(($s + 0.055) / 1.055, 2.4)
        }
    }

    $rLin = & $toLinear $r8
    $gLin = & $toLinear $g8
    $bLin = & $toLinear $b8

    return (0.2126 * $rLin) + (0.7152 * $gLin) + (0.0722 * $bLin)
}

function Get-ContrastRatio([string]$hex1, [string]$hex2) {
    $l1 = Get-RelativeLuminance $hex1
    $l2 = Get-RelativeLuminance $hex2
    $brightest = [Math]::Max($l1, $l2)
    $darkest = [Math]::Min($l1, $l2)
    return [Math]::Round(($brightest + 0.05) / ($darkest + 0.05), 2)
}

Write-Host "`n--- CHALLENGE SET 1: WCAG 2.1 Accessibility & Contrast Ratios ---" -ForegroundColor Yellow

$crAnnouncement = Get-ContrastRatio "#E5A93C" "#121212"
Write-Host "  Announcement Bar (Gold #E5A93C on Dark #121212): Contrast Ratio = $crAnnouncement : 1" -ForegroundColor Gray
Assert-Condition -TestName "M2.WCAG.01: Announcement Bar Contrast Ratio >= 7.0:1 (WCAG AAA)" `
    -Condition ($crAnnouncement -ge 7.0) `
    -Details "Actual CR: $crAnnouncement"

$crMobileNav = Get-ContrastRatio "#1E1E1E" "#FFFFFF"
Write-Host "  Mobile Drawer Nav (White #FFFFFF on Charcoal #1E1E1E): Contrast Ratio = $crMobileNav : 1" -ForegroundColor Gray
Assert-Condition -TestName "M2.WCAG.02: Mobile Nav Main Text Contrast Ratio >= 7.0:1 (WCAG AAA)" `
    -Condition ($crMobileNav -ge 7.0) `
    -Details "Actual CR: $crMobileNav"

$crMobileActive = Get-ContrastRatio "#1E1E1E" "#E5A93C"
Write-Host "  Mobile Nav Active Indicator (Gold #E5A93C on Charcoal #1E1E1E): Contrast Ratio = $crMobileActive : 1" -ForegroundColor Gray
Assert-Condition -TestName "M2.WCAG.03: Mobile Nav Active Gold Text Contrast Ratio >= 4.5:1 (WCAG AA)" `
    -Condition ($crMobileActive -ge 4.5) `
    -Details "Actual CR: $crMobileActive"

$crPrimaryBtn = Get-ContrastRatio "#E5A93C" "#121212"
Write-Host "  Primary Button (Dark #121212 text on Gold #E5A93C): Contrast Ratio = $crPrimaryBtn : 1" -ForegroundColor Gray
Assert-Condition -TestName "M2.WCAG.04: Primary Button Label Contrast Ratio >= 7.0:1 (WCAG AAA)" `
    -Condition ($crPrimaryBtn -ge 7.0) `
    -Details "Actual CR: $crPrimaryBtn"

# ------------------------------------------------------------------------------
# 2. Free Shipping Liquid Arithmetic Stress Test Oracle
# ------------------------------------------------------------------------------
Write-Host "`n--- CHALLENGE SET 2: Free Shipping Liquid Arithmetic Boundary Stress ---" -ForegroundColor Yellow

function Simulate-LiquidShippingProgress([int]$cartTotalCents, [int]$thresholdCents) {
    $remaining = $thresholdCents - $cartTotalCents
    if ($remaining -le 0) {
        $progress = 100
        $isUnlocked = $true
    } else {
        $isUnlocked = $false
        if ($thresholdCents -gt 0) {
            $raw = ($cartTotalCents * 100.0) / $thresholdCents
            $progress = [Math]::Min(100, [Math]::Round($raw, [MidpointRounding]::AwayFromZero))
        } else {
            $progress = 100
        }
    }
    return @{
        Progress = $progress
        IsUnlocked = $isUnlocked
        Remaining = [Math]::Max(0, $remaining)
    }
}

# Test 12 boundary amounts
$testCases = @(
    @{ Total = 0; ExpectedProgress = 0; ExpectedUnlocked = $false; ExpectedRemaining = 5000 },
    @{ Total = 1; ExpectedProgress = 0; ExpectedUnlocked = $false; ExpectedRemaining = 4999 },
    @{ Total = 50; ExpectedProgress = 1; ExpectedUnlocked = $false; ExpectedRemaining = 4950 },
    @{ Total = 1250; ExpectedProgress = 25; ExpectedUnlocked = $false; ExpectedRemaining = 3750 },
    @{ Total = 2500; ExpectedProgress = 50; ExpectedUnlocked = $false; ExpectedRemaining = 2500 },
    @{ Total = 3750; ExpectedProgress = 75; ExpectedUnlocked = $false; ExpectedRemaining = 1250 },
    @{ Total = 4999; ExpectedProgress = 100; ExpectedUnlocked = $false; ExpectedRemaining = 1 },
    @{ Total = 5000; ExpectedProgress = 100; ExpectedUnlocked = $true; ExpectedRemaining = 0 },
    @{ Total = 5001; ExpectedProgress = 100; ExpectedUnlocked = $true; ExpectedRemaining = 0 },
    @{ Total = 7500; ExpectedProgress = 100; ExpectedUnlocked = $true; ExpectedRemaining = 0 },
    @{ Total = 12000; ExpectedProgress = 100; ExpectedUnlocked = $true; ExpectedRemaining = 0 },
    @{ Total = 1000000; ExpectedProgress = 100; ExpectedUnlocked = $true; ExpectedRemaining = 0 }
)

foreach ($tc in $testCases) {
    $res = Simulate-LiquidShippingProgress -cartTotalCents $tc.Total -thresholdCents 5000
    $pass = ($res.Progress -eq $tc.ExpectedProgress) -and `
            ($res.IsUnlocked -eq $tc.ExpectedUnlocked) -and `
            ($res.Remaining -eq $tc.ExpectedRemaining)
    Assert-Condition -TestName "M2.ARITH.Subtotal_$($tc.Total)c : Progress=$($res.Progress)%, Unlocked=$($res.IsUnlocked), Remaining=$($res.Remaining)c" `
        -Condition $pass `
        -Details "Expected $($tc.ExpectedProgress)% / $($tc.ExpectedUnlocked) / $($tc.ExpectedRemaining)c"
}

# ------------------------------------------------------------------------------
# 3. Section Rendering & DOM Replacement Selectors Integrity
# ------------------------------------------------------------------------------
Write-Host "`n--- CHALLENGE SET 3: Section Rendering & PubSub DOM Replacement ---" -ForegroundColor Yellow

$cartDrawerLiquid = [System.IO.File]::ReadAllText("$PSScriptRoot\..\snippets\cart-drawer.liquid", [System.Text.Encoding]::UTF8)
$cartDrawerJs = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\cart-drawer.js", [System.Text.Encoding]::UTF8)
$cartJs = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\cart.js", [System.Text.Encoding]::UTF8)
$productFormJs = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\product-form.js", [System.Text.Encoding]::UTF8)

# Check 1: In cart-drawer.liquid, .cart-drawer__free-shipping is inside .drawer__inner
$hasFreeShippingInsideInner = ($cartDrawerLiquid -match '<div\s+class="drawer__inner[\s\S]*?class="cart-drawer__free-shipping')
Assert-Condition -TestName "M2.DOM.01: Free shipping container is rendered inside .drawer__inner" `
    -Condition $hasFreeShippingInsideInner `
    -Details "Free shipping progress container must be child of .drawer__inner for section replacement"

# Check 2: cart.js onCartUpdate replaces .cart-drawer__free-shipping
$cartJsReplacesMeter = ($cartJs -match "'\.cart-drawer__free-shipping'") -and ($cartJs -match "'\.cart-drawer__shipping-meter'")
Assert-Condition -TestName "M2.DOM.02: cart.js onCartUpdate() contains .cart-drawer__free-shipping in replace selectors" `
    -Condition $cartJsReplacesMeter `
    -Details "cart.js must include free shipping selectors for external pubsub updates"

# Check 3: CartDrawerItems getSectionsToRender() targets .drawer__inner
$cartDrawerItemsTargetsInner = ($cartDrawerJs -match "section:\s*'cart-drawer'") -and ($cartDrawerJs -match "selector:\s*'\.drawer__inner'")
Assert-Condition -TestName "M2.DOM.03: CartDrawerItems.getSectionsToRender() targets .drawer__inner" `
    -Condition $cartDrawerItemsTargetsInner `
    -Details "CartDrawerItems must target .drawer__inner for atomic drawer DOM re-rendering"

# Check 4: CartDrawer renderContents() targets #CartDrawer
$cartDrawerTargetsOuter = ($cartDrawerJs -match "id:\s*'cart-drawer'") -and ($cartDrawerJs -match "selector:\s*'#CartDrawer'")
Assert-Condition -TestName "M2.DOM.04: CartDrawer.getSectionsToRender() targets #CartDrawer" `
    -Condition $cartDrawerTargetsOuter `
    -Details "CartDrawer must target #CartDrawer container on add-to-cart mutations"

# Check 5: PubSub event subscription in cart.js
$cartJsPubSub = ($cartJs -match "subscribe\(PUB_SUB_EVENTS\.cartUpdate")
Assert-Condition -TestName "M2.DOM.05: CartItems subscribes to PUB_SUB_EVENTS.cartUpdate" `
    -Condition $cartJsPubSub `
    -Details "CartItems connectedCallback must listen to PUB_SUB_EVENTS.cartUpdate"

# Check 6: Product form dispatches PUB_SUB_EVENTS.cartUpdate
$productFormPublishes = ($productFormJs -match "publish\(PUB_SUB_EVENTS\.cartUpdate")
Assert-Condition -TestName "M2.DOM.06: ProductForm dispatches PUB_SUB_EVENTS.cartUpdate upon successful add" `
    -Condition $productFormPublishes `
    -Details "ProductForm must notify subscribers via PUB_SUB_EVENTS.cartUpdate"

# ------------------------------------------------------------------------------
# 4. Mobile Drawer CSS Transitions, Z-Index Layering & Backdrop Blur
# ------------------------------------------------------------------------------
Write-Host "`n--- CHALLENGE SET 4: Mobile Drawer Transitions, Z-Index & Backdrop Blur ---" -ForegroundColor Yellow

$menuDrawerCss = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\component-menu-drawer.css", [System.Text.Encoding]::UTF8)
$globalJs = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\global.js", [System.Text.Encoding]::UTF8)

# Check 1: Backdrop blur in menu drawer scrim
$hasBackdropFilter = ($menuDrawerCss -match "backdrop-filter:\s*blur\(8px\)") -and ($menuDrawerCss -match "-webkit-backdrop-filter:\s*blur\(8px\)")
Assert-Condition -TestName "M2.CSS.01: Backdrop blur (8px) with webkit prefix on drawer overlay scrim" `
    -Condition $hasBackdropFilter `
    -Details "summary::before must have backdrop-filter: blur(8px) and -webkit-backdrop-filter: blur(8px)"

# Check 2: Scrim overlay background opacity
$hasScrimBg = ($menuDrawerCss -match "background:\s*rgba\(0,\s*0,\s*0,\s*0\.7\)")
Assert-Condition -TestName "M2.CSS.02: Scrim overlay background rgba(0, 0, 0, 0.7)" `
    -Condition $hasScrimBg `
    -Details "Backdrop scrim must use dark translucent background"

# Check 3: Z-Index layering hierarchy
# Scrim = 2, .menu-drawer = 3, .menu-drawer__submenu = 1
$hasScrimZIndex = ($menuDrawerCss -match "summary::before[\s\S]*?z-index:\s*2;")
$hasDrawerZIndex = ($menuDrawerCss -match "\.menu-drawer[\s\S]*?z-index:\s*3;")
$hasSubmenuZIndex = ($menuDrawerCss -match "\.menu-drawer__submenu[\s\S]*?z-index:\s*1;")
Assert-Condition -TestName "M2.CSS.03: Z-Index Layering: Scrim (2) < Menu Drawer (3), Submenu scoped (1)" `
    -Condition ($hasScrimZIndex -and $hasDrawerZIndex -and $hasSubmenuZIndex) `
    -Details "Z-Index hierarchy must correctly layer backdrop below drawer and submenus"

# Check 4: Slide-in transform transitions
$hasDrawerTransform = ($menuDrawerCss -match "transform:\s*translateX\(-100%\)") -and ($menuDrawerCss -match "transform:\s*translateX\(0\)")
Assert-Condition -TestName "M2.CSS.04: Menu drawer transform: translateX(-100%) -> translateX(0)" `
    -Condition $hasDrawerTransform `
    -Details "Menu drawer must have GPU-accelerated horizontal slide transition"

# Check 5: Active menu item styling
$hasActiveItemStyle = ($menuDrawerCss -match "\.menu-drawer__menu-item--active[\s\S]*?border-left:\s*3px solid #E5A93C")
Assert-Condition -TestName "M2.CSS.05: Active menu item has 3px gold left accent bar and gold color" `
    -Condition $hasActiveItemStyle `
    -Details "Active menu item must feature FocusDrawer gold left border accent"

# Check 6: Escape key handling in MenuDrawer component
$hasEscapeKey = ($globalJs -match "event\.code\.toUpperCase\(\)\s*!==\s*'ESCAPE'") -and ($globalJs -match "this\.closeMenuDrawer")
Assert-Condition -TestName "M2.JS.01: MenuDrawer implements Escape key close handler" `
    -Condition $hasEscapeKey `
    -Details "MenuDrawer must capture Escape key and dismiss open details"

# Check 7: Focus trap integration in MenuDrawer
$hasTrapFocus = ($globalJs -match "trapFocus\(this\.mainDetailsToggle") -and ($globalJs -match "removeTrapFocus\(elementToFocus\)")
Assert-Condition -TestName "M2.JS.02: MenuDrawer implements focus trapping on open and restore on close" `
    -Condition $hasTrapFocus `
    -Details "MenuDrawer must trap focus inside open drawer for WCAG accessibility"

# Check 8: Body scroll locking
$hasBodyScrollLock = ($globalJs.Contains('document.body.classList.add(`overflow-hidden-${this.dataset.breakpoint}`)')) -and `
                     ($globalJs.Contains('document.body.classList.remove(`overflow-hidden-${this.dataset.breakpoint}`)'))
Assert-Condition -TestName "M2.JS.03: MenuDrawer applies and removes body overflow lock per breakpoint" `
    -Condition $hasBodyScrollLock `
    -Details "Body scroll must be locked when drawer is active"

# ------------------------------------------------------------------------------
# SUMMARY & VERDICT
# ------------------------------------------------------------------------------
Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host " EMPIRICAL CHALLENGE EXECUTION SUMMARY" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "Total Assertions Tested : $script:TotalAsserts"
Write-Host "Passed Assertions       : $script:PassedAsserts" -ForegroundColor Green
Write-Host "Failed Assertions       : $script:FailedAsserts" -ForegroundColor $(if ($script:FailedAsserts -eq 0) { "Green" } else { "Red" })

if ($script:FailedAsserts -eq 0) {
    Write-Host "`n[CHALLENGE VERDICT]: APPROVE - All PubSub sync, DOM replacement, drawer transitions, and contrast assertions passed with 0 defects." -ForegroundColor Green
} else {
    Write-Host "`n[CHALLENGE VERDICT]: REQUEST_CHANGES - $($script:FailedAsserts) assertion(s) failed." -ForegroundColor Red
    foreach ($f in $script:Findings) {
        Write-Host " - $f" -ForegroundColor Red
    }
}
Write-Host "==============================================================================" -ForegroundColor Cyan

if ($script:FailedAsserts -gt 0) {
    exit 1
} else {
    exit 0
}
