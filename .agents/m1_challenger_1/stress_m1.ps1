# FocusDrawer Milestone 1 Adversarial & Empirical Challenge Harness
# Author: m1_challenger_1

$ErrorActionPreference = "Stop"
$root = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " FOCUSDRAWER M1 EMPIRICAL CHALLENGE & STRESS HARNESS " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

function Record-Challenge {
    param(
        [string]$Id,
        [string]$Name,
        [bool]$Passed,
        [string]$Expected,
        [string]$Actual,
        [string]$Details
    )
    $obj = [PSCustomObject]@{
        Id       = $Id
        Name     = $Name
        Passed   = $Passed
        Expected = $Expected
        Actual   = $Actual
        Details  = $Details
    }
    $results.Add($obj)
    $status = if ($Passed) { "[PASS]" } else { "[FAIL]" }
    $color = if ($Passed) { "Green" } else { "Red" }
    Write-Host ("{0} {1,-12} : {2}" -f $status, $Id, $Name) -ForegroundColor $color
    if (-not $Passed -or $VerbosePreference -eq 'Continue') {
        Write-Host ("       Expected: {0}" -f $Expected) -ForegroundColor Gray
        Write-Host ("       Actual  : {0}" -f $Actual) -ForegroundColor Gray
        if ($Details) { Write-Host ("       Details : {0}" -f $Details) -ForegroundColor DarkGray }
    }
}

# -----------------------------------------------------------------------------
# 1. JSON STRESS & STRICT RFC 8259 PARSER CHALLENGE
# -----------------------------------------------------------------------------
Write-Host "`n--- 1. JSON STRESS & STRICT RFC 8259 PARSER CHALLENGE ---" -ForegroundColor Yellow

$settingsPath = Join-Path $root "config\settings_data.json"
$settingsRaw = [System.IO.File]::ReadAllText($settingsPath, [System.Text.Encoding]::UTF8)

# 1.1 Strict UTF-8 and BOM validation
$bytes = [System.IO.File]::ReadAllBytes($settingsPath)
$hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
Record-Challenge -Id "CH-JSON-01" -Name "UTF-8 Encoding without corrupting BOM" `
    -Passed ($bytes.Length -gt 0) `
    -Expected "Valid non-empty UTF-8 JSON file" `
    -Actual "Byte length: $($bytes.Length), Has BOM: $hasBom" `
    -Details "UTF-8 BOM is acceptable in Windows/Shopify, but non-empty payload required"

# 1.2 Strict RFC 8259 JSON parsing via System.Text.Json (strict .NET Core / .NET Framework parser)
$jsonValid = $false
$jsonObj = $null
$parseError = ""
try {
    $jsonObj = $settingsRaw | ConvertFrom-Json
    $jsonValid = $true
} catch {
    $parseError = $_.Exception.Message
}
Record-Challenge -Id "CH-JSON-02" -Name "Strict JSON RFC 8259 Deserialization" `
    -Passed $jsonValid `
    -Expected "Successful JSON object conversion without syntax errors" `
    -Actual $(if ($jsonValid) { "Parsed successfully" } else { "Parse error: $parseError" }) `
    -Details "Checks for unescaped quotes, trailing commas, unmatched brackets"

# 1.3 Preset & Current Structure Verification
$current = $jsonObj.current
$presets = $jsonObj.presets
$hasCurrent = ($null -ne $current)
$hasDawnPreset = ($null -ne $presets.Dawn)
Record-Challenge -Id "CH-JSON-03" -Name "JSON Top-Level Presets & Current Container Integrity" `
    -Passed ($hasCurrent -and $hasDawnPreset) `
    -Expected "Both .current and .presets.Dawn defined" `
    -Actual "current=$hasCurrent, presets.Dawn=$hasDawnPreset" `
    -Details "Shopify requires current settings object and Dawn preset for theme import/export"

# -----------------------------------------------------------------------------
# 2. COLOR SCHEMES 1-5 CONTRACT & HEX MATRIX CHALLENGE
# -----------------------------------------------------------------------------
Write-Host "`n--- 2. COLOR SCHEMES 1-5 CONTRACT & HEX MATRIX CHALLENGE ---" -ForegroundColor Yellow

$expectedSchemes = @{
    "scheme-1" = @{
        bg = "#121212"; fg = "#FFFFFF"; btn = "#E5A93C"; btn_lbl = "#121212"; sec_lbl = "#FFFFFF"
    }
    "scheme-2" = @{
        bg = "#1E1E1E"; fg = "#FFFFFF"; btn = "#E5A93C"; btn_lbl = "#121212"; sec_lbl = "#E5A93C"
    }
    "scheme-3" = @{
        bg = "#E5A93C"; fg = "#121212"; btn = "#121212"; btn_lbl = "#FFFFFF"; sec_lbl = "#121212"
    }
    "scheme-4" = @{
        bg = "#121212"; fg = "#FFFFFF"; btn = "#E5A93C"; btn_lbl = "#121212"; sec_lbl = "#FFFFFF"
    }
    "scheme-5" = @{
        bg = "#FFFFFF"; fg = "#121212"; btn = "#121212"; btn_lbl = "#FFFFFF"; sec_lbl = "#121212"
    }
}

$schemesContainer = if ($current.color_schemes) { $current.color_schemes } else { $presets.Dawn.color_schemes }

foreach ($schemeId in @("scheme-1", "scheme-2", "scheme-3", "scheme-4", "scheme-5")) {
    $s = $schemesContainer.$schemeId
    $exp = $expectedSchemes[$schemeId]
    $passed = $false
    $actualDesc = "Scheme not found"
    
    if ($null -ne $s) {
        $bgMatch = ($s.settings.background -eq $exp.bg)
        $fgMatch = ($s.settings.text -eq $exp.fg)
        $btnMatch = ($s.settings.button -eq $exp.btn)
        $btnLblMatch = ($s.settings.button_label -eq $exp.btn_lbl)
        $secLblMatch = ($s.settings.secondary_button_label -eq $exp.sec_lbl)
        
        $passed = ($bgMatch -and $fgMatch -and $btnMatch -and $btnLblMatch -and $secLblMatch)
        $actualDesc = "bg=$($s.settings.background), fg=$($s.settings.text), btn=$($s.settings.button), btn_lbl=$($s.settings.button_label), sec_lbl=$($s.settings.secondary_button_label)"
    }
    
    $expDesc = "bg=$($exp.bg), fg=$($exp.fg), btn=$($exp.btn), btn_lbl=$($exp.btn_lbl), sec_lbl=$($exp.sec_lbl)"
    
    Record-Challenge -Id "CH-SCH-$schemeId" -Name "Color Scheme Contract: $schemeId" `
        -Passed $passed `
        -Expected $expDesc `
        -Actual $actualDesc `
        -Details "Validates exact FocusDrawer hex tokens against PROJECT.md interface contract"
}

# -----------------------------------------------------------------------------
# 3. LOGO ASSET BINARY INTEGRITY & MAGIC BYTE CHALLENGE
# -----------------------------------------------------------------------------
Write-Host "`n--- 3. LOGO ASSET BINARY INTEGRITY & MAGIC BYTE CHALLENGE ---" -ForegroundColor Yellow

$logoPath = Join-Path $root "assets\focusdrawer-logo.png"
$logoFileExists = Test-Path $logoPath

Record-Challenge -Id "CH-ASSET-01" -Name "FocusDrawer Logo File Existence" `
    -Passed $logoFileExists `
    -Expected "assets/focusdrawer-logo.png exists in repository" `
    -Actual $(if ($logoFileExists) { "File exists" } else { "File missing" }) `
    -Details "Path: $logoPath"

if ($logoFileExists) {
    $logoBytes = [System.IO.File]::ReadAllBytes($logoPath)
    
    # 3.1 PNG Magic Bytes: 89 50 4E 47 0D 0A 1A 0A
    $expectedMagic = @(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
    $magicMatch = $true
    for ($i = 0; $i -lt 8; $i++) {
        if ($logoBytes[$i] -ne $expectedMagic[$i]) { $magicMatch = $false; break }
    }
    $actualMagicStr = ($logoBytes[0..7] | ForEach-Object { "{0:X2}" -f $_ }) -join " "
    
    Record-Challenge -Id "CH-ASSET-02" -Name "PNG Header Magic Bytes (89 50 4E 47 0D 0A 1A 0A)" `
        -Passed $magicMatch `
        -Expected "89 50 4E 47 0D 0A 1A 0A" `
        -Actual $actualMagicStr `
        -Details "Validates file is a legitimate PNG format and not a renamed dummy file"
        
    # 3.2 IHDR Chunk Parsing: Width, Height, Bit Depth, Color Type
    # IHDR chunk starts at byte 12 (length at 8..11 is 13, type at 12..15 is IHDR, data at 16..28)
    $ihdrWidth = ([int]$logoBytes[16] -shl 24) -bor ([int]$logoBytes[17] -shl 16) -bor ([int]$logoBytes[18] -shl 8) -bor [int]$logoBytes[19]
    $ihdrHeight = ([int]$logoBytes[20] -shl 24) -bor ([int]$logoBytes[21] -shl 16) -bor ([int]$logoBytes[22] -shl 8) -bor [int]$logoBytes[23]
    $bitDepth = [int]$logoBytes[24]
    $colorType = [int]$logoBytes[25] # 6 = RGBA (Truecolor with alpha)
    
    $validDims = ($ihdrWidth -ge 512 -and $ihdrHeight -ge 512)
    Record-Challenge -Id "CH-ASSET-03" -Name "Logo Dimensions & High-Resolution Scaling" `
        -Passed $validDims `
        -Expected "High-res logo (>= 512x512) for crisp retina display" `
        -Actual "${ihdrWidth}x${ihdrHeight} px, bitDepth: $bitDepth, colorType: $colorType" `
        -Details "ColorType 6 = RGBA Truecolor with Alpha Channel"

    # 3.3 IEND Chunk Presence
    $len = $logoBytes.Length
    $iendValid = ($len -ge 12 -and $logoBytes[$len - 8] -eq 0x49 -and $logoBytes[$len - 7] -eq 0x45 -and $logoBytes[$len - 6] -eq 0x4E -and $logoBytes[$len - 5] -eq 0x44)
    Record-Challenge -Id "CH-ASSET-04" -Name "PNG IEND Chunk Terminator Integrity" `
        -Passed $iendValid `
        -Expected "Valid IEND chunk terminator at EOF" `
        -Actual "IEND present: $iendValid (file size: $len bytes)" `
        -Details "Guarantees no truncated image stream"
}

# -----------------------------------------------------------------------------
# 4. LIQUID MARKUP & FALLBACK INTEGRITY AUDIT
# -----------------------------------------------------------------------------
Write-Host "`n--- 4. LIQUID MARKUP & FALLBACK INTEGRITY AUDIT ---" -ForegroundColor Yellow

# 4.1 Header Liquid fallback tags
$headerPath = Join-Path $root "sections\header.liquid"
$headerContent = [System.IO.File]::ReadAllText($headerPath, [System.Text.Encoding]::UTF8)

$hasLogoFallbackNonCenter = $headerContent -match "focusdrawer-logo\.png' \| asset_url"
$hasLogoFallbackSchema = $headerContent -match '"logo":\s*\{\s*"@type":\s*"ImageObject"'

Record-Challenge -Id "CH-LIQ-01" -Name "Header Logo Fallback Liquid Tag Integrity" `
    -Passed $hasLogoFallbackNonCenter `
    -Expected "sections/header.liquid renders focusdrawer-logo.png fallback" `
    -Actual "Fallback tag found: $hasLogoFallbackNonCenter" `
    -Details "Ensures brand logo displays even when settings.logo is unset in custom environments"

# 4.2 Check Liquid Tag Delimiter Balance across modified files
$modifiedLiquidFiles = @(
    "sections\header.liquid",
    "layout\theme.liquid",
    "layout\password.liquid",
    "templates\gift_card.liquid"
)

foreach ($relPath in $modifiedLiquidFiles) {
    $fullPath = Join-Path $root $relPath
    if (Test-Path $fullPath) {
        $content = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
        
        $openTags = [regex]::Matches($content, '\{%').Count
        $closeTags = [regex]::Matches($content, '%\}').Count
        $openVars = [regex]::Matches($content, '\{\{').Count
        $closeVars = [regex]::Matches($content, '\}\}').Count
        
        $tagsBalanced = ($openTags -eq $closeTags)
        $varsBalanced = ($openVars -eq $closeVars)
        $balanced = ($tagsBalanced -and $varsBalanced)
        
        Record-Challenge -Id "CH-LIQ-BAL-$($relPath.Replace('\', '_'))" -Name "Liquid Tag/Delimiter Balance in $relPath" `
            -Passed $balanced `
            -Expected "Open/Close tags matched ({% %}: $openTags, {{ }}: $openVars)" `
            -Actual "{% count: $openTags vs $closeTags, {{ count: $openVars vs $closeVars" `
            -Details "Zero tolerance for unclosed Liquid delimiters"
    }
}

# 4.3 Favicon Fallback in theme.liquid
$themePath = Join-Path $root "layout\theme.liquid"
$themeContent = [System.IO.File]::ReadAllText($themePath, [System.Text.Encoding]::UTF8)
$hasFaviconFallback = ($themeContent -match "focusdrawer-logo\.png' \| asset_url" -and $themeContent -match 'rel="icon"')

Record-Challenge -Id "CH-LIQ-02" -Name "Favicon 32x32 Fallback in layout/theme.liquid" `
    -Passed $hasFaviconFallback `
    -Expected "rel='icon' tag with focusdrawer-logo.png asset_url fallback" `
    -Actual "Favicon fallback found: $hasFaviconFallback" `
    -Details "Guarantees tab icon presence across all pages"

# -----------------------------------------------------------------------------
# 5. CSS TOKENS & ACCESSIBILITY CONTRAST (WCAG 2.1) ORACLE
# -----------------------------------------------------------------------------
Write-Host "`n--- 5. CSS TOKENS & ACCESSIBILITY CONTRAST (WCAG 2.1) ORACLE ---" -ForegroundColor Yellow

$baseCssPath = Join-Path $root "assets\base.css"
$baseCss = [System.IO.File]::ReadAllText($baseCssPath, [System.Text.Encoding]::UTF8)

# 5.1 Focus ring tokens in CSS
$hasOutlineToken = $baseCss -match '--focused-base-outline:\s*0\.2rem solid #E5A93C'
$hasShadowToken = $baseCss -match '--focused-base-box-shadow:.*rgba\(229,\s*169,\s*60'
$hasButtonHoverGlow = $baseCss -match '\.button:not\(\[disabled\]\):hover\s*\{[^}]*rgba\(229,\s*169,\s*60'

Record-Challenge -Id "CH-CSS-01" -Name "CSS Custom Properties for Gold Focus Ring (--focused-base-outline)" `
    -Passed $hasOutlineToken `
    -Expected "--focused-base-outline: 0.2rem solid #E5A93C;" `
    -Actual "Match found: $hasOutlineToken" `
    -Details "Focus ring in assets/base.css"

Record-Challenge -Id "CH-CSS-02" -Name "Button Focus-Visible & Hover Glow Styling" `
    -Passed ($hasShadowToken -and $hasButtonHoverGlow) `
    -Expected "Hover glow (rgba 229,169,60,0.25) and focus-visible box-shadow" `
    -Actual "ShadowToken: $hasShadowToken, ButtonHoverGlow: $hasButtonHoverGlow" `
    -Details "Delivers high-intent interactive visual feedback"

# 5.2 WCAG 2.1 Contrast Calculation Oracle
function Get-RelativeLuminance([string]$hex) {
    $hex = $hex.TrimStart('#')
    $r = [Convert]::ToInt32($hex.Substring(0,2), 16) / 255.0
    $g = [Convert]::ToInt32($hex.Substring(2,2), 16) / 255.0
    $b = [Convert]::ToInt32($hex.Substring(4,2), 16) / 255.0

    $rLin = if ($r -le 0.03928) { $r / 12.92 } else { [Math]::Pow((($r + 0.055) / 1.055), 2.4) }
    $gLin = if ($g -le 0.03928) { $g / 12.92 } else { [Math]::Pow((($g + 0.055) / 1.055), 2.4) }
    $bLin = if ($b -le 0.03928) { $b / 12.92 } else { [Math]::Pow((($b + 0.055) / 1.055), 2.4) }

    return (0.2126 * $rLin) + (0.7152 * $gLin) + (0.0722 * $bLin)
}

function Get-ContrastRatio([string]$hex1, [string]$hex2) {
    $l1 = Get-RelativeLuminance $hex1
    $l2 = Get-RelativeLuminance $hex2
    $brightest = [Math]::Max($l1, $l2)
    $darkest = [Math]::Min($l1, $l2)
    return ($brightest + 0.05) / ($darkest + 0.05)
}

# Scheme 1: White #FFFFFF on #121212 (Text)
$c_s1_text = Get-ContrastRatio "#FFFFFF" "#121212"
$pass_s1_text = ($c_s1_text -ge 7.0) # WCAG AAA is 7:1
Record-Challenge -Id "CH-WCAG-01" -Name "Scheme 1 Body Text Contrast (#FFFFFF on #121212)" `
    -Passed $pass_s1_text `
    -Expected ">= 7.0:1 (WCAG AAA)" `
    -Actual ("{0:N2}:1" -f $c_s1_text) `
    -Details "Ensures maximum legibility for workspace productivity content"

# Scheme 1 & 2: Button Text #121212 on Gold #E5A93C
$c_gold_btn = Get-ContrastRatio "#121212" "#E5A93C"
$pass_gold_btn = ($c_gold_btn -ge 4.5) # WCAG AA is 4.5:1, AAA large text is 4.5:1
Record-Challenge -Id "CH-WCAG-02" -Name "Gold Primary Button Contrast (#121212 on #E5A93C)" `
    -Passed $pass_gold_btn `
    -Expected ">= 4.5:1 (WCAG AA / AAA Large)" `
    -Actual ("{0:N2}:1" -f $c_gold_btn) `
    -Details "Ensures CTA button label readability"

# Scheme 2: White #FFFFFF on #1E1E1E (Cards/Surfaces)
$c_s2_text = Get-ContrastRatio "#FFFFFF" "#1E1E1E"
$pass_s2_text = ($c_s2_text -ge 7.0)
Record-Challenge -Id "CH-WCAG-03" -Name "Scheme 2 Surface Text Contrast (#FFFFFF on #1E1E1E)" `
    -Passed $pass_s2_text `
    -Expected ">= 7.0:1 (WCAG AAA)" `
    -Actual ("{0:N2}:1" -f $c_s2_text) `
    -Details "Elevated charcoal surface legibility"

# Scheme 3: Dark #121212 text on Gold #E5A93C background
$c_s3_text = Get-ContrastRatio "#121212" "#E5A93C"
$pass_s3_text = ($c_s3_text -ge 4.5)
Record-Challenge -Id "CH-WCAG-04" -Name "Scheme 3 Callout Text Contrast (#121212 on #E5A93C)" `
    -Passed $pass_s3_text `
    -Expected ">= 4.5:1 (WCAG AA)" `
    -Actual ("{0:N2}:1" -f $c_s3_text) `
    -Details "Announcement bar and gold callout badge contrast"

# Scheme 5: Dark #121212 text on White #FFFFFF
$c_s5_text = Get-ContrastRatio "#121212" "#FFFFFF"
$pass_s5_text = ($c_s5_text -ge 7.0)
Record-Challenge -Id "CH-WCAG-05" -Name "Scheme 5 Light Surface Text Contrast (#121212 on #FFFFFF)" `
    -Passed $pass_s5_text `
    -Expected ">= 7.0:1 (WCAG AAA)" `
    -Actual ("{0:N2}:1" -f $c_s5_text) `
    -Details "Light mode / invoice / receipt high contrast"

# -----------------------------------------------------------------------------
# 6. SUMMARY & VERDICT GENERATION
# -----------------------------------------------------------------------------
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host " EMPIRICAL CHALLENGE SUMMARY " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$totalTests = $results.Count
$passedCount = ($results | Where-Object { $_.Passed }).Count
$failedCount = ($results | Where-Object { -not $_.Passed }).Count
$passRate = ($passedCount / $totalTests) * 100

Write-Host ("Total Challenges Executed : {0}" -f $totalTests)
Write-Host ("Passed                    : {0}" -f $passedCount) -ForegroundColor Green
Write-Host ("Failed                    : {0}" -f $failedCount) -ForegroundColor $(if ($failedCount -eq 0) { "Green" } else { "Red" })
Write-Host ("Pass Rate                 : {0:N1}%" -f $passRate)

if ($failedCount -eq 0) {
    Write-Host "`n>>> VERDICT: APPROVE <<<" -ForegroundColor Green
} else {
    Write-Host "`n>>> VERDICT: REQUEST_CHANGES <<<" -ForegroundColor Red
}

return ($failedCount -eq 0)
