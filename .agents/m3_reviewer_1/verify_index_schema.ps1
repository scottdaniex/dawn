$indexJson = Get-Content -Raw "templates/index.json" | ConvertFrom-Json
$sectionsDir = "sections"
$errors = @()

foreach ($secProp in $indexJson.sections.PSObject.Properties) {
    $secName = $secProp.Name
    $secData = $secProp.Value
    $secType = $secData.type
    $secFile = Join-Path $sectionsDir "$secType.liquid"
    
    if (-not (Test-Path $secFile)) {
        $errors += "Section $secName has non-existent file $secFile"
        continue
    }
    
    $content = [System.IO.File]::ReadAllText((Resolve-Path $secFile).Path, [System.Text.Encoding]::UTF8)
    if ($content -match '(?s)\{%-?\s*schema\s*-?%\}(.*?)\{%-?\s*endschema\s*-?%\}') {
        $schema = ConvertFrom-Json $matches[1]
        
        # Check section settings
        $validSettingIds = @($schema.settings | ForEach-Object { $_.id })
        if ($secData.settings) {
            foreach ($settingProp in $secData.settings.PSObject.Properties) {
                if ($validSettingIds -notcontains $settingProp.Name) {
                    $errors += "Section $secName ($secType): invalid setting $($settingProp.Name)"
                }
            }
        }
        
        # Check blocks
        if ($secData.blocks) {
            $validBlockTypes = @($schema.blocks | ForEach-Object { $_.type })
            foreach ($blkProp in $secData.blocks.PSObject.Properties) {
                $blkName = $blkProp.Name
                $blkData = $blkProp.Value
                $blkType = $blkData.type
                
                if ($validBlockTypes -notcontains $blkType) {
                    $errors += "Section $secName ($secType): block $blkName has invalid type $blkType"
                    continue
                }
                
                $blkSchema = $schema.blocks | Where-Object { $_.type -eq $blkType } | Select-Object -First 1
                $validBlkSettingIds = @($blkSchema.settings | ForEach-Object { $_.id })
                if ($blkData.settings) {
                    foreach ($blkSettingProp in $blkData.settings.PSObject.Properties) {
                        if ($validBlkSettingIds -notcontains $blkSettingProp.Name) {
                            $errors += "Section $secName ($secType) -> block $blkName ($blkType): invalid setting $($blkSettingProp.Name)"
                        }
                    }
                }
            }
        }
    } else {
        $errors += "No schema found in $secFile"
    }
}

if ($errors.Count -eq 0) {
    Write-Host "ALL SETTINGS AND BLOCKS IN templates/index.json ARE 100% SCHEMA-COMPLIANT!" -ForegroundColor Green
} else {
    Write-Host "ERRORS FOUND:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}
