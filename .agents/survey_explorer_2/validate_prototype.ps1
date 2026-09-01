# Comprehensive Liquid & Theme Test Validator for FocusDrawer / Dawn Theme
param(
    [string]$repoRoot = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"
)

function Test-JsonFiles {
    param([string]$Path)
    $files = Get-ChildItem -Path $Path -Recurse -Filter "*.json" | Where-Object { 
        $_.FullName -notmatch '\\.git' -and $_.FullName -notmatch '\\.agents' 
    }
    $errors = @()
    foreach ($f in $files) {
        try {
            $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
            $null = ConvertFrom-Json $content
        } catch {
            $errors += "JSON syntax error in $($f.FullName): $($_.Exception.Message)"
        }
    }
    return @{ Total = $files.Count; Errors = $errors }
}

function Test-SectionSchemas {
    param([string]$SectionsPath)
    $files = Get-ChildItem -Path $SectionsPath -Filter "*.liquid"
    $errors = @()
    $schemaCount = 0
    foreach ($f in $files) {
        $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        if ($content -match '(?s)\{%\s*schema\s*%\}(.*?)\{%\s*endschema\s*%\}') {
            $schemaCount++
            $schemaJson = $matches[1].Trim()
            try {
                $null = ConvertFrom-Json $schemaJson
            } catch {
                $errors += "Schema JSON invalid in $($f.Name): $($_.Exception.Message)"
            }
        }
    }
    return @{ TotalSections = $files.Count; SchemasFound = $schemaCount; Errors = $errors }
}

function Test-LiquidTags {
    param([string[]]$Paths)
    $files = Get-ChildItem -Path $Paths -Recurse -Filter "*.liquid" | Where-Object {
        $_.FullName -notmatch '\\.git' -and $_.FullName -notmatch '\\.agents'
    }
    $errors = @()
    
    $pairedTags = @('if', 'unless', 'case', 'for', 'tablerow', 'form', 'paginate', 'capture', 'style', 'javascript', 'stylesheet')
    $liquidBlockKeywords = @('if', 'unless', 'case', 'for', 'tablerow', 'capture')

    foreach ($f in $files) {
        $raw = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        
        # 1. Remove comments, docs, raw, schema blocks
        $cleaned = [regex]::Replace($raw, '(?s)\{%-?\s*comment\s*-?%\}.*?\{%-?\s*endcomment\s*-?%\}', '')
        $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*doc\s*-?%\}.*?\{%-?\s*enddoc\s*-?%\}', '')
        $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*raw\s*-?%\}.*?\{%-?\s*endraw\s*-?%\}', '')
        $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*schema\s*-?%\}.*?\{%-?\s*endschema\s*-?%\}', '')
        $cleaned = [regex]::Replace($cleaned, '\{%-?\s*#.*?-?%\}', '')

        # 2. Check inner {% liquid ... %} blocks separately, then strip them
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
                            $errors += "Unmatched 'end$endKw' inside {% liquid %} in $($f.Name)"
                        } else {
                            $exp = $innerStack.Pop()
                            if ($exp -ne $endKw) {
                                $errors += "Mismatched 'end$endKw' (expected 'end$exp') inside {% liquid %} in $($f.Name)"
                            }
                        }
                    }
                }
            }
            if ($innerStack.Count -gt 0) {
                $errors += "Unclosed block '$($innerStack.ToArray() -join ',')' inside {% liquid %} in $($f.Name)"
            }
        }
        $cleaned = [regex]::Replace($cleaned, '(?s)\{%-?\s*liquid\b.*?-?%\}', '')

        # 3. Outer Liquid tag stack
        $tokens = [regex]::Matches($cleaned, '(?s)\{%-?\s*([a-zA-Z_]+)(.*?)-?%\}')
        $stack = New-Object System.Collections.Generic.Stack[string]
        
        foreach ($m in $tokens) {
            $tagName = $m.Groups[1].Value.ToLower()
            if ($pairedTags -contains $tagName) {
                $stack.Push($tagName)
            } elseif ($tagName -match '^end([a-zA-Z_]+)$') {
                $endTag = $matches[1]
                if ($stack.Count -eq 0) {
                    $errors += "Unmatched closing tag '{% $tagName %}' in $($f.Name)"
                } else {
                    $expected = $stack.Pop()
                    if ($expected -ne $endTag) {
                        $errors += "Mismatched tag in $($f.Name): expected 'end$expected', got '$tagName'"
                    }
                }
            }
        }
        if ($stack.Count -gt 0) {
            $unclosed = ($stack.ToArray()) -join ', '
            $errors += "Unclosed tags in $($f.Name): $unclosed"
        }

        # 4. Check for broken tag delimiters
        $unclosedOpen = [regex]::Matches($cleaned, '\{\{[^}]*?(?=\{\{|$)')
        if ($unclosedOpen.Count -gt 0) {
            # Check if any {{ without }}
            $countDoubleOpen = ([regex]::Matches($cleaned, '\{\{')).Count
            $countDoubleClose = ([regex]::Matches($cleaned, '\}\}')).Count
            if ($countDoubleOpen -ne $countDoubleClose) {
                $errors += "Mismatched '{{' ($countDoubleOpen) and '}}' ($countDoubleClose) in $($f.Name)"
            }
        }
    }
    return @{ TotalLiquidFiles = $files.Count; Errors = $errors }
}

$rJson = Test-JsonFiles -Path $repoRoot
$rSchema = Test-SectionSchemas -SectionsPath "$repoRoot\sections"
$rLiquid = Test-LiquidTags -Paths @("$repoRoot\sections", "$repoRoot\snippets", "$repoRoot\layout")

Write-Host "=== Validation Summary ==="
Write-Host "JSON Files: $($rJson.Total) scanned, $($rJson.Errors.Count) errors."
if ($rJson.Errors.Count -gt 0) { $rJson.Errors | ForEach-Object { Write-Host "  $_" } }

Write-Host "Section Schemas: $($rSchema.TotalSections) sections scanned ($($rSchema.SchemasFound) schemas), $($rSchema.Errors.Count) errors."
if ($rSchema.Errors.Count -gt 0) { $rSchema.Errors | ForEach-Object { Write-Host "  $_" } }

Write-Host "Liquid Files: $($rLiquid.TotalLiquidFiles) scanned, $($rLiquid.Errors.Count) errors."
if ($rLiquid.Errors.Count -gt 0) { $rLiquid.Errors | ForEach-Object { Write-Host "  $_" } }
