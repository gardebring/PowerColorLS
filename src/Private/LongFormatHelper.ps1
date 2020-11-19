function Get-LongFormatPrintout{
    param(
        [Parameter(Mandatory = $true)]
        $fileSystemInfo, 

        [Parameter(Mandatory = $true)]
        [hashtable]$options, 

        [Parameter(Mandatory = $true)]
        [hashtable]$longFormatData,

        [Parameter(Mandatory = $true)]
        [string]$colorAndIcon,

        [Parameter(Mandatory = $true)]
        [int]$availableCharWith
    )

    $isDirectory = Get-IsDirectory -fileSystemInfo $fileSystemInfo
    $nameForDisplay = Get-NameForDisplay -fileSystemInfo $fileSystemInfo
    $mode = Get-ModeForLongListing -modeInput $fileSystemInfo.Mode -hideIcons $options.hideIcons
    $lastWriteTime = ($fileSystemInfo.LastWriteTime).ToString("f")

    try{
        $acl = Get-Acl $fileSystemInfo.FullName
        $owner = $acl.Owner
        $group = $acl.Group
    }catch{
        $owner = ""
        $group = ""
    }

    if($isDirectory){
        if($options.showDirectorySize){
            $size = Get-DirectorySize -directoryName $fileSystemInfo.FullName
        }else{
            $size = ""
        }
    }else{
        $size = Get-FriendlySize -bytes $fileSystemInfo.Length
    }

    $sizeWithSpace = $size.PadRight(8)

    try{
        $ownerSpace = $longFormatData.longestOwnerAclLength - $owner.length
        $ownerWithSpace = "${owner}" + (" "*($ownerSpace))
    }catch{
        $ownerWithSpace = ""
    }

    try{
        $groupSpace = $longFormatData.longestGroupAclLength - $group.length
        $groupWithSpace = "${group}" + (" "*($groupSpace))
    }catch{
        $groupWithSpace = ""
    }

    $lwSpace = $longFormatData.longestDateLength - $lastWriteTime.Length

    $lwWithSpace = "${lastWriteTime}" + (" "*($lwSpace))

    $ownerColor = $longFormatData.ownerColor
    $groupColor = $longFormatData.groupColor
    $sizeColor = $longFormatData.sizeColor
    $lwColor = $longFormatData.lwColor

    if($availableCharWith -gt $longFormatData.fullItemMaxLength){
        $printout = "${mode}  ${ownerColor}${ownerWithSpace}  ${groupColor}${groupWithSpace}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${colorAndIcon} ${nameForDisplay}"
    }elseif($availableCharWith -gt $longFormatData.noGroupMaxLength){
        $printout = "${mode}  ${ownerColor}${ownerWithSpace}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${colorAndIcon} ${nameForDisplay}"
    }elseif($availableCharWith -gt $longFormatData.noGroupOrOwnerMaxLength){
        $printout = "${mode}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${colorAndIcon} ${nameForDisplay}"
    }elseif($availableCharWith -gt $longFormatData.noGroupOrOwnerOrModeMaxLength){
        $printout = "${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${colorAndIcon} ${nameForDisplay}"
    }else{
        $printout = "${sizeColor}${sizeWithSpace}  ${colorAndIcon} ${nameForDisplay}"
    }

    return $printout
}

function Get-LongFormatData{
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$options, 

        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders, 

        [Parameter(Mandatory = $true)]
        [int]$longestItemLength
    )

    if($options.longFormat){
        Try {
            $acls = $filesAndFolders | get-acl
            $longestOwnerAcl = Get-LongestItem -items $acls -scriptBlock {return $item.Owner}
            $longestGroupAcl = Get-LongestItem -items $acls -scriptBlock {return $item.Group}
        }
        Catch {
            $acls = ""
            $longestGroupAcl = ""
        }
        Finally {
        }

        $longestDate = Get-LongestItem -items $filesAndFolders -scriptBlock {return $item.LastWriteTime.ToString("f")}

        $directoryName = Get-DirectoryName -filesAndFolders $filesAndFolders

        # determine if we should handle this as git directory
        $isGitDirectory = Get-ShowAsGitDirectory -directory $directoryName

         if($isGitDirectory){
            $gitIncrease = 2
        }else{
            $gitIncrease = 0
        }

        $longestOwnerAclLength = $longestOwnerAcl.Length
        $longestGroupAclLength = $longestGroupAcl.Length
        $longestDateLength = $longestDate.Length + 1

        return @{
            longestOwnerAclLength = $longestOwnerAclLength
            longestGroupAclLength = $longestGroupAclLength
            longestDateLength = $longestDateLength

            # Calculate max lengths of different long outputs so we can determine how much will fit in the console
            fullItemMaxLength = (11 + 2 + $longestOwnerAclLength + 2 + $longestGroupAclLength + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5 + $gitIncrease)
            noGroupMaxLength = (11 + 2 + $longestOwnerAclLength + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5 + $gitIncrease)
            noGroupOrOwnerMaxLength = (11 + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5 + $gitIncrease)
            noGroupOrOwnerOrModeMaxLength = (8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5 + $gitIncrease)

            ownerColor = (ConvertFrom-RGBColor -RGB ("FDFFBA"))
            groupColor = (ConvertFrom-RGBColor -RGB ("D3D865"))
            lwColor = (ConvertFrom-RGBColor -RGB ("45B2A1"))
            sizeColor = (ConvertFrom-RGBColor -RGB ("FDFFBA"))
        }
    }
    return $null
}

function Get-Mode-Attribute-Color{
    param(
        [Parameter(Mandatory = $true)]
        [string]$attribute
    )

    switch($attribute){
        "d" {
            return (ConvertFrom-RGBColor -RGB ("EEEE8B"))
        }
        "a" {
            return (ConvertFrom-RGBColor -RGB ("EE82EE"))
        }
        "r" {
            return (ConvertFrom-RGBColor -RGB ("6382FF"))
        }
        "h" {
            return (ConvertFrom-RGBColor -RGB ("BABABA"))
        }
        "s" {
            return (ConvertFrom-RGBColor -RGB ("EDA1A1"))
        }
        default{
            return (ConvertFrom-RGBColor -RGB ("EEEEEE"))
        }
    }
}

function Get-ModeForLongListing{
    param(
        [Parameter(Mandatory = $true)]
        [string]$modeInput,

        [Parameter(Mandatory = $true)]
        [bool]$hideIcons
    )

    $mode = ""
    foreach ($m in $modeInput.ToCharArray()) {
        $color = Get-Mode-Attribute-Color($m)
        if($hideIcons){
            $mode += $color + $m + " "
        }else{
            switch($m){
                "d" {
                    $mode += $color + $glyphs["nf-fa-folder_o"] + " "
                }
                "a" {
                    $mode += $color + $glyphs["nf-fa-archive"] + " "
                }
                "r" {
                    $mode += $color + $glyphs["nf-fa-lock"] + " "
                }
                "h" {
                    $mode += $color + $glyphs["nf-mdi-file_hidden"] + " "
                }
                "s" {
                    $mode += $color + $glyphs["nf-fa-gear"] + " "
                }
                default{
                    $mode += $color +  $m + " "
                }
            }
        }
    }
    return $mode
}