$filePath = Resolve-Path ".agents/m4_explorer_2/test_product_blocks.json"
$content = Get-Content -Path $filePath -Raw
$jsonObj = ConvertFrom-Json -InputObject $content
Write-Host "VALID JSON: Yes"
Write-Host ("Blocks in main section: " + $jsonObj.sections.main.block_order.Count)
foreach ($b in $jsonObj.sections.main.block_order) {
    $type = $jsonObj.sections.main.blocks.$b.type
    Write-Host ("  - Block: " + $b + " (type: " + $type + ")")
}
