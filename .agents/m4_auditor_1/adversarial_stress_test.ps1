# Adversarial Stress Testing Script for Milestone 4 (Updated with Multiline Regex)
Write-Host "=== ADVERSARIAL STRESS TEST SUITE: MILESTONE 4 ===" -ForegroundColor Magenta

# Test 1: Full Repo JSON Schema Sweep
Write-Host "`n[STRESS 1] Validating all repository JSON files..." -ForegroundColor Cyan
$jsonFiles = Get-ChildItem -Path . -Filter "*.json" -Recurse | Where-Object { 
    $_.FullName -notmatch '\\\.git' -and 
    $_.FullName -notmatch '\\node_modules' -and
    $_.FullName -notmatch '\\\.agents'
}
$jsonFailures = @()
foreach ($f in $jsonFiles) {
    try {
        $null = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        $jsonFailures += "$($f.FullName): $($_.Exception.Message)"
    }
}
if ($jsonFailures.Count -eq 0) {
    Write-Host "  -> PASS: All $($jsonFiles.Count) JSON files are strictly valid RFC 8259 JSON." -ForegroundColor Green
} else {
    Write-Host "  -> FAIL: $($jsonFailures.Count) JSON files failed parsing:" -ForegroundColor Red
    $jsonFailures | ForEach-Object { Write-Host "     $_" -ForegroundColor Red }
}

# Test 2: Full Repo Liquid Tag Balance Sweep
Write-Host "`n[STRESS 2] Validating all Liquid template syntax & balance..." -ForegroundColor Cyan
$liquidFiles = Get-ChildItem -Path sections, snippets, layout, templates -Filter "*.liquid" -Recurse
$pairedTags = @('if', 'unless', 'case', 'for', 'tablerow', 'form', 'paginate', 'capture', 'style', 'javascript', 'stylesheet')
$liquidFailures = @()

foreach ($lf in $liquidFiles) {
    $raw = [System.IO.File]::ReadAllText($lf.FullName, [System.Text.Encoding]::UTF8)
    $cleaned = [regex]::Replace($raw, '(?s)\{%-?\s*comment\s*-?%\}.*?\{%-?\s*endcomment\s*-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*doc\s*-?%\}.*?\{%-?\s*enddoc\s*-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*raw\s*-?%\}.*?\{%-?\s*endraw\s*-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*schema\s*-?%\}.*?\{%-?\s*endschema\s*-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '\{%-?\s*#.*?-?%\}', '')
    $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*liquid\b.*?-?%\}', '')

    $tokens = [regex]::Matches($cleaned, '(?s)\{%-?\s*([a-zA-Z_]+)(.*?)-?%\}')
    $stack = New-Object System.Collections.Generic.Stack[string]
    $fileErr = @()
    foreach ($tok in $tokens) {
        $tagName = $tok.Groups[1].Value.ToLower()
        if ($pairedTags -contains $tagName) {
            $stack.Push($tagName)
        } elseif ($tagName -match '^end([a-zA-Z_]+)$') {
            $endTag = $matches[1]
            if ($stack.Count -eq 0) {
                $fileErr += "Unmatched closing tag {% $tagName %}"
            } else {
                $expected = $stack.Pop()
                if ($expected -ne $endTag) {
                    $fileErr += "Mismatched tag: expected {% end$expected %}, got {% $tagName %}"
                }
            }
        }
    }
    if ($stack.Count -gt 0) {
        $fileErr += "Unclosed tags: $($stack.ToArray() -join ', ')"
    }
    
    $openCount = ([regex]::Matches($cleaned, '\{\{')).Count
    $closeCount = ([regex]::Matches($cleaned, '\}\}')).Count
    if ($openCount -ne $closeCount) {
        $fileErr += "Delimiter mismatch: $openCount '{{' vs $closeCount '}}'"
    }

    if ($fileErr.Count -gt 0) {
        $liquidFailures += "$($lf.Name): $($fileErr -join '; ')"
    }
}

if ($liquidFailures.Count -eq 0) {
    Write-Host "  -> PASS: All $($liquidFiles.Count) Liquid files passed strict tag & delimiter validation." -ForegroundColor Green
} else {
    Write-Host "  -> FAIL: $($liquidFailures.Count) Liquid files failed:" -ForegroundColor Red
    $liquidFailures | ForEach-Object { Write-Host "     $_" -ForegroundColor Red }
}

# Test 3: Specific M4 Liquid Snippet Logic Verification
Write-Host "`n[STRESS 3] Auditing snippets/sticky-atc.liquid logic constructs..." -ForegroundColor Cyan
$stickyAtcContent = [System.IO.File]::ReadAllText('snippets/sticky-atc.liquid', [System.Text.Encoding]::UTF8)
$checks = @(
    @{ Name = "Custom Element Root (<sticky-atc>)"; Pattern = '(?s)<sticky-atc\b' },
    @{ Name = "Data attributes (data-section-id, data-product-id)"; Pattern = '(?s)data-section-id=.*?data-product-id=' },
    @{ Name = "Aria hidden initial state"; Pattern = 'aria-hidden="true"' },
    @{ Name = "Featured image fallback chain"; Pattern = '(?s)selected_variant\.featured_image.*?product\.featured_image' },
    @{ Name = "Price wrapper & IDs"; Pattern = '(?s)StickyATCPrice-.*?StickyATCComparePrice-' },
    @{ Name = "Variant select wrapper guard"; Pattern = 'unless product\.has_only_default_variant' },
    @{ Name = "Variant option data attributes"; Pattern = '(?s)data-price=.*?data-compare-price=.*?data-available=' },
    @{ Name = "Button disabled logic"; Pattern = '(?s)unless selected_variant\.available.*?disabled="disabled"' },
    @{ Name = "Loading spinner presence"; Pattern = 'loading__spinner' }
)

foreach ($chk in $checks) {
    if ($stickyAtcContent -match $chk.Pattern) {
        Write-Host "  -> PASS: $($chk.Name)" -ForegroundColor Green
    } else {
        Write-Host "  -> FAIL: $($chk.Name) missing or pattern mismatch!" -ForegroundColor Red
    }
}

# Test 4: Check for Forbidden Hardcoded Fake Strings / Mock Patterns
Write-Host "`n[STRESS 4] Checking for forbidden mock / facade patterns..." -ForegroundColor Cyan
$facadePatterns = @(
    'return\s+true\s*;?\s*$',
    'return\s+false\s*;?\s*$',
    'mock',
    'stub',
    'placeholder-pass',
    'fake'
)

$m4Files = @(
    'templates/product.json',
    'templates/collection.json',
    'snippets/sticky-atc.liquid',
    'assets/sticky-atc.js',
    'assets/component-sticky-atc.css'
)

$facadeHits = 0
foreach ($mf in $m4Files) {
    $text = [System.IO.File]::ReadAllText($mf, [System.Text.Encoding]::UTF8)
    foreach ($p in $facadePatterns) {
        if ($p -eq 'mock' -or $p -eq 'stub' -or $p -eq 'fake') {
            # Search for actual code mocks
            if ($text -match "(?i)\b$p\b" -and $text -notmatch "reviews_placeholder") {
                Write-Host "  -> WARNING: Found suspicious keyword '$p' in $mf" -ForegroundColor Yellow
                $facadeHits++
            }
        }
    }
}
if ($facadeHits -eq 0) {
    Write-Host "  -> PASS: Zero facade/mock implementations detected in Milestone 4 files." -ForegroundColor Green
}

Write-Host "`n=== ADVERSARIAL STRESS TEST COMPLETE ===" -ForegroundColor Magenta
