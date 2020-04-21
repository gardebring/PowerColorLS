function Get-FolderColorHex{
    Param($name, $colorTheme)

    $colorHex = $colorTheme.Types.Directories.WellKnown[$name]
    if($null -eq $colorHex){
        $colorHex = "EEEE8B"
    }

    return $colorHex
}

function Get-FileColorHex{
    Param($name, $fileExt, $colorTheme)

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
    Param($isFolder, $name, $fileExt, $colorTheme)

    if($isFolder){
        $colorHex = Get-FolderColorHex -name $name -colorTheme $colorTheme
    }else{
        $colorHex = Get-FileColorHex -name $name -fileExt $fileExt -colorTheme $colorTheme
    }
    return $colorHex
}

function Get-ItemColor{
    Param($isFolder, $name, $fileExt, $colorTheme)

    $colorHex = Get-ItemColorHex -isFolder $isFolder -name $name -fileExt $fileExt -colorTheme $colorTheme

    return ConvertFrom-RGBColor -RGB ($colorHex)
}