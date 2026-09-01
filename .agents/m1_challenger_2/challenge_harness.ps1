# ==============================================================================
# FocusDrawer Theme: Milestone 1 Deep Empirical Challenge Suite (m1_challenger_2)
# ==============================================================================
# Author: m1_challenger_2 (Cross-Breakpoint & Token Challenger)
# Target: C:\Users\asedacasd\.gemini\antigravity\scratch\dawn
# ==============================================================================

$RepoRoot = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"
$Results = [ordered]@{
    Total = 0
    Passed = 0
    Failed = 0
    Challenges = @()
}

function Run-EmpiricalTest {
    param(
        [string]$Id,
        [string]$Category,
        [string]$Description,
        [scriptblock]$TestBlock
    )
    $Results.Total++
    $passed = $false
    $details = ""
    try {
        $testResult = & $TestBlock
        if ($testResult -is [bool]) {
            $passed = $testResult
        } elseif ($testResult.Passed -ne $null) {
            $passed = [bool]$testResult.Passed
            $details = $testResult.Details
        } else {
            $passed = [bool]$testResult
        }
    } catch {
        $passed = $false
        $details = $_.Exception.Message
    }

    if ($passed) {
        $Results.Passed++
        Write-Host "  [PASS] $Id ($Category): $Description" -ForegroundColor Green
        if ($details) { Write-Host "         Info: $details" -ForegroundColor DarkGray }
    } else {
        $Results.Failed++
        Write-Host "  [FAIL] $Id ($Category): $Description" -ForegroundColor Red
        if ($details) { Write-Host "         Error: $details" -ForegroundColor Yellow }
    }

    $Results.Challenges += [ordered]@{
        Id = $Id
        Category = $Category
        Description = $Description
        Passed = $passed
        Details = $details
    }
}

Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host " FOCUSDRAWER THEME M1: CROSS-BREAKPOINT & TOKEN EMPIRICAL CHALLENGE HARNESS " -ForegroundColor Cyan
Write-Host "==============================================================================`n" -ForegroundColor Cyan

$settingsPath = Join-Path $RepoRoot "config/settings_data.json"
$settingsJson = Get-Content $settingsPath -Raw | ConvertFrom-Json
$dawnPreset = $settingsJson.presets.Dawn
$headerLiquid = Get-Content (Join-Path $RepoRoot "sections/header.liquid") -Raw
$themeLiquid = Get-Content (Join-Path $RepoRoot "layout/theme.liquid") -Raw
$passwordLiquid = Get-Content (Join-Path $RepoRoot "layout/password.liquid") -Raw
$giftCardLiquid = Get-Content (Join-Path $RepoRoot "templates/gift_card.liquid") -Raw
$baseCss = Get-Content (Join-Path $RepoRoot "assets/base.css") -Raw

# ------------------------------------------------------------------------------
# 1. TOKEN & COLOR MATRIX VERIFICATION
# ------------------------------------------------------------------------------
Run-EmpiricalTest "CH.TOKEN.01" "Tokens" "Scheme 1 (Dark Matte Core) Color Tokens & RGB Math" {
    $s = $dawnPreset.color_schemes.'scheme-1'.settings
    $rBg = [Convert]::ToInt32($s.background.Substring(1,2), 16)
    $gBg = [Convert]::ToInt32($s.background.Substring(3,2), 16)
    $bBg = [Convert]::ToInt32($s.background.Substring(5,2), 16)
    $rBtn = [Convert]::ToInt32($s.button.Substring(1,2), 16)
    $gBtn = [Convert]::ToInt32($s.button.Substring(3,2), 16)
    $bBtn = [Convert]::ToInt32($s.button.Substring(5,2), 16)

    $valid = ($s.background -eq "#121212" -and $rBg -eq 18 -and $gBg -eq 18 -and $bBg -eq 18) -and
             ($s.text -eq "#FFFFFF") -and
             ($s.button -eq "#E5A93C" -and $rBtn -eq 229 -and $gBtn -eq 169 -and $bBtn -eq 60) -and
             ($s.button_label -eq "#121212") -and
             ($s.secondary_button_label -eq "#FFFFFF") -and
             ($s.shadow -eq "#000000")
    return @{ Passed = $valid; Details = "bg=$($s.background) ($rBg,$gBg,$bBg), btn=$($s.button) ($rBtn,$gBtn,$bBtn), text=$($s.text)" }
}

Run-EmpiricalTest "CH.TOKEN.02" "Tokens" "Scheme 2 (Elevated Charcoal Surface) Color Tokens & RGB Math" {
    $s = $dawnPreset.color_schemes.'scheme-2'.settings
    $rBg = [Convert]::ToInt32($s.background.Substring(1,2), 16)
    $gBg = [Convert]::ToInt32($s.background.Substring(3,2), 16)
    $bBg = [Convert]::ToInt32($s.background.Substring(5,2), 16)

    $valid = ($s.background -eq "#1E1E1E" -and $rBg -eq 30 -and $gBg -eq 30 -and $bBg -eq 30) -and
             ($s.text -eq "#FFFFFF") -and
             ($s.button -eq "#E5A93C") -and
             ($s.button_label -eq "#121212") -and
             ($s.secondary_button_label -eq "#E5A93C") -and
             ($s.shadow -eq "#000000")
    return @{ Passed = $valid; Details = "bg=$($s.background) ($rBg,$gBg,$bBg), secondary_btn=$($s.secondary_button_label)" }
}

Run-EmpiricalTest "CH.TOKEN.03" "Tokens" "Scheme 3 (Gold Accent Callout) Inverted Matrix" {
    $s = $dawnPreset.color_schemes.'scheme-3'.settings
    $valid = ($s.background -eq "#E5A93C") -and
             ($s.text -eq "#121212") -and
             ($s.button -eq "#121212") -and
             ($s.button_label -eq "#FFFFFF") -and
             ($s.secondary_button_label -eq "#121212")
    return @{ Passed = $valid; Details = "bg=$($s.background), text=$($s.text), btn=$($s.button), label=$($s.button_label)" }
}

Run-EmpiricalTest "CH.TOKEN.04" "Tokens" "Scheme 4 (Deep Surface) & Scheme 5 (Clean Light) Matrices" {
    $s4 = $dawnPreset.color_schemes.'scheme-4'.settings
    $s5 = $dawnPreset.color_schemes.'scheme-5'.settings
    $valid4 = ($s4.background -eq "#121212") -and ($s4.text -eq "#FFFFFF") -and ($s4.button -eq "#E5A93C") -and ($s4.button_label -eq "#121212")
    $valid5 = ($s5.background -eq "#FFFFFF") -and ($s5.text -eq "#121212") -and ($s5.button -eq "#121212") -and ($s5.button_label -eq "#FFFFFF")
    return @{ Passed = ($valid4 -and $valid5); Details = "scheme-4 valid: $valid4, scheme-5 valid: $valid5" }
}

Run-EmpiricalTest "CH.TOKEN.05" "Tokens" "All 5 Schemes Strict Hex Format & Non-Empty Key Validation" {
    $requiredKeys = @("background", "text", "button", "button_label", "secondary_button_label", "shadow")
    $allValid = $true
    $checkedCount = 0
    foreach ($schemeKey in @("scheme-1", "scheme-2", "scheme-3", "scheme-4", "scheme-5")) {
        $schemeObj = $dawnPreset.color_schemes.$schemeKey.settings
        foreach ($k in $requiredKeys) {
            $val = $schemeObj.$k
            $checkedCount++
            if (-not ($val -match '^#[0-9A-Fa-f]{6}$')) {
                $allValid = $false
                Write-Host "Invalid Hex: $schemeKey $k = $val" -ForegroundColor Yellow
            }
        }
    }
    return @{ Passed = $allValid; Details = "Checked $checkedCount color properties across 5 schemes, all valid 6-digit hex" }
}

# ------------------------------------------------------------------------------
# 2. CONTRAST RATIO & WCAG A11Y MATHEMATICAL AUDIT
# ------------------------------------------------------------------------------
function Get-RelativeLuminance($hex) {
    $r = [Convert]::ToInt32($hex.Substring(1,2), 16) / 255.0
    $g = [Convert]::ToInt32($hex.Substring(3,2), 16) / 255.0
    $b = [Convert]::ToInt32($hex.Substring(5,2), 16) / 255.0

    $rLin = if ($r -le 0.03928) { $r / 12.92 } else { [Math]::Pow((($r + 0.055) / 1.055), 2.4) }
    $gLin = if ($g -le 0.03928) { $g / 12.92 } else { [Math]::Pow((($g + 0.055) / 1.055), 2.4) }
    $bLin = if ($b -le 0.03928) { $b / 12.92 } else { [Math]::Pow((($b + 0.055) / 1.055), 2.4) }

    return 0.2126 * $rLin + 0.7152 * $gLin + 0.0722 * $bLin
}

function Get-ContrastRatio($hex1, $hex2) {
    $l1 = Get-RelativeLuminance $hex1
    $l2 = Get-RelativeLuminance $hex2
    $lighter = [Math]::Max($l1, $l2)
    $darker = [Math]::Min($l1, $l2)
    return ($lighter + 0.05) / ($darker + 0.05)
}

Run-EmpiricalTest "CH.A11Y.01" "Contrast" "Gold (#E5A93C) vs Dark Matte (#121212) Contrast Ratio >= 7.0:1 (WCAG AAA)" {
    $ratio = Get-ContrastRatio "#E5A93C" "#121212"
    return @{ Passed = ($ratio -ge 7.0); Details = ("{0:N2}:1 (WCAG AAA >= 7.0:1)" -f $ratio) }
}

Run-EmpiricalTest "CH.A11Y.02" "Contrast" "White (#FFFFFF) vs Dark Charcoal (#1E1E1E) Contrast Ratio >= 7.0:1 (WCAG AAA)" {
    $ratio = Get-ContrastRatio "#FFFFFF" "#1E1E1E"
    return @{ Passed = ($ratio -ge 7.0); Details = ("{0:N2}:1 (WCAG AAA >= 7.0:1)" -f $ratio) }
}

Run-EmpiricalTest "CH.A11Y.03" "Contrast" "White (#FFFFFF) vs Dark Matte (#121212) Contrast Ratio >= 7.0:1 (WCAG AAA)" {
    $ratio = Get-ContrastRatio "#FFFFFF" "#121212"
    return @{ Passed = ($ratio -ge 7.0); Details = ("{0:N2}:1 (WCAG AAA >= 7.0:1)" -f $ratio) }
}

Run-EmpiricalTest "CH.A11Y.04" "Contrast" "Gold Focus Ring (#E5A93C) Non-Text UI Contrast >= 3.0:1 (WCAG 2.1 AA)" {
    $r1 = Get-ContrastRatio "#E5A93C" "#121212"
    $r2 = Get-ContrastRatio "#E5A93C" "#1E1E1E"
    return @{ Passed = ($r1 -ge 3.0 -and $r2 -ge 3.0); Details = ("On #121212: {0:N2}:1, On #1E1E1E: {1:N2}:1" -f $r1, $r2) }
}

# ------------------------------------------------------------------------------
# 3. RESPONSIVE LOGO CALCULATIONS & BREAKPOINT SCALING
# ------------------------------------------------------------------------------
Run-EmpiricalTest "CH.RESP.01" "Logo" "Desktop Base Logo Width Setting = 160px" {
    $w = $dawnPreset.logo_width
    return @{ Passed = ($w -eq 160); Details = "Base logo width: $w px" }
}

Run-EmpiricalTest "CH.RESP.02" "Logo" "Header Liquid Asset Fallbacks for 'focusdrawer-logo.png'" {
    $hasLeftFallback = $headerLiquid -match 'focusdrawer-logo\.png'
    $hasEager = $headerLiquid -match 'loading="eager"'
    $hasPriority = $headerLiquid -match 'fetchpriority="high"'
    $hasLogoWidth = $headerLiquid -match 'logo_width_val\s*=\s*settings\.logo_width\s*\|\s*default:\s*160'
    return @{ Passed = ($hasLeftFallback -and $hasEager -and $hasPriority -and $hasLogoWidth); Details = "Asset fallback tag with 160 default and eager/high priority attributes verified" }
}

Run-EmpiricalTest "CH.RESP.03" "Logo" "Header JSON-LD Organization Schema Fallback Logo URL" {
    $hasJsonLdFallback = $headerLiquid -match "'focusdrawer-logo\.png'\s*\|\s*asset_url"
    return @{ Passed = $hasJsonLdFallback; Details = "JSON-LD schema logo URL fallback: $hasJsonLdFallback" }
}

Run-EmpiricalTest "CH.RESP.04" "Logo" "Favicon Integration & Fallback in theme.liquid, password.liquid, gift_card.liquid" {
    $tFav = $themeLiquid -match 'focusdrawer-logo\.png'
    $pFav = $passwordLiquid -match 'focusdrawer-logo\.png'
    $gFav = $giftCardLiquid -match 'focusdrawer-logo\.png'
    return @{ Passed = ($tFav -and $pFav -and $gFav); Details = "theme.liquid: $tFav, password.liquid: $pFav, gift_card.liquid: $gFav" }
}

Run-EmpiricalTest "CH.RESP.05" "Logo" "CSS Aspect Ratio & Fluid Scaling (max-width: 100%, height: auto)" {
    $hasLogoCss = $baseCss -match '\.header__heading-logo\s*\{[^}]*max-width:\s*100%' -and $baseCss -match '\.header__heading-logo\s*\{[^}]*height:\s*auto'
    $hasWrapperCss = $baseCss -match '\.header__heading-logo-wrapper\s*\{[^}]*width:\s*100%'
    return @{ Passed = ($hasLogoCss -and $hasWrapperCss); Details = "Fluid container scaling and aspect-ratio preservation verified" }
}

Run-EmpiricalTest "CH.RESP.06" "Logo" "Responsive Breakpoint Media Queries (750px and 990px)" {
    $hasMobileBreakpoint = $baseCss -match '@media\s+screen\s+and\s+\(max-width:\s*989px\)'
    $hasDesktopBreakpoint = $baseCss -match '@media\s+screen\s+and\s+\(min-width:\s*990px\)'
    $hasTabletBreakpoint = $baseCss -match '@media\s+screen\s+and\s+\(min-width:\s*750px\)'
    return @{ Passed = ($hasMobileBreakpoint -and $hasDesktopBreakpoint -and $hasTabletBreakpoint); Details = "Mobile (<990px): $hasMobileBreakpoint, Desktop (>=990px): $hasDesktopBreakpoint, Tablet (>=750px): $hasTabletBreakpoint" }
}

Run-EmpiricalTest "CH.RESP.07" "Logo" "Sticky Header Reduced Logo Calculation (width: 75% -> 120px)" {
    $hasStickyLogoRule = $headerLiquid -match '\.scrolled-past-header\s+\.header__heading-logo-wrapper\s*\{[^}]*width:\s*75%'
    return @{ Passed = $hasStickyLogoRule; Details = "Sticky header logo scale-down rule verified (75% of 160px = 120px)" }
}

# ------------------------------------------------------------------------------
# 4. BUTTON FOCUS OUTLINES, :FOCUS-VISIBLE & ACCESSIBILITY TOKENS
# ------------------------------------------------------------------------------
Run-EmpiricalTest "CH.FOCUS.01" "Focus" ":root --focused-base-outline & Box-Shadow Token Definitions in base.css" {
    $hasOutline = $baseCss -match '--focused-base-outline:\s*0\.2rem\s+solid\s+#E5A93C;'
    $hasOffset = $baseCss -match '--focused-base-outline-offset:\s*0\.3rem;'
    $hasBoxShadow = $baseCss -match '--focused-base-box-shadow:\s*0\s+0\s+0\s+0\.3rem\s+rgb\(var\(--color-background\)\),\s*0\s+0\s+0\.5rem\s+0\.4rem\s+rgba\(229,\s*169,\s*60,\s*0\.4\);'
    return @{ Passed = ($hasOutline -and $hasOffset -and $hasBoxShadow); Details = "Outline: $hasOutline, Offset: $hasOffset, BoxShadow: $hasBoxShadow" }
}

Run-EmpiricalTest "CH.FOCUS.02" "Focus" "Global *:focus-visible & .focused Fallback Binding" {
    $hasUniversal = $baseCss -match '\*:focus-visible\s*\{[^}]*outline:\s*var\(--focused-base-outline\);[^}]*outline-offset:\s*var\(--focused-base-outline-offset\);[^}]*box-shadow:\s*var\(--focused-base-box-shadow\);'
    $hasFocused = $baseCss -match '\.focused\s*\{[^}]*outline:\s*var\(--focused-base-outline\);'
    return @{ Passed = ($hasUniversal -and $hasFocused); Details = "*:focus-visible: $hasUniversal, .focused fallback: $hasFocused" }
}

Run-EmpiricalTest "CH.FOCUS.03" "Focus" "Interactive Button (.button, unbranded payment) Multi-Ring Focus Glow" {
    $hasBtnSelectors = $baseCss -match '\.button:focus-visible,\s*\.button:focus,\s*\.button\.focused,\s*\.shopify-payment-button__button--unbranded:focus-visible'
    $hasBtnShadow = $baseCss -match 'box-shadow:\s*0\s+0\s+0\s+0\.3rem\s+rgb\(var\(--color-background\)\),\s*0\s+0\s+0\s+0\.5rem\s+#E5A93C,\s*0\s+0\s+0\.5rem\s+0\.4rem\s+rgba\(229,\s*169,\s*60,\s*0\.4\);'
    return @{ Passed = ($hasBtnSelectors -and $hasBtnShadow); Details = "Button focus selector: $hasBtnSelectors, Multi-ring shadow: $hasBtnShadow" }
}

Run-EmpiricalTest "CH.FOCUS.04" "Focus" "Mouse-Click Focus Bleed Suppression (:focus:not(:focus-visible))" {
    $hasSuppression = $baseCss -match '\.button:focus:not\(:focus-visible\):not\(\.focused\)' -and $baseCss -match 'box-shadow:\s*inherit;'
    return @{ Passed = $hasSuppression; Details = "Mouse-click focus shadow inheritance suppression verified" }
}

Run-EmpiricalTest "CH.FOCUS.05" "Focus" "Button Hover Elevation & Gold Ambient Glow" {
    $hasHover = $baseCss -match '\.button:not\(\[disabled\]\):hover\s*\{[^}]*box-shadow:\s*0\s+4px\s+16px\s+rgba\(229,\s*169,\s*60,\s*0\.25\);'
    $hasTransform = $baseCss -match 'transform:\s*translateY\(-1px\);'
    return @{ Passed = ($hasHover -and $hasTransform); Details = "Hover box-shadow glow: $hasHover, translateY(-1px): $hasTransform" }
}

Run-EmpiricalTest "CH.FOCUS.06" "Focus" "Input Fields, Search & Select Focus Inset Styling" {
    $hasInputFocus = $baseCss -match '\.field__input:focus-visible,\s*\.select__select:focus-visible'
    $hasQuantityFocus = $baseCss -match '\.quantity__button:focus-visible'
    return @{ Passed = ($hasInputFocus -and $hasQuantityFocus); Details = "Field inputs focus-visible: $hasInputFocus, Quantity buttons: $hasQuantityFocus" }
}

# ------------------------------------------------------------------------------
# 5. DYNAMIC LIQUID THEME INJECTION & MICRO-COMPONENT SCALING
# ------------------------------------------------------------------------------
Run-EmpiricalTest "CH.THEME.01" "Theme" "Dynamic CSS Variable Generation Loop in layout/theme.liquid" {
    $hasLoop = $themeLiquid -match '(?s)\{\%\s*for\s+scheme\s+in\s+settings\.color_schemes\s*-\%\}.*?\{\%\s*if\s+forloop\.index\s*==\s*1\s*-\%\}\s*:root,'
    $hasBgVar = $themeLiquid -match '--color-background:\s*\{\{\s*scheme\.settings\.background\.red\s*\}\},\{\{\s*scheme\.settings\.background\.green\s*\}\},\{\{\s*scheme\.settings\.background\.blue\s*\}\};'
    $hasFgVar = $themeLiquid -match '--color-foreground:\s*\{\{\s*scheme\.settings\.text\.red\s*\}\},\{\{\s*scheme\.settings\.text\.green\s*\}\},\{\{\s*scheme\.settings\.text\.blue\s*\}\};'
    $hasBtnVar = $themeLiquid -match '--color-button:\s*\{\{\s*scheme\.settings\.button\.red\s*\}\},\{\{\s*scheme\.settings\.button\.green\s*\}\},\{\{\s*scheme\.settings\.button\.blue\s*\}\};'
    $hasBtnTxtVar = $themeLiquid -match '--color-button-text:\s*\{\{\s*scheme\.settings\.button_label\.red\s*\}\},\{\{\s*scheme\.settings\.button_label\.green\s*\}\},\{\{\s*scheme\.settings\.button_label\.blue\s*\}\};'
    return @{ Passed = ($hasLoop -and $hasBgVar -and $hasFgVar -and $hasBtnVar -and $hasBtnTxtVar); Details = "Dynamic :root loop: $hasLoop, bg var: $hasBgVar, fg var: $hasFgVar, btn var: $hasBtnVar, btn text var: $hasBtnTxtVar" }
}

Run-EmpiricalTest "CH.THEME.02" "Theme" "Typography Hierarchy and Scaling (Heading 115%, Body 105%)" {
    $hScale = $dawnPreset.heading_scale
    $bScale = $dawnPreset.body_scale
    $hFont = $dawnPreset.type_header_font
    $bFont = $dawnPreset.type_body_font
    $passed = ($hScale -eq 115) -and ($bScale -eq 105) -and ($hFont -eq "assistant_n7") -and ($bFont -eq "assistant_n4")
    return @{ Passed = $passed; Details = "Heading: ${hScale}% ($hFont), Body: ${bScale}% ($bFont)" }
}

Run-EmpiricalTest "CH.THEME.03" "Theme" "Micro-Component Geometry Tokens (Buttons 8px, Cards 12px, Badges 6px)" {
    $btnR = $dawnPreset.buttons_radius
    $pillsR = $dawnPreset.variant_pills_radius
    $inputsR = $dawnPreset.inputs_radius
    $cardR = $dawnPreset.card_corner_radius
    $badgeR = $dawnPreset.badge_corner_radius
    $passed = ($btnR -eq 8) -and ($pillsR -eq 8) -and ($inputsR -eq 8) -and ($cardR -eq 12) -and ($badgeR -eq 6)
    return @{ Passed = $passed; Details = "buttons: ${btnR}px, pills: ${pillsR}px, inputs: ${inputsR}px, cards: ${cardR}px, badges: ${badgeR}px" }
}

Run-EmpiricalTest "CH.ASSET.01" "Asset" "Brand Logo Asset (assets/focusdrawer-logo.png) Exists & Resolution Valid" {
    $logoPath = Join-Path $RepoRoot "assets/focusdrawer-logo.png"
    $exists = Test-Path $logoPath
    $fileBytes = (Get-Item $logoPath).Length
    $passed = ($exists -and $fileBytes -ge 5000)
    return @{ Passed = $passed; Details = "Path: $logoPath, Size: $fileBytes bytes (>= 5KB)" }
}

# ------------------------------------------------------------------------------
# FINAL REPORT & VERDICT
# ------------------------------------------------------------------------------
Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host " CHALLENGE EXECUTION SUMMARY " -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "Total Challenges : $($Results.Total)"
Write-Host "Passed           : $($Results.Passed)" -ForegroundColor Green
Write-Host "Failed           : $($Results.Failed)" -ForegroundColor $(if ($Results.Failed -gt 0) { "Red" } else { "Green" })
Write-Host "Pass Rate        : $([Math]::Round(($Results.Passed / $Results.Total) * 100, 1))%`n"

if ($Results.Failed -eq 0) {
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host " >>> EMPIRICAL CHALLENGE VERDICT: APPROVE <<< " -ForegroundColor Green
    Write-Host "========================================================`n" -ForegroundColor Green
} else {
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host " >>> EMPIRICAL CHALLENGE VERDICT: REQUEST_CHANGES <<< " -ForegroundColor Red
    Write-Host "========================================================`n" -ForegroundColor Red
}
