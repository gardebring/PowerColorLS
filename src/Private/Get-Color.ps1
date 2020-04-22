function Get-Color{
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$fileSystemInfo, 

        [Parameter(Mandatory = $true)]
        [hashtable]$colorTheme
    )

    $colorHex = Get-ColorHex -fileSystemInfo $fileSystemInfo -colorTheme $colorTheme

    return ConvertFrom-RGBColor -RGB ($colorHex)
}

# Following are internal methods

function Get-ColorHex{
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$fileSystemInfo, 
        
        [Parameter(Mandatory = $true)]
        [hashtable]$colorTheme
    )

    $isDirectory = Get-IsDirectory -fileSystemInfo $fileSystemInfo
    $name = $fileSystemInfo.name
    $fileExt = Get-FileExtension -fileName $fileSystemInfo.FullName
    
    if($isDirectory){
        $colorHex = Get-FolderColorHex -name $name -colorTheme $colorTheme
    }else{
        $colorHex = Get-FileColorHex -name $name -fileExt $fileExt -colorTheme $colorTheme
    }
    return $colorHex
}

function Get-FolderColorHex{
    param(
        [Parameter(Mandatory = $true)]
        [string]$name, 
        
        [Parameter(Mandatory = $true)]
        [hashtable]$colorTheme
    )

    $colorHex = $colorTheme.Types.Directories.WellKnown[$name]
    if($null -eq $colorHex){
        $colorHex = "EEEE8B"
    }

    return $colorHex
}

function Get-FileColorHex{
    param(
        [Parameter(Mandatory = $true)]
        [string]$name, 
        
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$fileExt, 
        
        [Parameter(Mandatory = $true)]
        [hashtable]$colorTheme
    )

    $colorHex = $colorTheme.Types.Files.WellKnown[$name]
    if($null -eq $colorHex){
        $colorHex = $colorTheme.Types.Files[$fileExt]
    }
    if($null -eq $colorHex){
        $colorHex = "EEEEEE"
    }

    return $colorHex
}
