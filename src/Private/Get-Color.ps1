function ConvertFrom-RGBColor {
    [OutputType([System.String])]
    param(
        [parameter(Mandatory)]
        [string]$RGB
    )

    $RGB = $RGB.Replace('#', '')
    $r   = [convert]::ToInt32($RGB.SubString(0,2), 16)
    $g   = [convert]::ToInt32($RGB.SubString(2,2), 16)
    $b   = [convert]::ToInt32($RGB.SubString(4,2), 16)

    $escape = [char]27
    return "${escape}[38;2;$r;$g;$b`m"
}

function Get-Color{
    param(
        [Parameter(Mandatory = $true)]
        $fileSystemInfo, 

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
        $fileSystemInfo, 
        
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
