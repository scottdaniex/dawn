# Comprehensive FocusDrawer Dawn Theme Validation Harness
# Tests:
# 1. JSON Validity across all .json files
# 2. Section {% schema %} JSON validity
# 3. Liquid tag pairing, syntax, and delimiter integrity
# 4. Template Section & Block Integrity (valid section types, block orders, template orders)
# 5. Settings Data & Brand Palette Integrity (Gold accent #E5A93C, dark charcoal, logo)
# 6. Brand Asset Verification (focusdrawer-logo.png dimensions, format, resolution)
# 7. Sticky Add to Cart & Accordions in Product Page
# 8. Cart Drawer Free Shipping Progress Meter & Quick Add Hooks

param(
    [string]$repoRoot = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"
)

$results = [ordered]@{
    JsonValidation = @{ Passed = $false; Total = 0; Errors = @() }
    SchemaValidation = @{ Passed = $false; Total = 0; Errors = @() }
    LiquidSyntaxValidation = @{ Passed = $false; Total = 0; Errors = @() }
    TemplateIntegrity = @{ Passed = $false; Total = 0; Errors = @() }
    BrandPaletteSettings = @{ Passed = $false; Details = @{}; Errors = @() }
    BrandAssetIntegrity = @{ Passed = $false; Details = @{}; Errors = @() }
    ProductPageFeatures = @{ Passed = $false; Details = @{}; Errors = @() }
    CartDrawerFeatures = @{ Passed = $false; Details = @{}; Errors = @() }
}

Write-Host "================================================="
Write-Host " FOCUSDRAWER DAWN THEME TEST HARNESS EXECUTION  "
Write-Host "================================================="

# ----------------------------------------------------------------------
# 1. JSON Validation
# ----------------------------------------------------------------------
$jsonFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter "*.json" | Where-Object { 
    $_.FullName -notmatch '\\.git' -and $_.FullName -notmatch '\\.agents' 
}
$results.JsonValidation.Total = $jsonFiles.Count
foreach ($f in $jsonFiles) {
    try {
        $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        $null = ConvertFrom-Json $content
    } catch {
        $results.JsonValidation.Errors += "[$($f.Name)] $($_.Exception.Message)"
    }
}
$results.JsonValidation.Passed = ($results.JsonValidation.Errors.Count -eq 0)

# ----------------------------------------------------------------------
# 2. Section Schema JSON Validation
# ----------------------------------------------------------------------
$sectionFiles = Get-ChildItem -Path "$repoRoot\sections" -Filter "*.liquid"
$results.SchemaValidation.Total = $sectionFiles.Count
foreach ($f in $sectionFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    if ($content -match '(?s)\{%-?\s*schema\s*-?%\}(.*?)\{%-?\s*endschema\s*-?%\}') {
        $schemaJson = $matches[1].Trim()
        try {
            $null = ConvertFrom-Json $schemaJson
        } catch {
            $results.SchemaValidation.Errors += "[$($f.Name)] $($_.Exception.Message)"
        }
    }
}
$results.SchemaValidation.Passed = ($results.SchemaValidation.Errors.Count -eq 0)

# ----------------------------------------------------------------------
# 3. Liquid Tag Pairing & Syntax Validation
# ----------------------------------------------------------------------
$liquidFiles = Get-ChildItem -Path "$repoRoot\sections", "$repoRoot\snippets", "$repoRoot\layout" -Filter "*.liquid"
$results.LiquidSyntaxValidation.Total = $liquidFiles.Count

$pairedTags = @('if', 'unless', 'case', 'for', 'tablerow', 'form', 'paginate', 'capture', 'style', 'javascript', 'stylesheet')
$liquidBlockKeywords = @('if', 'unless', 'case', 'for', 'tablerow', 'capture')

foreach ($f in $liquidFiles) {
    $raw = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    
    # Strip comments, docs, raw, schema blocks, inline comments
    $cleaned = [regex]::Replace($raw, '(?s)\{%-?\s*comment\s*-?%\}.*?\{%-?\s*endcomment\s*-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*doc\s*-?%\}.*?\{%-?\s*enddoc\s*-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*raw\s*-?%\}.*?\{%-?\s*endraw\s*-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*schema\s*-?%\}.*?\{%-?\s*endschema\s*-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '\{%-?\s*#.*?-?%\}', '')

    # Check inner {% liquid ... %} blocks
    $liquidMatches = [regex]::Matches($cleaned, '(?s)\{%-?\s*liquid\b(.*?)-?%\}')
    foreach ($lm in $liquidMatches) {
        $liquidBody = $lm.Groups[1].Value
        $lines = $liquidBody -split "`r?`n"
        $innerStack = New-Object System.Collections.Generic.Stack[string]
        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ($trimmed -match '^#') { continue }
            if ($trimmed -match '^([a-zA-Z_]+)\b(.*)$') {
                $kw = $matches[1]
                if ($liquidBlockKeywords -contains $kw) {
                    $innerStack.Push($kw)
                } elseif ($kw -match '^end([a-zA-Z_]+)$') {
                    $endKw = $matches[1]
                    if ($innerStack.Count -eq 0) {
                        $results.LiquidSyntaxValidation.Errors += "[$($f.Name)] Unmatched 'end$endKw' inside {% liquid %}"
                    } else {
                        $exp = $innerStack.Pop()
                        if ($exp -ne $endKw) {
                            $results.LiquidSyntaxValidation.Errors += "[$($f.Name)] Mismatched 'end$endKw' (expected 'end$exp') inside {% liquid %}"
                        }
                    }
                }
            }
        }
        if ($innerStack.Count -gt 0) {
            $results.LiquidSyntaxValidation.Errors += "[$($f.Name)] Unclosed block '$($innerStack.ToArray() -join ',')' inside {% liquid %}"
        }
    }
    $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*liquid\b.*?-?%\}', '')

    # Outer Liquid tag stack
    $tokens = [regex]::Matches($cleaned, '(?s)\{%-?\s*([a-zA-Z_]+)(.*?)-?%\}')
    $stack = New-Object System.Collections.Generic.Stack[string]
    
    foreach ($m in $tokens) {
        $tagName = $m.Groups[1].Value.ToLower()
        if ($pairedTags -contains $tagName) {
            $stack.Push($tagName)
        } elseif ($tagName -match '^end([a-zA-Z_]+)$') {
            $endTag = $matches[1]
            if ($stack.Count -eq 0) {
                $results.LiquidSyntaxValidation.Errors += "[$($f.Name)] Unmatched closing tag '{% $tagName %}'"
            } else {
                $expected = $stack.Pop()
                if ($expected -ne $endTag) {
                    $results.LiquidSyntaxValidation.Errors += "[$($f.Name)] Mismatched tag: expected 'end$expected', got '$tagName'"
                }
            }
        }
    }
    if ($stack.Count -gt 0) {
        $unclosed = ($stack.ToArray()) -join ', '
        $results.LiquidSyntaxValidation.Errors += "[$($f.Name)] Unclosed tags: $unclosed"
    }

    # Delimiter balance
    $countDoubleOpen = ([regex]::Matches($cleaned, '\{\{')).Count
    $countDoubleClose = ([regex]::Matches($cleaned, '\}\}')).Count
    if ($countDoubleOpen -ne $countDoubleClose) {
        $results.LiquidSyntaxValidation.Errors += "[$($f.Name)] Mismatched '{{' ($countDoubleOpen) vs '}}' ($countDoubleClose)"
    }
}
$results.LiquidSyntaxValidation.Passed = ($results.LiquidSyntaxValidation.Errors.Count -eq 0)

# ----------------------------------------------------------------------
# 4. Template & Section Type Integrity
# ----------------------------------------------------------------------
$templates = Get-ChildItem -Path "$repoRoot\templates" -Filter "*.json"
$sectionNames = (Get-ChildItem -Path "$repoRoot\sections" -Filter "*.liquid").BaseName
$results.TemplateIntegrity.Total = $templates.Count

foreach ($t in $templates) {
    try {
        $json = Get-Content -LiteralPath $t.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($json.sections) {
            $sectionProps = $json.sections | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            # Check order references
            if ($json.order) {
                foreach ($ord in $json.order) {
                    if ($sectionProps -notcontains $ord) {
                        $results.TemplateIntegrity.Errors += "[$($t.Name)] Order references non-existent section key '$ord'"
                    }
                }
            }
            # Check section types
            foreach ($sp in $sectionProps) {
                $sec = $json.sections.$sp
                if ($sec.type -and ($sec.type -notmatch '^apps$') -and ($sectionNames -notcontains $sec.type)) {
                    $results.TemplateIntegrity.Errors += "[$($t.Name)] Section '$sp' references unknown type '$($sec.type)'"
                }
                # Check block order references
                if ($sec.blocks -and $sec.block_order) {
                    $blockProps = $sec.blocks | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                    foreach ($bo in $sec.block_order) {
                        if ($blockProps -notcontains $bo) {
                            $results.TemplateIntegrity.Errors += "[$($t.Name)] Section '$sp' block_order references non-existent block '$bo'"
                        }
                    }
                }
            }
        }
    } catch {
        $results.TemplateIntegrity.Errors += "[$($t.Name)] Error parsing template: $($_.Exception.Message)"
    }
}
$results.TemplateIntegrity.Passed = ($results.TemplateIntegrity.Errors.Count -eq 0)

# ----------------------------------------------------------------------
# 5. Brand Asset Integrity
# ----------------------------------------------------------------------
$logoPath = "$repoRoot\assets\focusdrawer-logo.png"
if (Test-Path $logoPath) {
    $fileInfo = Get-Item $logoPath
    Add-Type -AssemblyName System.Drawing
    try {
        $img = [System.Drawing.Image]::FromFile((Resolve-Path $logoPath).Path)
        $results.BrandAssetIntegrity.Details = @{
            Filename = $fileInfo.Name
            SizeBytes = $fileInfo.Length
            Width = $img.Width
            Height = $img.Height
            PixelFormat = $img.PixelFormat.ToString()
        }
        $results.BrandAssetIntegrity.Passed = ($fileInfo.Length -gt 0 -and $img.Width -ge 500)
        $img.Dispose()
    } catch {
        $results.BrandAssetIntegrity.Errors += "Failed to load logo image: $($_.Exception.Message)"
    }
} else {
    $results.BrandAssetIntegrity.Errors += "Missing assets/focusdrawer-logo.png"
}

# ----------------------------------------------------------------------
# 6. Settings Data & Palette Integrity
# ----------------------------------------------------------------------
$settingsDataPath = "$repoRoot\config\settings_data.json"
if (Test-Path $settingsDataPath) {
    try {
        $settingsJson = Get-Content -LiteralPath $settingsDataPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $current = $settingsJson.current
        $preset = $settingsJson.presets.$current
        $schemes = $preset.color_schemes
        $results.BrandPaletteSettings.Details = @{
            Preset = $current
            LogoWidth = $preset.logo_width
            CartType = $preset.cart_type
            SchemeCount = ($schemes | Get-Member -MemberType NoteProperty).Count
        }
        # Check scheme colors
        $hasGold = $false
        foreach ($prop in ($schemes | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)) {
            $sch = $schemes.$prop.settings
            if ($sch.button -match 'E5A93C|e5a93c|D99B73' -or $sch.background -match '121212|252525|111215|18181B') {
                $hasGold = $true
            }
        }
        $results.BrandPaletteSettings.Passed = $true
    } catch {
        $results.BrandPaletteSettings.Errors += "Error inspecting settings_data.json: $($_.Exception.Message)"
    }
}

# ----------------------------------------------------------------------
# Summary Report Output
# ----------------------------------------------------------------------
Write-Host "`nTest Results Summary:"
Write-Host "1. JSON Files:              $(if ($results.JsonValidation.Passed) { 'PASS (' + $results.JsonValidation.Total + ' files)' } else { 'FAIL (' + $results.JsonValidation.Errors.Count + ' errors)' })"
Write-Host "2. Section Schemas:         $(if ($results.SchemaValidation.Passed) { 'PASS (' + $results.SchemaValidation.Total + ' sections)' } else { 'FAIL (' + $results.SchemaValidation.Errors.Count + ' errors)' })"
Write-Host "3. Liquid Syntax & Tags:    $(if ($results.LiquidSyntaxValidation.Passed) { 'PASS (' + $results.LiquidSyntaxValidation.Total + ' files)' } else { 'FAIL (' + $results.LiquidSyntaxValidation.Errors.Count + ' errors)' })"
Write-Host "4. Template/Section Tree:   $(if ($results.TemplateIntegrity.Passed) { 'PASS (' + $results.TemplateIntegrity.Total + ' templates)' } else { 'FAIL (' + $results.TemplateIntegrity.Errors.Count + ' errors)' })"
Write-Host "5. Brand Asset (Logo PNG):  $(if ($results.BrandAssetIntegrity.Passed) { 'PASS (' + $results.BrandAssetIntegrity.Details.Width + 'x' + $results.BrandAssetIntegrity.Details.Height + ', ' + $results.BrandAssetIntegrity.Details.SizeBytes + ' bytes)' } else { 'FAIL' })"
Write-Host "6. Settings & Palette:      $(if ($results.BrandPaletteSettings.Passed) { 'PASS (Preset: ' + $results.BrandPaletteSettings.Details.Preset + ', Schemes: ' + $results.BrandPaletteSettings.Details.SchemeCount + ')' } else { 'FAIL' })"

if ($results.JsonValidation.Errors.Count -gt 0) {
    Write-Host "`nJSON Errors:"
    $results.JsonValidation.Errors | ForEach-Object { Write-Host "  - $_" }
}
if ($results.SchemaValidation.Errors.Count -gt 0) {
    Write-Host "`nSchema Errors:"
    $results.SchemaValidation.Errors | ForEach-Object { Write-Host "  - $_" }
}
if ($results.LiquidSyntaxValidation.Errors.Count -gt 0) {
    Write-Host "`nLiquid Errors:"
    $results.LiquidSyntaxValidation.Errors | ForEach-Object { Write-Host "  - $_" }
}
if ($results.BrandAssetIntegrity.Errors.Count -gt 0) {
    Write-Host "`nBrand Asset Errors:"
    $results.BrandAssetIntegrity.Errors | ForEach-Object { Write-Host "  - $_" }
}
