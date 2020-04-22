function Get-PatchedPowerColorLSIcon{
    param(
        [Parameter(Mandatory = $true)]
        [string]$iconName
    )

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
    param(
        [Parameter(Mandatory = $true)]
        [string]$name,

        [Parameter(Mandatory = $true)]
        [hashtable]$iconTheme
    )

    $iconName = $iconTheme.Types.Directories.WellKnown[$name]

    if($null -eq $iconName){
        $iconName = $iconTheme.Types.Directories[""]
    }

    return $iconName
}

function Get-FileIconName{
    param(
        [Parameter(Mandatory = $true)]
        [string]$name, 
        
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$fileExt, 
        
        [Parameter(Mandatory = $true)]
        [hashtable]$iconTheme
    )

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
    param(
        [Parameter(Mandatory = $true)]
        [bool]$isFolder, 
        
        [Parameter(Mandatory = $true)]
        [string]$name, 
        
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$fileExt, 
        
        [Parameter(Mandatory = $true)]
        [hashtable]$iconTheme
    )

    if($isFolder){
        $iconName = Get-FolderIconName -name $name -iconTheme $iconTheme
    }else{
        $iconName = Get-FileIconName -name $name -fileExt $fileExt -iconTheme $iconTheme
    }

    $iconName = Get-PatchedPowerColorLSIcon -iconName $iconName

    return $iconName
}

function Get-ItemIcon{
    param(
        [Parameter(Mandatory = $true)]
        [bool]$isFolder, 

        [Parameter(Mandatory = $true)]
        [string]$name, 

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$fileExt,

        [Parameter(Mandatory = $true)]
        [hashtable]$iconTheme,

        [Parameter(Mandatory = $true)]
        [hashtable]$glyphs
    )

    $iconName = Get-ItemIconName -isFolder $isFolder -name $name -fileExt $fileExt -iconTheme $iconTheme

    return $glyphs[$iconName]
}