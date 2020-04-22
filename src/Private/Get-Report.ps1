function Get-Report{
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$options, 

        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders, 

        [Parameter(Mandatory = $true)]
        [string]$query, 

        [Parameter(Mandatory = $true)]
        [long]$folderCount, 

        [Parameter(Mandatory = $true)]
        [long]$fileCount
    )
    
    $queryColor = (ConvertFrom-RGBColor -RGB ("00AAFF"))
    $baseColor = (ConvertFrom-RGBColor -RGB ("FFFFFF"))
    Write-Host ""
    if(-not $options.longFormat){
        Write-Host ""
    }

    $itemsLength = $filesAndFolders.Length
    Write-Host "${baseColor}Found ${itemsLength} files and folders matching ${queryColor}$query${baseColor}"
    Write-Host ""
    Write-Host "`tFolders:`t$folderCount"
    Write-Host "`tFiles:`t`t$fileCount"
    Write-Host ""
}