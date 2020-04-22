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

function Get-ItemColorHex{
    param(
        [Parameter()]
        [bool]$isFolder, 
        
        [Parameter(Mandatory = $true)]
        [string]$name, 

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$fileExt, 
        
        [Parameter(Mandatory = $true)]
        [hashtable]$colorTheme
    )

    if($isFolder){
        $colorHex = Get-FolderColorHex -name $name -colorTheme $colorTheme
    }else{
        $colorHex = Get-FileColorHex -name $name -fileExt $fileExt -colorTheme $colorTheme
    }
    return $colorHex
}

function Get-ItemColor{
    param(
        [Parameter()]
        [bool]$isFolder, 

        [Parameter(Mandatory = $true)]
        [string]$name, 

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$fileExt, 

        [Parameter(Mandatory = $true)]
        [hashtable]$colorTheme
    )

    $colorHex = Get-ItemColorHex -isFolder $isFolder -name $name -fileExt $fileExt -colorTheme $colorTheme

    return ConvertFrom-RGBColor -RGB ($colorHex)
}