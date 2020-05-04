function Show-Report{
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$options, 

        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders, 

        [Parameter(Mandatory = $true)]
        [string]$query
    )
    
    $directoryCount = ($filesAndFolders | Where-Object {$_.GetType() -eq [System.IO.DirectoryInfo]}).Length
    $fileCount = ($filesAndFolders | Where-Object {$_.GetType() -eq [System.IO.FileInfo]}).Length
    $itemsLength = $filesAndFolders.Length

    $queryColor = (ConvertFrom-RGBColor -RGB ("00AAFF"))
    $baseColor = (ConvertFrom-RGBColor -RGB ("FFFFFF"))

    $report = "
${baseColor}Found ${itemsLength} files and folders matching ${queryColor}$query${baseColor}
        Folders:    $directoryCount
        Files:      $fileCount
"

    if(-not $options.longFormat){
        Write-Host ""
    }

    Write-Host $report
}