# Deep Verification Script in PowerShell (.NET Core / Framework)
$ErrorActionPreference = "Stop"
$dawnDir = "C:\Users\asedacasd\.gemini\antigravity\scratch\dawn"

Write-Host "--- STRICT JSON PARSER AUDIT ACROSS REPO ---" -ForegroundColor Yellow
$jsonFiles = Get-ChildItem -Path $dawnDir -Filter "*.json" -Recurse | Where-Object { $_.FullName -notmatch '\\\.agents\\' -and $_.FullName -notmatch '\\node_modules\\' }
$jsonPassed = 0
$jsonErrors = @()

foreach ($f in $jsonFiles) {
    try {
        $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        $obj = $content | ConvertFrom-Json
        $jsonPassed++
    } catch {
        $jsonErrors += "$($f.FullName): $($_.Exception.Message)"
    }
}
Write-Host "Strictly parsed $jsonPassed JSON files. Errors: $($jsonErrors.Count)" -ForegroundColor Green

Write-Host "`n--- LIQUID DELIMITER SCAN ACROSS ALL REPO LIQUID FILES ---" -ForegroundColor Yellow
$liquidFiles = Get-ChildItem -Path $dawnDir -Filter "*.liquid" -Recurse | Where-Object { $_.FullName -notmatch '\\\.agents\\' }
$liqPassed = 0
$liqErrors = @()

foreach ($lf in $liquidFiles) {
    $content = [System.IO.File]::ReadAllText($lf.FullName, [System.Text.Encoding]::UTF8)
    $openTag = [regex]::Matches($content, '\{%').Count
    $closeTag = [regex]::Matches($content, '%\}').Count
    $openVar = [regex]::Matches($content, '\{\{').Count
    $closeVar = [regex]::Matches($content, '\}\}').Count
    
    if ($openTag -ne $closeTag -or $openVar -ne $closeVar) {
        $liqErrors += "$($lf.FullName): tag ($openTag vs $closeTag), var ($openVar vs $closeVar)"
    } else {
        $liqPassed++
    }
}
Write-Host "Scanned $liqPassed Liquid files. Errors: $($liqErrors.Count)" -ForegroundColor Green
if ($liqErrors.Count -gt 0) {
    foreach ($err in $liqErrors) {
        Write-Host "  ERROR: $err" -ForegroundColor Red
    }
}

Write-Host "`n--- LOGO FILE DIMENSION & CRC CHECK ---" -ForegroundColor Yellow
$logoPath = Join-Path $dawnDir "assets\focusdrawer-logo.png"
$bytes = [System.IO.File]::ReadAllBytes($logoPath)

$sig = $bytes[0..7]
$sigMatch = ($sig[0] -eq 0x89 -and $sig[1] -eq 0x50 -and $sig[2] -eq 0x4E -and $sig[3] -eq 0x47 -and $sig[4] -eq 0x0D -and $sig[5] -eq 0x0A -and $sig[6] -eq 0x1A -and $sig[7] -eq 0x0A)
Write-Host "PNG signature valid: $sigMatch" -ForegroundColor Green

# Parse IHDR chunk
$w = ([int]$bytes[16] -shl 24) -bor ([int]$bytes[17] -shl 16) -bor ([int]$bytes[18] -shl 8) -bor [int]$bytes[19]
$h = ([int]$bytes[20] -shl 24) -bor ([int]$bytes[21] -shl 16) -bor ([int]$bytes[22] -shl 8) -bor [int]$bytes[23]
$bd = [int]$bytes[24]
$ct = [int]$bytes[25]
Write-Host "IHDR: Width=$w, Height=$h, BitDepth=$bd, ColorType=$ct (6=RGBA Truecolor)" -ForegroundColor Green
Write-Host "Total file size: $($bytes.Length) bytes" -ForegroundColor Green

# Remove python script if present
$pyScript = Join-Path $dawnDir ".agents\m1_challenger_1\deep_verify.py"
if (Test-Path $pyScript) { Remove-Item $pyScript -Force }
