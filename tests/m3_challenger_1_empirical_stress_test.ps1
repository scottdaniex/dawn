# ==============================================================================
# M3 EMPIRICAL CHALLENGER: ADVERSARIAL STRESS TEST & VALIDATION HARNESS (v2)
# Agent: m3_challenger_1
# Purpose: Deep validation of templates/index.json, section schemas, link resolution,
#          color schemes, and content coverage for FocusDrawer M3 Home Page Showcase.
# ==============================================================================

param(
    [string]$RepoRoot = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"
)

$ErrorActionPreference = "Stop"

$PassCount = 0
$FailCount = 0
$TestResults = @()

function Report-Assert {
    param(
        [string]$TestId,
        [string]$Description,
        [bool]$Condition,
        [string]$Details = ""
    )
    $status = if ($Condition) { "PASS" } else { "FAIL" }
    if ($Condition) {
        $Script:PassCount++
        Write-Host "  [PASS] $TestId : $Description" -ForegroundColor Green
        if ($Details) { Write-Host "         -> $Details" -ForegroundColor DarkGray }
    } else {
        $Script:FailCount++
        Write-Host "  [FAIL] $TestId : $Description" -ForegroundColor Red
        if ($Details) { Write-Host "         -> ERROR: $Details" -ForegroundColor Yellow }
    }
    $Script:TestResults += [PSCustomObject]@{
        TestId      = $TestId
        Description = $Description
        Status      = $status
        Details     = $Details
    }
}

Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "  M3 EMPIRICAL CHALLENGE HARNESS: FOCUSDRAWER HOME PAGE SHOWCASE" -ForegroundColor Cyan
Write-Host "==============================================================================`n" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. TEMPLATE JSON INTEGRITY & STRUCTURE
# ------------------------------------------------------------------------------
Write-Host "--- Group 1: JSON Integrity & Section Hierarchy ---" -ForegroundColor White
$indexPath = Join-Path $RepoRoot "templates\index.json"
$indexObj = $null
$jsonParseSuccess = $false

try {
    $rawContent = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
    $indexObj = ConvertFrom-Json -InputObject $rawContent
    $jsonParseSuccess = ($indexObj -ne $null -and $indexObj.sections -ne $null -and $indexObj.order -ne $null)
    Report-Assert "M3.JSON.01" "templates/index.json is valid RFC 8259 JSON" $jsonParseSuccess "File size: $($rawContent.Length) bytes"
} catch {
    Report-Assert "M3.JSON.01" "templates/index.json is valid RFC 8259 JSON" $false $_.Exception.Message
}

$sectionKeys = if ($indexObj.sections) { $indexObj.sections | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name } else { @() }
$orderKeys = if ($indexObj.order) { $indexObj.order } else { @() }

# Section order consistency
$orderMatches = ($sectionKeys.Count -eq $orderKeys.Count)
foreach ($ok in $orderKeys) {
    if (-not ($sectionKeys -contains $ok)) {
        $orderMatches = $false
    }
}
Report-Assert "M3.JSON.02" "Section list matches section order array exactly ($($orderKeys.Count) sections)" $orderMatches "Order: $($orderKeys -join ' -> ')"

# ------------------------------------------------------------------------------
# 2. REQUIRED M3 HOMEPAGE COMPONENTS & ORDER
# ------------------------------------------------------------------------------
Write-Host "`n--- Group 2: Milestone 3 Component Inventory & Order ---" -ForegroundColor White

# 1. Hero Banner
$hasHero = ($orderKeys -contains "image_banner") -and ($indexObj.sections.image_banner.type -eq "image-banner")
Report-Assert "M3.COMP.01" "Hero Banner section ('image_banner', type: image-banner) present" $hasHero "Type: $($indexObj.sections.image_banner.type)"

# 2. Brand Mission Intro
$hasIntro = ($orderKeys -contains "focus_intro") -and ($indexObj.sections.focus_intro.type -eq "rich-text")
Report-Assert "M3.COMP.02" "Brand Mission Intro section ('focus_intro', type: rich-text) present" $hasIntro "Type: $($indexObj.sections.focus_intro.type)"

# 3. 3-Pillar Value Proposition
$hasPillars = ($orderKeys -contains "organizing_pillars") -and ($indexObj.sections.organizing_pillars.type -eq "multicolumn")
Report-Assert "M3.COMP.03" "3-Pillar Value Proposition section ('organizing_pillars', type: multicolumn) present" $hasPillars "Type: $($indexObj.sections.organizing_pillars.type)"

# 4. Featured Products Grid & Quick-Add
$hasFeatured = ($orderKeys -contains "featured_collection") -and ($indexObj.sections.featured_collection.type -eq "featured-collection")
Report-Assert "M3.COMP.04" "Featured Products Grid section ('featured_collection', type: featured-collection) present" $hasFeatured "Type: $($indexObj.sections.featured_collection.type)"

# 5. Interactive Dimension Comparison / Specs Highlight
$hasDimensions = ($orderKeys -contains "dimension_comparison") -and ($indexObj.sections.dimension_comparison.type -eq "collapsible-content")
Report-Assert "M3.COMP.05" "Interactive Dimension section ('dimension_comparison', type: collapsible-content) present" $hasDimensions "Type: $($indexObj.sections.dimension_comparison.type)"

# 6. Customer Testimonials
$hasReviews = ($orderKeys -contains "customer_testimonials") -and ($indexObj.sections.customer_testimonials.type -eq "multicolumn")
Report-Assert "M3.COMP.06" "Customer Testimonials section ('customer_testimonials', type: multicolumn) present" $hasReviews "Type: $($indexObj.sections.customer_testimonials.type)"

# 7. Brand Story & 8. Newsletter
$hasBrandStory = ($orderKeys -contains "brand_story") -and ($indexObj.sections.brand_story.type -eq "rich-text")
$hasNewsletter = ($orderKeys -contains "newsletter") -and ($indexObj.sections.newsletter.type -eq "newsletter")
Report-Assert "M3.COMP.07" "Brand Story ('brand_story') & Community Newsletter ('newsletter') present" ($hasBrandStory -and $hasNewsletter) "Total homepage sections: $($orderKeys.Count)"

# Order check: image_banner -> focus_intro -> organizing_pillars -> featured_collection -> dimension_comparison -> customer_testimonials -> brand_story -> newsletter
$expectedOrder = @("image_banner", "focus_intro", "organizing_pillars", "featured_collection", "dimension_comparison", "customer_testimonials", "brand_story", "newsletter")
$orderIdentical = ($orderKeys.Count -eq $expectedOrder.Count)
if ($orderIdentical) {
    for ($i = 0; $i -lt $orderKeys.Count; $i++) {
        if ($orderKeys[$i] -ne $expectedOrder[$i]) {
            $orderIdentical = $false
            break
        }
    }
}
Report-Assert "M3.COMP.08" "Home page section sequence adheres to conversion story flow" $orderIdentical "Sequence: $($orderKeys -join ' -> ')"

# ------------------------------------------------------------------------------
# 3. SCHEMA COMPLIANCE FOR ALL HOMEPAGE SECTIONS
# ------------------------------------------------------------------------------
Write-Host "`n--- Group 3: Strict Schema Compliance (Liquid {% schema %} vs index.json) ---" -ForegroundColor White

foreach ($secKey in $orderKeys) {
    $sec = $indexObj.sections.$secKey
    $secType = $sec.type
    $liquidPath = Join-Path $RepoRoot "sections\$secType.liquid"

    if (-not (Test-Path $liquidPath)) {
        Report-Assert "M3.SCH.$secKey" "Section file sections/$secType.liquid exists" $false "Missing file: $liquidPath"
        continue
    }

    # Extract schema
    $liqText = [System.IO.File]::ReadAllText($liquidPath, [System.Text.Encoding]::UTF8)
    $schemaMatch = [regex]::Match($liqText, '\{%\s*schema\s*%\}([\s\S]*?)\{%\s*endschema\s*%\}')
    if (-not $schemaMatch.Success) {
        Report-Assert "M3.SCH.$secKey" "Section schema extracted for $secType" $false "No {% schema %} block found in $liquidPath"
        continue
    }

    $schemaObj = ConvertFrom-Json -InputObject $schemaMatch.Groups[1].Value
    $allowedSettings = @{}
    foreach ($st in $schemaObj.settings) {
        if ($st.id) {
            $allowedSettings[$st.id] = $st
        }
    }

    $allowedBlocks = @{}
    if ($schemaObj.blocks) {
        foreach ($bl in $schemaObj.blocks) {
            if ($bl.type) {
                $allowedBlocks[$bl.type] = $bl
            }
        }
    }

    # Check section settings
    $settingsValid = $true
    $settingErrors = @()
    if ($sec.settings) {
        $configuredSettings = $sec.settings | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
        foreach ($cSet in $configuredSettings) {
            if (-not $allowedSettings.ContainsKey($cSet)) {
                $settingsValid = $false
                $settingErrors += "Unknown setting '$cSet' for section type '$secType'"
            } else {
                $schemaDef = $allowedSettings[$cSet]
                $val = $sec.settings.$cSet
                if ($schemaDef.type -eq "select" -or $schemaDef.type -eq "radio") {
                    $validOptionValues = $schemaDef.options | ForEach-Object { $_.value }
                    if (-not ($validOptionValues -contains "$val")) {
                        $settingsValid = $false
                        $settingErrors += "Setting '$cSet' has invalid option value '$val'. Allowed: $($validOptionValues -join ', ')"
                    }
                } elseif ($schemaDef.type -eq "range") {
                    $numVal = [double]$val
                    if ($numVal -lt $schemaDef.min -or $numVal -gt $schemaDef.max) {
                        $settingsValid = $false
                        $settingErrors += "Setting '$cSet' value $val out of bounds [$($schemaDef.min), $($schemaDef.max)]"
                    }
                }
            }
        }
    }

    # Check section blocks
    $blocksValid = $true
    $blockErrors = @()
    if ($sec.blocks) {
        $blockKeys = $sec.blocks | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
        if ($schemaObj.max_blocks -and $blockKeys.Count -gt $schemaObj.max_blocks) {
            $blocksValid = $false
            $blockErrors += "Block count $($blockKeys.Count) exceeds max_blocks $($schemaObj.max_blocks)"
        }

        foreach ($bk in $blockKeys) {
            $bObj = $sec.blocks.$bk
            $bType = $bObj.type
            if (-not $allowedBlocks.ContainsKey($bType)) {
                $blocksValid = $false
                $blockErrors += "Block '$bk' has unknown block type '$bType' for section '$secType'"
            } else {
                $bSchema = $allowedBlocks[$bType]
                $bAllowedSettings = @{}
                foreach ($bst in $bSchema.settings) {
                    if ($bst.id) { $bAllowedSettings[$bst.id] = $bst }
                }
                if ($bObj.settings) {
                    $bConfiguredSettings = $bObj.settings | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                    foreach ($bcSet in $bConfiguredSettings) {
                        if (-not $bAllowedSettings.ContainsKey($bcSet)) {
                            $blocksValid = $false
                            $blockErrors += "Block '$bk' has unknown setting '$bcSet'"
                        } else {
                            $bDef = $bAllowedSettings[$bcSet]
                            $bVal = $bObj.settings.$bcSet
                            if ($bDef.type -eq "select" -or $bDef.type -eq "radio") {
                                $bValidOptions = $bDef.options | ForEach-Object { $_.value }
                                if (-not ($bValidOptions -contains "$bVal")) {
                                    $blocksValid = $false
                                    $blockErrors += "Block '$bk' setting '$bcSet' has invalid option '$bVal'. Allowed: $($bValidOptions -join ', ')"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    $secPassed = ($settingsValid -and $blocksValid)
    $errorDetails = ($settingErrors + $blockErrors) -join '; '
    if (-not $errorDetails) { $errorDetails = "All settings and blocks match schema" }
    Report-Assert "M3.SCH.$secKey" "Section '$secKey' ($secType) settings and blocks match schema definitions" $secPassed $errorDetails
}

# ------------------------------------------------------------------------------
# 4. CONTENT & BRANDING COVERAGE EMPIRICAL VERIFICATION
# ------------------------------------------------------------------------------
Write-Host "`n--- Group 4: Content Coverage & Brand Alignment ---" -ForegroundColor White

# 4.1 Hero Content
$heroSec = $indexObj.sections.image_banner
$heroHeading = $heroSec.blocks.heading.settings.heading
$heroText = $heroSec.blocks.text.settings.text
$heroBtn1 = $heroSec.blocks.button.settings.button_label_1
$heroLink1 = $heroSec.blocks.button.settings.button_link_1
$heroBtn2 = $heroSec.blocks.button.settings.button_label_2
$heroLink2 = $heroSec.blocks.button.settings.button_link_2

$heroContentValid = ($heroHeading -match 'Workspace Flow|Focus Drawers' -and
                     $heroText -match 'Precision aerospace aluminum|under-desk' -and
                     $heroBtn1 -eq "Shop Focus Drawer" -and
                     $heroLink1 -eq "shopify://collections/all" -and
                     $heroBtn2 -eq "Explore Setup" -and
                     $heroLink2 -eq "#organizing_pillars")
Report-Assert "M3.CNT.01" "Hero Banner contains FocusDrawer copy, value proposition, and dual CTAs" $heroContentValid "Heading: '$heroHeading', CTA1: '$heroBtn1' ($heroLink1), CTA2: '$heroBtn2' ($heroLink2)"

# 4.2 3-Pillar Value Props (Declutter, Focus, Ergonomics)
$pillarsSec = $indexObj.sections.organizing_pillars
$pillarDeclutter = $pillarsSec.blocks.declutter.settings
$pillarFocus = $pillarsSec.blocks.focus.settings
$pillarErgonomics = $pillarsSec.blocks.ergonomics.settings

$pDeclutterValid = ($pillarDeclutter.title -match '1\.\s*Declutter' -and $pillarDeclutter.text -match 'aerospace aluminum')
$pFocusValid = ($pillarFocus.title -match '2\.\s*Focus' -and $pillarFocus.text -match 'deep.*?work|tactile')
$pErgoValid = ($pillarErgonomics.title -match '3\.\s*Ergonomics' -and $pillarErgonomics.text -match 'ball-bearing|knee clearance|sit-stand')

$pillarsValid = ($pDeclutterValid -and $pFocusValid -and $pErgoValid -and $pillarsSec.settings.columns_desktop -eq 3)
Report-Assert "M3.CNT.02" "3-Pillars Section explicitly defines '1. Declutter', '2. Focus', and '3. Ergonomics'" $pillarsValid "Columns: $($pillarsSec.settings.columns_desktop), Alignment: $($pillarsSec.settings.column_alignment)"

# 4.3 Featured Collection & Quick-Add
$featSec = $indexObj.sections.featured_collection
$featValid = ($featSec.settings.quick_add -eq "standard" -and
              $featSec.settings.columns_desktop -eq 4 -and
              $featSec.settings.products_to_show -ge 4 -and
              $featSec.settings.image_ratio -eq "square" -and
              $featSec.settings.show_secondary_image -eq $true -and
              $featSec.settings.show_view_all -eq $true)
Report-Assert "M3.CNT.03" "Featured Collection has quick_add: standard, 4 cols desktop, square 1:1 image ratio" $featValid "quick_add: '$($featSec.settings.quick_add)', cols: $($featSec.settings.columns_desktop), count: $($featSec.settings.products_to_show)"

# 4.4 Technical Dimensions & Highlights Accordion
$dimSec = $indexObj.sections.dimension_comparison
$dimBlocks = $dimSec.blocks
$hasClearanceRow = ($dimBlocks.mounting_clearance -ne $null -and $dimBlocks.mounting_clearance.settings.icon -eq "ruler" -and $dimBlocks.mounting_clearance.settings.row_content -match '18\.5".*?11\.8"')
$hasCableRow = ($dimBlocks.cable_routing -ne $null -and $dimBlocks.cable_routing.settings.icon -eq "lightning_bolt" -and $dimBlocks.cable_routing.settings.row_content -match 'grommets|USB-C|pass-through')
$hasLoadRow = ($dimBlocks.load_capacity -ne $null -and $dimBlocks.load_capacity.settings.icon -eq "box" -and $dimBlocks.load_capacity.settings.row_content -match '25 lb|50,000')
$hasWarrantyRow = ($dimBlocks.warranty_guarantee -ne $null -and $dimBlocks.warranty_guarantee.settings.icon -eq "check_mark" -and $dimBlocks.warranty_guarantee.settings.row_content -match 'Lifetime|30-Day')

$dimsValid = ($hasClearanceRow -and $hasCableRow -and $hasLoadRow -and $hasWarrantyRow -and $dimSec.settings.layout -eq "row" -and $dimSec.settings.open_first_collapsible_row -eq $true)
Report-Assert "M3.CNT.04" "Interactive Dimension Accordion has 4 spec rows (ruler, lightning_bolt, box, check_mark)" $dimsValid "OpenFirstRow: $($dimSec.settings.open_first_collapsible_row), Layout: $($dimSec.settings.layout), ColorScheme: $($dimSec.settings.container_color_scheme)"

# 4.5 Customer Testimonials & Verified Social Proof
$revSec = $indexObj.sections.customer_testimonials
$revBlocks = $revSec.blocks
$hasRev1 = ($revBlocks.testimonial_alex -ne $null -and $revBlocks.testimonial_alex.settings.text -match 'Alex M\.' -and $revBlocks.testimonial_alex.settings.text -match 'Verified Buyer')
$hasRev2 = ($revBlocks.testimonial_david -ne $null -and $revBlocks.testimonial_david.settings.text -match 'David K\.' -and $revBlocks.testimonial_david.settings.text -match 'Verified Buyer')
$hasRev3 = ($revBlocks.testimonial_elena -ne $null -and $revBlocks.testimonial_elena.settings.text -match 'Elena R\.' -and $revBlocks.testimonial_elena.settings.text -match 'Verified Buyer')

$reviewsValid = ($hasRev1 -and $hasRev2 -and $hasRev3 -and $revSec.settings.swipe_on_mobile -eq $true -and $revSec.settings.columns_desktop -eq 3)
Report-Assert "M3.CNT.05" "Customer Testimonials include 3 verified buyer reviews with badges and swipe_on_mobile" $reviewsValid "SwipeOnMobile: $($revSec.settings.swipe_on_mobile), Scheme: $($revSec.settings.color_scheme)"

# ------------------------------------------------------------------------------
# 5. PALETTE & COLOR SCHEME HARMONIZATION
# ------------------------------------------------------------------------------
Write-Host "`n--- Group 5: Palette & Color Scheme Harmonization ---" -ForegroundColor White
$settingsDataPath = Join-Path $RepoRoot "config\settings_data.json"
$settingsData = Get-Content -LiteralPath $settingsDataPath -Raw -Encoding UTF8 | ConvertFrom-Json
$currentPreset = $settingsData.presets.($settingsData.current)
$definedSchemes = $currentPreset.color_schemes | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

# Check schemes used in index.json:
$schemesUsed = @()
foreach ($secName in $orderKeys) {
    $sec = $indexObj.sections.$secName
    if ($sec.settings.color_scheme) { $schemesUsed += $sec.settings.color_scheme }
    if ($sec.settings.container_color_scheme) { $schemesUsed += $sec.settings.container_color_scheme }
}
$uniqueSchemesUsed = $schemesUsed | Select-Object -Unique

$allSchemesExist = $true
foreach ($sc in $uniqueSchemesUsed) {
    if (-not ($definedSchemes -contains $sc)) {
        $allSchemesExist = $false
        Write-Host "Scheme $sc not found in settings_data.json" -ForegroundColor Red
    }
}
Report-Assert "M3.PAL.01" "All color schemes used in index.json exist in settings_data.json" $allSchemesExist "Schemes used: $($uniqueSchemesUsed -join ', ')"

# Scheme 1 check (#121212 bg, #E5A93C button)
$scheme1 = $currentPreset.color_schemes."scheme-1".settings
$s1Valid = ($scheme1.background -eq "#121212" -and $scheme1.button -eq "#E5A93C")
Report-Assert "M3.PAL.02" "Scheme-1 is matte black (#121212) with FocusDrawer gold button (#E5A93C)" $s1Valid "bg=$($scheme1.background), btn=$($scheme1.button)"

# Scheme 2 check (#1E1E1E bg, #E5A93C button)
$scheme2 = $currentPreset.color_schemes."scheme-2".settings
$s2Valid = ($scheme2.background -eq "#1E1E1E" -and $scheme2.button -eq "#E5A93C")
Report-Assert "M3.PAL.03" "Scheme-2 is dark charcoal surface (#1E1E1E) with gold accents" $s2Valid "bg=$($scheme2.background), btn=$($scheme2.button)"

# ------------------------------------------------------------------------------
# 6. ICON ASSETS INTEGRITY
# ------------------------------------------------------------------------------
Write-Host "`n--- Group 6: Accordion Icon Assets Integrity ---" -ForegroundColor White
$iconList = @("icon-ruler.svg", "icon-lightning-bolt.svg", "icon-box.svg", "icon-check-mark.svg")
$allIconsExist = $true
$iconDetails = @()

foreach ($ic in $iconList) {
    $icPath = Join-Path $RepoRoot "assets\$ic"
    if (Test-Path $icPath) {
        $icSize = (Get-Item $icPath).Length
        $iconDetails += "$ic ($icSize bytes)"
    } else {
        $allIconsExist = $false
        $iconDetails += "$ic (MISSING)"
    }
}
Report-Assert "M3.ICO.01" "All 4 accordion SVG icon assets present in assets/" $allIconsExist ($iconDetails -join ', ')

# ------------------------------------------------------------------------------
# 7. SUMMARY REPORT & VERDICT
# ------------------------------------------------------------------------------
Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "  M3 EMPIRICAL CHALLENGE EXECUTION SUMMARY" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "Total Assertions : $($PassCount + $FailCount)" -ForegroundColor White
Write-Host "Passed           : $PassCount" -ForegroundColor Green
Write-Host "Failed           : $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
$passRate = [Math]::Round(($PassCount * 100.0 / ($PassCount + $FailCount)), 1)
Write-Host "Pass Rate        : $passRate%`n" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })

if ($FailCount -eq 0) {
    Write-Host "[VERDICT] APPROVE: Milestone 3 meets all architectural, schema, content, and test criteria." -ForegroundColor Green
    exit 0
} else {
    Write-Host "[VERDICT] REQUEST_CHANGES: $FailCount assertions failed." -ForegroundColor Red
    exit 1
}
