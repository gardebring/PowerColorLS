function Get-PatchedPowerColorLSIcon{
    Param($iconName)
    switch($iconName){
        "nf-mdi-view_list"{
            return "nf-fa-th_list"
        }
        "nf-mdi-xml"{
            return "nf-fa-code"
        }
        default{
            return $iconName
        }
    }
}

function Get-FolderIconName{
    Param($name, $iconTheme)

    $iconName = $iconTheme.Types.Directories.WellKnown[$name]

    if($null -eq $iconName){
        $iconName = $iconTheme.Types.Directories[""]
    }

    return $iconName
}

function Get-FileIconName{
    Param($name, $fileExt, $iconTheme)

    $iconName = $iconTheme.Types.Files.WellKnown[$name]
    if($null -eq $iconName){
        $iconName = $iconTheme.Types.Files[$fileExt]
    }
    if($null -eq $iconName){
        $iconName = $iconTheme.Types.Files[""]
    }

    return $iconName
}


function Get-ItemIconName{
    Param($isFolder, $name, $fileExt, $iconTheme)
    if($isFolder){
        $iconName = Get-FolderIconName -name $name -iconTheme $iconTheme
    }else{
        $iconName = Get-FileIconName -name $name -fileExt $fileExt -iconTheme $iconTheme
    }

    $iconName = Get-PatchedPowerColorLSIcon -iconName $iconName

    return $iconName
}

function Get-ItemIcon{
    Param($isFolder, $name, $fileExt, $iconTheme, $glyphs)

    $iconName = Get-ItemIconName -isFolder $isFolder -name $name -fileExt $fileExt -iconTheme $iconTheme

    return $glyphs[$iconName]
}