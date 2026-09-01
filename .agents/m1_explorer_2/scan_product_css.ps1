$lines = Get-Content "assets/section-main-product.css"
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'accordion|sticky|collapsible|badge|focus|button|--color-') {
        Write-Host "Line $($i+1): $($lines[$i])"
    }
}
