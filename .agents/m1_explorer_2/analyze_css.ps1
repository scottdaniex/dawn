$assets = Get-ChildItem -Path "assets" -Filter "*.css"
foreach ($file in $assets) {
    $content = Get-Content $file.FullName
    $buttonMatches = $content | Select-String -Pattern '\.button|button--primary|button--secondary|button--tertiary'
    $focusMatches = $content | Select-String -Pattern ':focus-visible|--focused|focus-ring|outline'
    $badgeMatches = $content | Select-String -Pattern '\.badge|badge--sale|badge--soldout'
    
    if ($buttonMatches.Count -gt 0 -or $focusMatches.Count -gt 0 -or $badgeMatches.Count -gt 0) {
        Write-Host "File: $($file.Name)"
        if ($buttonMatches.Count -gt 0) { Write-Host "  Buttons: $($buttonMatches.Count)" }
        if ($focusMatches.Count -gt 0) { Write-Host "  Focus: $($focusMatches.Count)" }
        if ($badgeMatches.Count -gt 0) { Write-Host "  Badges: $($badgeMatches.Count)" }
    }
}
