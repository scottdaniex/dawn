$jsonFiles = Get-ChildItem -Path "..\.." -Filter "*.json" -Recurse | Where-Object { $_.FullName -notmatch '\\.git\\' }
$allValid = $true

Write-Host "--- VALIDATING JSON FILES ---"
foreach ($f in $jsonFiles) {
    try {
        $content = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
        $null = ConvertFrom-Json -InputObject $content -ErrorAction Stop
        Write-Host "OK: $($f.FullName.Replace((Get-Location).Path, ''))"
    } catch {
        $allValid = $false
        Write-Host "ERROR in $($f.FullName): $($_.Exception.Message)"
    }
}

Write-Host "`n--- VALIDATING LIQUID SECTION SCHEMAS ---"
$liquidFiles = Get-ChildItem -Path "..\..\sections" -Filter "*.liquid"
foreach ($f in $liquidFiles) {
    $content = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
    if ($content -match '(?s)\{% schema %\}(.*?)\{% endschema %\}') {
        $schemaText = $matches[1].Trim()
        try {
            $null = ConvertFrom-Json -InputObject $schemaText -ErrorAction Stop
            Write-Host "OK SCHEMA: $($f.Name)"
        } catch {
            $allValid = $false
            Write-Host "ERROR SCHEMA in $($f.Name): $($_.Exception.Message)"
        }
    }
}

if ($allValid) {
    Write-Host "`nALL JSON FILES AND LIQUID SCHEMAS ARE VALID!"
} else {
    Write-Host "`nSOME FILES CONTAIN SYNTAX ERRORS!"
}
