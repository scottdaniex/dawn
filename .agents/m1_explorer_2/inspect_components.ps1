$filesToInspect = @(
    "assets/component-card.css",
    "assets/component-product-variant-picker.css",
    "assets/component-swatch-input.css",
    "assets/component-cart-drawer.css",
    "assets/section-main-product.css",
    "assets/quick-add.css",
    "snippets/card-product.liquid",
    "snippets/buy-buttons.liquid"
)

foreach ($f in $filesToInspect) {
    if (Test-Path $f) {
        Write-Host "=========================================="
        Write-Host "FILE: $f"
        Write-Host "=========================================="
        $lines = Get-Content $f
        for ($i=0; $i -lt $lines.Length; $i++) {
            $l = $lines[$i]
            if ($l -match 'badge|button|focus|color-scheme|variant-picker|swatch|quick-add') {
                $start = [Math]::Max(0, $i - 1)
                $end = [Math]::Min($lines.Length - 1, $i + 3)
                Write-Host "--- Match at line $($i+1): $l"
            }
        }
    }
}
