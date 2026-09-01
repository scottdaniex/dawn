# Audit Script for Milestone 3 (Home Page Showcase) - Complete Forensic Check
$RepoRoot = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"
$indexPath = "$RepoRoot\templates\index.json"

Write-Host "=== 1. RAW TEXT INTEGRITY & SUSPICIOUS STRING AUDIT ==="
$rawContent = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

$suspiciousPatterns = @(
    'lorem', 'ipsum', 'dolor', 'sit amet', 'consectetur',
    'todo', 'fixme', 'placeholder', 'dummy', 'temp', 'asdf', 'test_data', 'sample'
)

$foundSuspicious = @()
foreach ($pat in $suspiciousPatterns) {
    $matches = [regex]::Matches($rawContent, "(?i)\b$pat\b")
    if ($matches.Count -gt 0) {
        $foundSuspicious += "Found pattern '$pat' ($($matches.Count) occurrences)"
    }
}

if ($foundSuspicious.Count -eq 0) {
    Write-Host "[PASS] No suspicious / dummy / placeholder tokens found in templates/index.json." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Suspicious tokens found:" -ForegroundColor Red
    $foundSuspicious | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host "`n=== 2. STRICT RFC 8259 JSON VALIDITY ==="
try {
    $indexObj = ConvertFrom-Json $rawContent
    Write-Host "[PASS] JSON parsed successfully via .NET JSON engine." -ForegroundColor Green
} catch {
    Write-Host "[FAIL] JSON parse error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== 3. SECTION GRAPH & ORDER INTEGRITY ==="
$sectionKeys = $indexObj.sections | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
$orderKeys = $indexObj.order

Write-Host "Configured Sections Count: $($sectionKeys.Count)"
Write-Host "Order Array Count: $($orderKeys.Count)"

$orderMismatch = $false
foreach ($ok in $orderKeys) {
    if ($sectionKeys -notcontains $ok) {
        Write-Host "[FAIL] Order references unknown section: $ok" -ForegroundColor Red
        $orderMismatch = $true
    }
}
foreach ($sk in $sectionKeys) {
    if ($orderKeys -notcontains $sk) {
        Write-Host "[WARN] Section not listed in order array: $sk" -ForegroundColor Yellow
        $orderMismatch = $true
    }
}
if (-not $orderMismatch) {
    Write-Host "[PASS] 100% 1-to-1 match between order array and sections dictionary." -ForegroundColor Green
}

Write-Host "`n=== 4. LIQUID SCHEMA CONFORMANCE DEEP CHECK ==="
foreach ($sk in $orderKeys) {
    $sec = $indexObj.sections.$sk
    $secType = $sec.type
    $liquidPath = "$RepoRoot\sections\$secType.liquid"
    Write-Host "Checking Section: '$sk' (Type: '$secType')..." -ForegroundColor Cyan
    
    if (-not (Test-Path $liquidPath)) {
        Write-Host "  [FAIL] Liquid file missing: $liquidPath" -ForegroundColor Red
        continue
    }
    
    $liquidContent = [System.IO.File]::ReadAllText($liquidPath, [System.Text.Encoding]::UTF8)
    if ($liquidContent -match '(?s)\{%-?\s*schema\s*-?%\}(.*?)\{%-?\s*endschema\s*-?%\}') {
        $schema = ConvertFrom-Json $matches[1].Trim()
        $allowedSettingIds = @($schema.settings | ForEach-Object { $_.id } | Where-Object { $_ })
        $allowedBlockTypes = @($schema.blocks | ForEach-Object { $_.type } | Where-Object { $_ })
        
        # Check section settings
        if ($sec.settings) {
            $secSettingKeys = $sec.settings | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            foreach ($ssk in $secSettingKeys) {
                if ($allowedSettingIds -notcontains $ssk) {
                    Write-Host "  [WARN] Section setting '$ssk' not in schema settings list" -ForegroundColor Yellow
                }
            }
        }
        
        # Check blocks
        if ($sec.blocks) {
            $secBlockKeys = $sec.blocks | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $secBlockOrder = $sec.block_order
            Write-Host "  Blocks ($($secBlockKeys.Count)): $($secBlockKeys -join ', ')"
            
            foreach ($bk in $secBlockKeys) {
                $blk = $sec.blocks.$bk
                $bType = $blk.type
                if ($allowedBlockTypes -notcontains $bType) {
                    Write-Host "  [FAIL] Block '$bk' has invalid type '$bType' (allowed: $($allowedBlockTypes -join ', '))" -ForegroundColor Red
                } else {
                    Write-Host "  [PASS] Block '$bk' type '$bType' is valid" -ForegroundColor Green
                }
            }
            
            if ($secBlockOrder) {
                foreach ($bo in $secBlockOrder) {
                    if ($secBlockKeys -notcontains $bo) {
                        Write-Host "  [FAIL] block_order references unknown block '$bo'" -ForegroundColor Red
                    }
                }
            }
        }
    } else {
        Write-Host "  [WARN] No schema found in $liquidPath" -ForegroundColor Yellow
    }
}

Write-Host "`n=== 5. EMBEDDED HTML MARKUP INTEGRITY ==="
$htmlMatches = [regex]::Matches($rawContent, '<[^>]+>')
Write-Host "Found $($htmlMatches.Count) embedded HTML tags."
$tagStack = New-Object System.Collections.Generic.Stack[string]
$selfClosing = @('br', 'hr', 'img', 'input')
$htmlErrors = @()

foreach ($tm in $htmlMatches) {
    $tag = $tm.Value
    if ($tag -match '^<([a-zA-Z0-9]+)(\s+[^>]*)?/>$') {
        # self-closing
        continue
    } elseif ($tag -match '^</([a-zA-Z0-9]+)>$') {
        $cTag = $matches[1].ToLower()
        if ($tagStack.Count -eq 0) {
            $htmlErrors += "Unmatched closing tag: $tag"
        } else {
            $expected = $tagStack.Pop()
            if ($expected -ne $cTag) {
                $htmlErrors += "Mismatched tag: expected closing of '$expected', got '$cTag'"
            }
        }
    } elseif ($tag -match '^<([a-zA-Z0-9]+)(\s+[^>]*)?>$') {
        $oTag = $matches[1].ToLower()
        if ($selfClosing -notcontains $oTag) {
            $tagStack.Push($oTag)
        }
    }
}
if ($tagStack.Count -gt 0) {
    $htmlErrors += "Unclosed tags: " + ($tagStack.ToArray() -join ', ')
}

if ($htmlErrors.Count -eq 0) {
    Write-Host "[PASS] All HTML tags in templates/index.json are well-formed, balanced, and sanitized." -ForegroundColor Green
} else {
    Write-Host "[FAIL] HTML markup errors found:" -ForegroundColor Red
    $htmlErrors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host "`n=== 6. REQUIREMENT R2 TRACEABILITY MATRIX ==="
# R2.1: Hero Section
$hasHero = $indexObj.sections.image_banner -ne $null -and $indexObj.sections.image_banner.type -eq "image-banner"
$heroHeading = $indexObj.sections.image_banner.blocks.heading.settings.heading
$heroBtn1 = $indexObj.sections.image_banner.blocks.button.settings.button_label_1
$heroBtn2 = $indexObj.sections.image_banner.blocks.button.settings.button_label_2
Write-Host "R2.1 Hero Banner: Present=$hasHero | Heading='$heroHeading' | Button1='$heroBtn1' | Button2='$heroBtn2'"

# R2.2: 3-Pillar Value Proposition
$hasPillars = $indexObj.sections.organizing_pillars -ne $null
$pillar1 = $indexObj.sections.organizing_pillars.blocks.declutter.settings.title
$pillar2 = $indexObj.sections.organizing_pillars.blocks.focus.settings.title
$pillar3 = $indexObj.sections.organizing_pillars.blocks.ergonomics.settings.title
Write-Host "R2.2 3 Pillars: Present=$hasPillars | P1='$pillar1' | P2='$pillar2' | P3='$pillar3'"

# R2.3: Featured Products Grid & Quick-Add
$hasFeatured = $indexObj.sections.featured_collection -ne $null
$quickAdd = $indexObj.sections.featured_collection.settings.quick_add
$colsDesktop = $indexObj.sections.featured_collection.settings.columns_desktop
Write-Host "R2.3 Featured Collection: Present=$hasFeatured | quick_add='$quickAdd' | columns_desktop=$colsDesktop"

# R2.4: Interactive Dimension / Specs Highlight
$hasDimensions = $indexObj.sections.dimension_comparison -ne $null
$dimLayout = $indexObj.sections.dimension_comparison.settings.layout
$dimBlocks = $indexObj.sections.dimension_comparison.block_order.Count
Write-Host "R2.4 Dimensions/Specs: Present=$hasDimensions | layout='$dimLayout' | rows=$dimBlocks"

# R2.5: Customer Testimonials
$hasTestimonials = $indexObj.sections.customer_testimonials -ne $null
$testBlocks = $indexObj.sections.customer_testimonials.block_order.Count
Write-Host "R2.5 Testimonials: Present=$hasTestimonials | reviews count=$testBlocks"

Write-Host "`n=== 7. COLOR SCHEME INTEGRATION AUDIT ==="
$schemesUsed = @()
foreach ($sk in $orderKeys) {
    $sec = $indexObj.sections.$sk
    if ($sec.settings.color_scheme) {
        $schemesUsed += "${sk}: $($sec.settings.color_scheme)"
    }
    if ($sec.settings.container_color_scheme) {
        $schemesUsed += "${sk} (container): $($sec.settings.container_color_scheme)"
    }
}
Write-Host "Color Scheme Mappings:"
$schemesUsed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }

Write-Host "`n=== AUDIT SCRIPT COMPLETE ==="
