function Get-Icon{
    param(
        [Parameter(Mandatory = $true)]
        $fileSystemInfo, 

        [Parameter(Mandatory = $true)]
        [hashtable]$iconTheme,

        [Parameter(Mandatory = $true)]
        [hashtable]$glyphs
    )

    $iconName = Get-IconName -fileSystemInfo $fileSystemInfo -iconTheme $iconTheme

    return $glyphs[$iconName]
}

# Following are internal methods
function Get-IconName{
    param(
        [Parameter(Mandatory = $true)]
        $fileSystemInfo, 
        
        [Parameter(Mandatory = $true)]
        [hashtable]$iconTheme
    )
    
    $isDirectory = Get-IsDirectory -fileSystemInfo $fileSystemInfo
    $name = $fileSystemInfo.name
    $fileExt = Get-FileExtension -fileName $fileSystemInfo.FullName

    if($isDirectory){
        $iconName = Get-FolderIconName -name $name -iconTheme $iconTheme
    }else{
        $iconName = Get-FileIconName -name $name -fileExt $fileExt -iconTheme $iconTheme
    }

    $iconName = Get-PatchedIconName -iconName $iconName

    return $iconName
}


function Get-PatchedIconName{
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


