function Get-Report{
    Param($options, $filesAndFolders, $query, $folderCount, $fileCount)
    $queryColor = (ConvertFrom-RGBColor -RGB ("00AAFF"))
    Write-Host ""
    if(-not $options.longFormat){
        Write-Host ""
    }
    $itemsLength = $filesAndFolders.Length
    Write-Host "Found ${itemsLength} files and folders matching ${queryColor}$query"
    Write-Host ""
    Write-Host "`tFolders:`t$folderCount"
    Write-Host "`tFiles:`t`t$fileCount"
    Write-Host ""
}