# M2 Verification Script
$ErrorActionPreference = "Stop"

Write-Host "1. Testing header-group.json..."
$rawHg = [System.IO.File]::ReadAllText("$PSScriptRoot\..\sections\header-group.json", [System.Text.Encoding]::UTF8)
$hg = ConvertFrom-Json $rawHg
$text = $hg.sections."announcement-bar".blocks."announcement-bar-0".settings.text
$scheme = $hg.sections."announcement-bar".settings.color_scheme
$menuScheme = $hg.sections.header.settings.menu_color_scheme

if ($text -notmatch 'FREE SHIPPING ON WORKSPACE BUNDLES OVER') {
    throw "Unexpected announcement text: $text"
}
if ($text -notmatch '30-DAY SETUP GUARANTEE') {
    throw "Unexpected announcement text: $text"
}
if ($scheme -ne "scheme-3") {
    throw "Unexpected announcement scheme: $scheme"
}
if ($menuScheme -ne "scheme-2") {
    throw "Unexpected menu_color_scheme: $menuScheme"
}
Write-Host "  -> header-group.json verified." -ForegroundColor Green

Write-Host "2. Testing snippets/cart-drawer.liquid..."
$rawCd = [System.IO.File]::ReadAllText("$PSScriptRoot\..\snippets\cart-drawer.liquid", [System.Text.Encoding]::UTF8)
if ($rawCd -notmatch "free_shipping_threshold = 5000") {
    throw "cart-drawer.liquid missing free_shipping_threshold = 5000"
}
if ($rawCd -notmatch "cart-drawer__free-shipping-bar-fill") {
    throw "cart-drawer.liquid missing cart-drawer__free-shipping-bar-fill"
}
if ($rawCd -notmatch "cart-drawer__free-shipping-message") {
    throw "cart-drawer.liquid missing cart-drawer__free-shipping-message"
}
if ($rawCd -notmatch "is-unlocked") {
    throw "cart-drawer.liquid missing is-unlocked class"
}
Write-Host "  -> snippets/cart-drawer.liquid verified." -ForegroundColor Green

Write-Host "3. Testing assets/component-cart-drawer.css..."
$rawCdCss = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\component-cart-drawer.css", [System.Text.Encoding]::UTF8)
if ($rawCdCss -notmatch "\.cart-drawer__free-shipping") {
    throw "component-cart-drawer.css missing .cart-drawer__free-shipping"
}
if ($rawCdCss -notmatch "#E5A93C") {
    throw "component-cart-drawer.css missing #E5A93C"
}
if ($rawCdCss -notmatch "#2D2D2D") {
    throw "component-cart-drawer.css missing #2D2D2D"
}
Write-Host "  -> assets/component-cart-drawer.css verified." -ForegroundColor Green

Write-Host "4. Testing assets/component-menu-drawer.css..."
$rawMdCss = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\component-menu-drawer.css", [System.Text.Encoding]::UTF8)
if ($rawMdCss -notmatch "backdrop-filter: blur\(8px\)") {
    throw "component-menu-drawer.css missing backdrop-filter: blur(8px)"
}
if ($rawMdCss -notmatch "\.menu-drawer__menu-item--active") {
    throw "component-menu-drawer.css missing .menu-drawer__menu-item--active"
}
Write-Host "  -> assets/component-menu-drawer.css verified." -ForegroundColor Green

Write-Host "5. Testing assets/component-list-menu.css..."
$rawLmCss = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\component-list-menu.css", [System.Text.Encoding]::UTF8)
if ($rawLmCss -notmatch "\.header__active-menu-item") {
    throw "component-list-menu.css missing .header__active-menu-item"
}
Write-Host "  -> assets/component-list-menu.css verified." -ForegroundColor Green

Write-Host "6. Testing assets/cart.js..."
$rawCjs = [System.IO.File]::ReadAllText("$PSScriptRoot\..\assets\cart.js", [System.Text.Encoding]::UTF8)
if ($rawCjs -notmatch "\.cart-drawer__free-shipping") {
    throw "cart.js missing .cart-drawer__free-shipping selector"
}
Write-Host "  -> assets/cart.js verified." -ForegroundColor Green

Write-Host "`nAll Milestone 2 custom verifications passed 100%!" -ForegroundColor Green
