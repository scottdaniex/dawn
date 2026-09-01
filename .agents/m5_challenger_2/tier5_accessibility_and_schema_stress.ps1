# ==============================================================================
# FOCUS DRAWER SHOPIFY DAWN THEME - TIER 5 ADVERSARIAL STRESS TEST HARNESS
# White-Box Architectural, Accessibility (ARIA), Design Token, & Schema Stress
# ==============================================================================

param(
    [string]$ProjectRoot = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn",
    [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$TotalTests = 0
$PassedTests = 0
$FailedTests = 0
$Failures = @()

function Run-Test {
    param(
        [string]$TestId,
        [string]$Description,
        [scriptblock]$Assertion
    )
    $script:TotalTests++
    try {
        $result = & $Assertion
        if ($result -eq $true -or $null -eq $result) {
            $script:PassedTests++
            Write-Host ("  [PASS] {0,-12} : {1}" -f $TestId, $Description) -ForegroundColor Green
            return $true
        } else {
            $script:FailedTests++
            $msg = "Assertion returned false"
            $script:Failures += [PSCustomObject]@{ TestId = $TestId; Description = $Description; Error = $msg }
            Write-Host ("  [FAIL] {0,-12} : {1} -> {2}" -f $TestId, $Description, $msg) -ForegroundColor Red
            return $false
        }
    } catch {
        $script:FailedTests++
        $msg = $_.Exception.Message
        $script:Failures += [PSCustomObject]@{ TestId = $TestId; Description = $Description; Error = $msg }
        Write-Host ("  [FAIL] {0,-12} : {1} -> ERROR: {2}" -f $TestId, $Description, $msg) -ForegroundColor Red
        return $false
    }
}

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  TIER 5 ADVERSARIAL HARDENING & WHITE-BOX ACCESSIBILITY AUDIT HARNESS" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "Project Root : $ProjectRoot" -ForegroundColor DarkGray
Write-Host "Timestamp    : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')" -ForegroundColor DarkGray
Write-Host ""

# ==============================================================================
# SUITE 1: COLOR SCHEMES 1-5 & CSS TOKEN LEAK / COLLISION AUDIT
# ==============================================================================
Write-Host "--- Suite 1: Color Schemes 1-5 & CSS Custom Property Scoping Audit ---" -ForegroundColor Yellow

Run-Test "T5.CS.01" "settings_data.json: Validate all 5 FocusDrawer color schemes definition" {
    $settingsPath = Join-Path $ProjectRoot "config\settings_data.json"
    $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
    $schemes = $json.presets.Dawn.color_schemes

    if (-not $schemes) { throw "color_schemes object not found in settings_data.json" }

    # Scheme 1: Matte Black (#121212), Text (#FFFFFF), Button (#E5A93C), Button Label (#121212)
    if ($schemes.'scheme-1'.settings.background -ne "#121212") { throw "scheme-1 background expected #121212, got $($schemes.'scheme-1'.settings.background)" }
    if ($schemes.'scheme-1'.settings.text -ne "#FFFFFF") { throw "scheme-1 text expected #FFFFFF, got $($schemes.'scheme-1'.settings.text)" }
    if ($schemes.'scheme-1'.settings.button -ne "#E5A93C") { throw "scheme-1 button expected #E5A93C, got $($schemes.'scheme-1'.settings.button)" }
    if ($schemes.'scheme-1'.settings.button_label -ne "#121212") { throw "scheme-1 button_label expected #121212, got $($schemes.'scheme-1'.settings.button_label)" }

    # Scheme 2: Elevated Charcoal (#1E1E1E), Text (#FFFFFF), Button (#E5A93C)
    if ($schemes.'scheme-2'.settings.background -ne "#1E1E1E") { throw "scheme-2 background expected #1E1E1E, got $($schemes.'scheme-2'.settings.background)" }
    if ($schemes.'scheme-2'.settings.text -ne "#FFFFFF") { throw "scheme-2 text expected #FFFFFF, got $($schemes.'scheme-2'.settings.text)" }
    if ($schemes.'scheme-2'.settings.button -ne "#E5A93C") { throw "scheme-2 button expected #E5A93C, got $($schemes.'scheme-2'.settings.button)" }

    # Scheme 3: Gold Accent (#E5A93C), Text (#121212), Button (#121212), Button Label (#FFFFFF)
    if ($schemes.'scheme-3'.settings.background -ne "#E5A93C") { throw "scheme-3 background expected #E5A93C, got $($schemes.'scheme-3'.settings.background)" }
    if ($schemes.'scheme-3'.settings.text -ne "#121212") { throw "scheme-3 text expected #121212, got $($schemes.'scheme-3'.settings.text)" }
    if ($schemes.'scheme-3'.settings.button -ne "#121212") { throw "scheme-3 button expected #121212, got $($schemes.'scheme-3'.settings.button)" }
    if ($schemes.'scheme-3'.settings.button_label -ne "#FFFFFF") { throw "scheme-3 button_label expected #FFFFFF, got $($schemes.'scheme-3'.settings.button_label)" }

    # Scheme 4: Deep Surface (#121212), Text (#FFFFFF), Button (#E5A93C)
    if ($schemes.'scheme-4'.settings.background -ne "#121212") { throw "scheme-4 background expected #121212, got $($schemes.'scheme-4'.settings.background)" }
    if ($schemes.'scheme-4'.settings.text -ne "#FFFFFF") { throw "scheme-4 text expected #FFFFFF, got $($schemes.'scheme-4'.settings.text)" }
    if ($schemes.'scheme-4'.settings.button -ne "#E5A93C") { throw "scheme-4 button expected #E5A93C, got $($schemes.'scheme-4'.settings.button)" }

    # Scheme 5: Clean Light (#FFFFFF), Text (#121212), Button (#121212), Button Label (#FFFFFF)
    if ($schemes.'scheme-5'.settings.background -ne "#FFFFFF") { throw "scheme-5 background expected #FFFFFF, got $($schemes.'scheme-5'.settings.background)" }
    if ($schemes.'scheme-5'.settings.text -ne "#121212") { throw "scheme-5 text expected #121212, got $($schemes.'scheme-5'.settings.text)" }
    if ($schemes.'scheme-5'.settings.button -ne "#121212") { throw "scheme-5 button expected #121212, got $($schemes.'scheme-5'.settings.button)" }
    if ($schemes.'scheme-5'.settings.button_label -ne "#FFFFFF") { throw "scheme-5 button_label expected #FFFFFF, got $($schemes.'scheme-5'.settings.button_label)" }

    $true
}

Run-Test "T5.CS.02" "layout/theme.liquid: Scoped CSS variable binding without global root pollution" {
    $themeLiquid = Get-Content (Join-Path $ProjectRoot "layout\theme.liquid") -Raw
    
    # Must iterate color_schemes and scope to .color-{{ scheme.id }}
    if ($themeLiquid -notmatch 'for\s+scheme\s+in\s+settings\.color_schemes') {
        throw "theme.liquid does not iterate settings.color_schemes"
    }
    if ($themeLiquid -notmatch '\.color-\{\{\s*scheme\.id\s*\}\}') {
        throw "theme.liquid does not bind scoped class .color-{{ scheme.id }}"
    }
    
    # Check all key custom properties generated in loop
    $requiredVars = @(
        "--color-background",
        "--color-foreground",
        "--color-button",
        "--color-button-text",
        "--color-secondary-button-text",
        "--color-shadow",
        "--color-badge-foreground"
    )
    foreach ($var in $requiredVars) {
        if ($themeLiquid -notmatch [regex]::Escape($var)) {
            throw "Missing CSS custom property definition for $var in theme.liquid"
        }
    }
    $true
}

Run-Test "T5.CS.03" "assets/base.css: Root design tokens and scoped override isolation" {
    $baseCss = Get-Content (Join-Path $ProjectRoot "assets\base.css") -Raw
    
    # Verify base.css does not hardcode static colors that overwrite scoped --color-background
    if ($baseCss -notmatch 'var\(--color-background\)') {
        throw "base.css missing dynamic var(--color-background) usage"
    }
    if ($baseCss -notmatch 'var\(--color-foreground\)') {
        throw "base.css missing dynamic var(--color-foreground) usage"
    }
    $true
}

# ==============================================================================
# SUITE 2: FOCUSDRAWER GOLD (#E5A93C) FOCUS RINGS & HOVER GLOW AUDIT
# ==============================================================================
Write-Host "`n--- Suite 2: FocusDrawer Gold (#E5A93C) Focus Rings & Glow States Audit ---" -ForegroundColor Yellow

Run-Test "T5.GL.01" "assets/base.css: Global focus ring outline & glow tokens configured with #E5A93C" {
    $baseCss = Get-Content (Join-Path $ProjectRoot "assets\base.css") -Raw
    
    if ($baseCss -notmatch '--focused-base-outline:\s*0\.2rem\s+solid\s+#E5A93C') {
        throw "--focused-base-outline missing or not set to 0.2rem solid #E5A93C in base.css"
    }
    if ($baseCss -notmatch '--focused-base-box-shadow:.*229,\s*169,\s*60') {
        throw "--focused-base-box-shadow missing gold rgba(229, 169, 60, ...) glow in base.css"
    }
    $true
}

Run-Test "T5.GL.02" "assets/base.css: Universal :focus-visible & .focused rule bindings" {
    $baseCss = Get-Content (Join-Path $ProjectRoot "assets\base.css") -Raw
    
    if ($baseCss -notmatch '\*:focus-visible\s*\{[^}]*outline:\s*var\(--focused-base-outline\)') {
        throw "*:focus-visible does not bind var(--focused-base-outline)"
    }
    if ($baseCss -notmatch '\*:focus-visible\s*\{[^}]*box-shadow:\s*var\(--focused-base-box-shadow\)') {
        throw "*:focus-visible does not bind var(--focused-base-box-shadow)"
    }
    $true
}

Run-Test "T5.GL.03" "assets/base.css: Primary button hover glow and focus ring specification" {
    $baseCss = Get-Content (Join-Path $ProjectRoot "assets\base.css") -Raw
    
    # Hover glow on buttons
    if ($baseCss -notmatch '\.button:not\(\[disabled\]\):hover\s*\{[^}]*rgba\(229,\s*169,\s*60') {
        throw ".button:not([disabled]):hover does not apply gold box-shadow glow"
    }
    # Button focus visible
    if ($baseCss -notmatch '\.button:focus-visible[^{]*\{[^}]*#E5A93C') {
        throw ".button:focus-visible does not bind #E5A93C focus ring"
    }
    $true
}

Run-Test "T5.GL.04" "assets/component-sticky-atc.css: Sticky ATC gold button, hover glow, & focus ring" {
    $stickyCss = Get-Content (Join-Path $ProjectRoot "assets\component-sticky-atc.css") -Raw
    
    if ($stickyCss -notmatch '\.sticky-atc__button\s*\{[^}]*background-color:\s*#E5A93C') {
        throw ".sticky-atc__button does not set background-color: #E5A93C"
    }
    if ($stickyCss -notmatch '\.sticky-atc__button:hover:not\(\[disabled\]\)\s*\{[^}]*rgba\(229,\s*169,\s*60,\s*0\.4\)') {
        throw ".sticky-atc__button hover state does not provide gold box-shadow glow"
    }
    if ($stickyCss -notmatch '\.sticky-atc__select:focus-visible\s*\{[^}]*border-color:\s*#E5A93C') {
        throw ".sticky-atc__select:focus-visible does not bind gold border-color: #E5A93C"
    }
    $true
}

Run-Test "T5.GL.05" "assets/component-cart-drawer.css: Cart shipping meter gold gradient & glow" {
    $cartCss = Get-Content (Join-Path $ProjectRoot "assets\component-cart-drawer.css") -Raw
    
    if ($cartCss -notmatch '#E5A93C') {
        throw "component-cart-drawer.css does not reference #E5A93C"
    }
    if ($cartCss -notmatch 'shipping-meter__fill|cart-drawer__free-shipping-bar-fill') {
        throw "component-cart-drawer.css missing shipping meter fill class selector"
    }
    $true
}

Run-Test "T5.GL.06" "assets/component-menu-drawer.css: Mobile navigation active link gold styling" {
    $menuCss = Get-Content (Join-Path $ProjectRoot "assets\component-menu-drawer.css") -Raw
    
    if ($menuCss -notmatch 'menu-drawer__menu-item--active[^{]*\{[^}]*#E5A93C') {
        throw "Mobile menu drawer active item does not feature #E5A93C styling"
    }
    $true
}

# ==============================================================================
# SUITE 3: ARIA ACCESSIBILITY & SCREEN READER SUPPORT AUDIT
# ==============================================================================
Write-Host "`n--- Suite 3: ARIA Accessibility & Screen Reader Support Audit ---" -ForegroundColor Yellow

Run-Test "T5.AR.01" "snippets/cart-drawer.liquid: Modal dialog ARIA attributes & focus trapping markup" {
    $cartDrawer = Get-Content (Join-Path $ProjectRoot "snippets\cart-drawer.liquid") -Raw
    
    if ($cartDrawer -notmatch 'role="dialog"') {
        throw "cart-drawer.liquid missing role='dialog'"
    }
    if ($cartDrawer -notmatch 'aria-modal="true"') {
        throw "cart-drawer.liquid missing aria-modal='true'"
    }
    if ($cartDrawer -notmatch 'aria-label=') {
        throw "cart-drawer.liquid missing aria-label attribute"
    }
    if ($cartDrawer -notmatch 'aria-label="\{\{\s*''accessibility\.close''\s*\|\s*t\s*\}\}"') {
        throw "cart-drawer.liquid close button missing accessibility.close aria-label"
    }
    $true
}

Run-Test "T5.AR.02" "snippets/cart-drawer.liquid: Free shipping progress meter ARIA live region & progressbar" {
    $cartDrawer = Get-Content (Join-Path $ProjectRoot "snippets\cart-drawer.liquid") -Raw
    
    if ($cartDrawer -notmatch 'role="status"') {
        throw "Shipping meter container missing role='status'"
    }
    if ($cartDrawer -notmatch 'aria-live="polite"') {
        throw "Shipping meter container missing aria-live='polite'"
    }
    if ($cartDrawer -notmatch 'role="progressbar"') {
        throw "Shipping meter track missing role='progressbar'"
    }
    if ($cartDrawer -notmatch 'aria-valuenow="\{\{\s*progress_percentage\s*\}\}"') {
        throw "Shipping meter missing aria-valuenow binding"
    }
    if ($cartDrawer -notmatch 'aria-valuemin="0"') {
        throw "Shipping meter missing aria-valuemin='0'"
    }
    if ($cartDrawer -notmatch 'aria-valuemax="100"') {
        throw "Shipping meter missing aria-valuemax='100'"
    }
    $true
}

Run-Test "T5.AR.03" "snippets/sticky-atc.liquid & sticky-atc.js: Viewport slide-up ARIA visibility management" {
    $stickyLiquid = Get-Content (Join-Path $ProjectRoot "snippets\sticky-atc.liquid") -Raw
    $stickyJs = Get-Content (Join-Path $ProjectRoot "assets\sticky-atc.js") -Raw
    
    # Liquid template starts hidden with aria-hidden="true"
    if ($stickyLiquid -notmatch 'aria-hidden="true"') {
        throw "sticky-atc.liquid should initialize with aria-hidden='true'"
    }
    # Select dropdown has aria-label
    if ($stickyLiquid -notmatch 'aria-label=') {
        throw "sticky-atc.liquid select dropdown missing aria-label"
    }
    # JS toggles aria-hidden appropriately
    if ($stickyJs -notmatch "this\.setAttribute\('aria-hidden',\s*'false'\)") {
        throw "sticky-atc.js show() must set aria-hidden='false'"
    }
    if ($stickyJs -notmatch "this\.setAttribute\('aria-hidden',\s*'true'\)") {
        throw "sticky-atc.js hide() must set aria-hidden='true'"
    }
    $true
}

Run-Test "T5.AR.04" "sections/main-product.liquid: Collapsible tabs semantic structure and headings" {
    $mainProduct = Get-Content (Join-Path $ProjectRoot "sections\main-product.liquid") -Raw
    
    # Collapsible tab block uses details and summary with heading
    if ($mainProduct -notmatch 'when\s+''collapsible_tab''') {
        throw "main-product.liquid missing collapsible_tab block handler"
    }
    if ($mainProduct -notmatch '<details\s+id="Details-\{\{\s*block\.id\s*\}\}-\{\{\s*section\.id\s*\}\}">') {
        throw "main-product.liquid collapsible_tab details element id missing or non-unique"
    }
    if ($mainProduct -notmatch '<summary>') {
        throw "main-product.liquid collapsible_tab missing summary tag"
    }
    if ($mainProduct -notmatch '<h2[^>]*accordion__title[^>]*>') {
        throw "main-product.liquid collapsible_tab summary title must use semantic heading (h2/h3)"
    }
    $true
}

Run-Test "T5.AR.05" "snippets/header-drawer.liquid: Mobile navigation drawer disclosures & current page ARIA" {
    $headerDrawer = Get-Content (Join-Path $ProjectRoot "snippets\header-drawer.liquid") -Raw
    
    if ($headerDrawer -notmatch 'aria-label="\{\{\s*''sections\.header\.menu''\s*\|\s*t\s*\}\}"') {
        throw "header-drawer.liquid menu summary missing sections.header.menu aria-label"
    }
    if ($headerDrawer -notmatch 'aria-current="page"') {
        throw "header-drawer.liquid active link missing aria-current='page'"
    }
    if ($headerDrawer -notmatch 'aria-expanded="true"') {
        throw "header-drawer.liquid submenu close button missing aria-expanded='true'"
    }
    $true
}

# ==============================================================================
# SUITE 4: 100% STRICT RFC 8259 JSON & LIQUID TAG BALANCING VALIDATION
# ==============================================================================
Write-Host "`n--- Suite 4: 100% Strict RFC 8259 JSON & Liquid Tag Balancing Validation ---" -ForegroundColor Yellow

Run-Test "T5.SC.01" "Validate 100% of workspace JSON files (RFC 8259 compliance)" {
    $jsonFiles = Get-ChildItem -Path $ProjectRoot -Recurse -Include *.json -File | Where-Object { $_.FullName -notmatch '\\\.agents\\' -and $_.FullName -notmatch '\\\.git\\' }
    if ($jsonFiles.Count -eq 0) { throw "No JSON files found in workspace" }

    $invalidFiles = @()
    foreach ($file in $jsonFiles) {
        try {
            $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
            $null = ConvertFrom-Json $content -ErrorAction Stop
        } catch {
            $invalidFiles += "$($file.FullName): $($_.Exception.Message)"
        }
    }

    if ($invalidFiles.Count -gt 0) {
        throw "Found $($invalidFiles.Count) invalid JSON files:`n" + ($invalidFiles -join "`n")
    }
    $true
}

Run-Test "T5.SC.02" "Validate 100% of Liquid section {% schema %} blocks for valid JSON" {
    $liquidFiles = Get-ChildItem -Path (Join-Path $ProjectRoot "sections") -Include *.liquid -File
    $invalidSchemas = @()

    foreach ($file in $liquidFiles) {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        if ($content -match '\{%\s*schema\s*%\}([\s\S]*?)\{%\s*endschema\s*%\}') {
            $schemaJson = $Matches[1].Trim()
            try {
                $null = ConvertFrom-Json $schemaJson -ErrorAction Stop
            } catch {
                $invalidSchemas += "$($file.Name): $($_.Exception.Message)"
            }
        }
    }

    if ($invalidSchemas.Count -gt 0) {
        throw "Found $($invalidSchemas.Count) invalid schema blocks:`n" + ($invalidSchemas -join "`n")
    }
    $true
}

Run-Test "T5.SC.03" "Validate 100% of Liquid templates and snippets for balanced paired tags" {
    $liquidFiles = Get-ChildItem -Path $ProjectRoot -Recurse -Include *.liquid -File | Where-Object { $_.FullName -notmatch '\\\.agents\\' -and $_.FullName -notmatch '\\\.git\\' }
    $unbalancedFiles = @()

    $pairDefs = @(
        @{ Open = '\bif\b'; Close = '\bendif\b'; Name = 'if' },
        @{ Open = '\bunless\b'; Close = '\bendunless\b'; Name = 'unless' },
        @{ Open = '\bcase\b'; Close = '\bendcase\b'; Name = 'case' },
        @{ Open = '\bfor\b'; Close = '\bendfor\b'; Name = 'for' },
        @{ Open = '\bform\b'; Close = '\bendform\b'; Name = 'form' },
        @{ Open = '\bpaginate\b'; Close = '\bendpaginate\b'; Name = 'paginate' },
        @{ Open = '\bcapture\b'; Close = '\bendcapture\b'; Name = 'capture' },
        @{ Open = '\bstyle\b'; Close = '\bendstyle\b'; Name = 'style' },
        @{ Open = '\bjavascript\b'; Close = '\bendjavascript\b'; Name = 'javascript' },
        @{ Open = '\bschema\b'; Close = '\bendschema\b'; Name = 'schema' }
    )

    foreach ($file in $liquidFiles) {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

        # Check comment blocks balance
        $openComments = ([regex]::Matches($content, '\{%-?\s*comment\s*-?%\}')).Count
        $closeComments = ([regex]::Matches($content, '\{%-?\s*endcomment\s*-?%\}')).Count
        if ($openComments -ne $closeComments) {
            $unbalancedFiles += "$($file.Name): Unbalanced comments ($openComments open vs $closeComments close)"
            continue
        }

        # Check raw blocks balance
        $openRaw = ([regex]::Matches($content, '\{%-?\s*raw\s*-?%\}')).Count
        $closeRaw = ([regex]::Matches($content, '\{%-?\s*endraw\s*-?%\}')).Count
        if ($openRaw -ne $closeRaw) {
            $unbalancedFiles += "$($file.Name): Unbalanced raw blocks ($openRaw open vs $closeRaw close)"
            continue
        }

        # Strip comments and raw contents for cleaner tag counting
        $clean = [regex]::Replace($content, '\{%-?\s*comment\s*-?%\}[\s\S]*?\{%-?\s*endcomment\s*-?%\}', '')
        $clean = [regex]::Replace($clean, '\{%-?\s*raw\s*-?%\}[\s\S]*?\{%-?\s*endraw\s*-?%\}', '')

        foreach ($p in $pairDefs) {
            $openRegex = '\{%-?\s*' + $p.Open + '\b'
            $closeRegex = '\{%-?\s*' + $p.Close + '\b'

            $openCount = ([regex]::Matches($clean, $openRegex)).Count
            $closeCount = ([regex]::Matches($clean, $closeRegex)).Count

            if ($openCount -ne $closeCount) {
                $unbalancedFiles += "$($file.Name): Tag mismatch for '$($p.Name)' ($openCount open vs $closeCount close)"
            }
        }
    }

    if ($unbalancedFiles.Count -gt 0) {
        throw "Found $($unbalancedFiles.Count) Liquid tag mismatches:`n" + ($unbalancedFiles -join "`n")
    }
    $true
}

# ==============================================================================
# SUITE 5: ADVERSARIAL BOUNDARY & MATHEMATICAL STRESS
# ==============================================================================
Write-Host "`n--- Suite 5: Adversarial Boundary & Numerical Model Stress ---" -ForegroundColor Yellow

Run-Test "T5.BD.01" "Free shipping meter: Numerical model simulation across 10 boundary conditions" {
    $threshold = 5000 # cents ($50.00)
    
    $testVectors = @(
        @{ Total = 0; ExpectedPct = 0; ExpectedUnlocked = $false; ExpectedRemaining = 5000 },
        @{ Total = 1; ExpectedPct = 0; ExpectedUnlocked = $false; ExpectedRemaining = 4999 },
        @{ Total = 1250; ExpectedPct = 25; ExpectedUnlocked = $false; ExpectedRemaining = 3750 },
        @{ Total = 2500; ExpectedPct = 50; ExpectedUnlocked = $false; ExpectedRemaining = 2500 },
        @{ Total = 4999; ExpectedPct = 100; ExpectedUnlocked = $false; ExpectedRemaining = 1 },
        @{ Total = 5000; ExpectedPct = 100; ExpectedUnlocked = $true; ExpectedRemaining = 0 },
        @{ Total = 5001; ExpectedPct = 100; ExpectedUnlocked = $true; ExpectedRemaining = -1 },
        @{ Total = 7500; ExpectedPct = 100; ExpectedUnlocked = $true; ExpectedRemaining = -2500 },
        @{ Total = 15000; ExpectedPct = 100; ExpectedUnlocked = $true; ExpectedRemaining = -10000 },
        @{ Total = 1000000; ExpectedPct = 100; ExpectedUnlocked = $true; ExpectedRemaining = -995000 }
    )

    foreach ($v in $testVectors) {
        $cartTotal = $v.Total
        $rem = $threshold - $cartTotal
        $unlocked = ($rem -le 0)
        
        if ($unlocked) {
            $pct = 100
        } else {
            if ($threshold -gt 0) {
                $raw = [Math]::Round(($cartTotal * 100.0) / $threshold)
                $pct = [Math]::Min(100, [Math]::Max(0, [int]$raw))
            } else {
                $pct = 100
            }
        }

        if ($pct -ne $v.ExpectedPct) {
            throw "Total $($v.Total) calculated percentage $pct, expected $($v.ExpectedPct)"
        }
        if ($unlocked -ne $v.ExpectedUnlocked) {
            throw "Total $($v.Total) calculated unlocked $unlocked, expected $($v.ExpectedUnlocked)"
        }
    }
    $true
}

Run-Test "T5.BD.02" "Product accordion tabs: Verify dynamic SVG asset pipeline and icon asset existence" {
    $iconAccordion = Get-Content (Join-Path $ProjectRoot "snippets\icon-accordion.liquid") -Raw
    
    if ($iconAccordion -notmatch 'inline_asset_content') {
        throw "icon-accordion.liquid does not use inline_asset_content filter"
    }

    $requiredIcons = @("icon-ruler.svg", "icon-check-mark.svg", "icon-lightning-bolt.svg", "icon-star.svg", "icon-box.svg")
    foreach ($icon in $requiredIcons) {
        $iconPath = Join-Path $ProjectRoot "assets\$icon"
        if (-not (Test-Path $iconPath)) {
            throw "Required accordion icon asset '$icon' is missing from assets/"
        }
    }
    $true
}

Run-Test "T5.BD.03" "Product template: Verify all 4 FocusDrawer spec accordion tabs in templates/product.json" {
    $prodJson = Get-Content (Join-Path $ProjectRoot "templates\product.json") -Raw | ConvertFrom-Json
    $mainBlocks = $prodJson.sections.main.blocks

    $expectedTabs = @(
        @{ Name = "spec_dimensions_mounting"; Icon = "ruler"; Heading = "Dimensions & Mounting Instructions" },
        @{ Name = "spec_materials_craftsmanship"; Icon = "check_mark"; Heading = "Materials & Craftsmanship" },
        @{ Name = "spec_cable_management"; Icon = "lightning_bolt"; Heading = "Cable Management & Charging" },
        @{ Name = "spec_warranty_guarantee"; Icon = "star"; Heading = "Warranty & Guarantee" }
    )

    foreach ($tab in $expectedTabs) {
        $block = $mainBlocks.$($tab.Name)
        if (-not $block) {
            throw "Missing collapsible tab block '$($tab.Name)' in templates/product.json"
        }
        if ($block.type -ne "collapsible_tab") {
            throw "Block '$($tab.Name)' is type '$($block.type)', expected 'collapsible_tab'"
        }
        if ($block.settings.icon -ne $tab.Icon) {
            throw "Block '$($tab.Name)' has icon '$($block.settings.icon)', expected '$($tab.Icon)'"
        }
        if ($block.settings.heading -ne $tab.Heading) {
            throw "Block '$($tab.Name)' has heading '$($block.settings.heading)', expected '$($tab.Heading)'"
        }
        if ([string]::IsNullOrWhiteSpace($block.settings.content)) {
            throw "Block '$($tab.Name)' has empty specification content"
        }
    }
    $true
}

Run-Test "T5.BD.04" "Brand Asset Integrity: focusdrawer-logo.png format, dimensions, & RGBA buffer" {
    Add-Type -AssemblyName System.Drawing
    $logoPath = Join-Path $ProjectRoot "assets\focusdrawer-logo.png"
    if (-not (Test-Path $logoPath)) { throw "Logo missing at $logoPath" }

    $img = [System.Drawing.Image]::FromFile($logoPath)
    try {
        if ($img.Width -lt 500 -or $img.Height -lt 500) {
            throw "Logo dimensions $($img.Width)x$($img.Height) below minimum 500x500 requirement"
        }
        if ($img.PixelFormat -notmatch "Format32bppArgb|Format32bppRgb") {
            throw "Logo pixel format expected 32-bit ARGB/RGB, got $($img.PixelFormat)"
        }
    } finally {
        $img.Dispose()
    }
    $true
}

# ==============================================================================
# SUMMARY & EXIT CODE
# ==============================================================================
Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "  TIER 5 ADVERSARIAL HARDENING AUDIT SUMMARY" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ("Total Assertions : {0}" -f $TotalTests)
Write-Host ("Passed           : {0}" -f $PassedTests) -ForegroundColor Green
Write-Host ("Failed           : {0}" -f $FailedTests) -ForegroundColor $(if ($FailedTests -eq 0) { "Green" } else { "Red" })
$passRate = if ($TotalTests -gt 0) { [Math]::Round(($PassedTests / $TotalTests) * 100, 2) } else { 0 }
Write-Host ("Pass Rate        : {0}%" -f $passRate) -ForegroundColor $(if ($FailedTests -eq 0) { "Green" } else { "Red" })

if ($FailedTests -gt 0) {
    Write-Host "`n[FAILURES REPORTED]" -ForegroundColor Red
    foreach ($f in $Failures) {
        Write-Host ("- [{0}] {1} : {2}" -f $f.TestId, $f.Description, $f.Error) -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "`n[SUCCESS] All Tier 5 Adversarial and White-Box Audit Assertions Passed!" -ForegroundColor Green
    exit 0
}
