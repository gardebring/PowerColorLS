function Get-LongFormatData{
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$options, 

        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders, 

        [Parameter(Mandatory = $true)]
        [bool]$isGitDirectory
    )

    if($options.longFormat){
        Try {
            $acls = $filesAndFolders | get-acl -ErrorAction SilentlyContinue
            $longestOwnerAcl = ($acls | Select-Object Owner | Sort-Object { "$_".Length } -descending | Select-Object -first 1).Owner
            $longestGroupAcl = ($acls | Select-object Group | Sort-Object { "$_".Length } -descending | Select-Object -first 1).Group
        }
        Catch {
            $acls = ""
            $longestOwnerAcl = ""
            $longestGroupAcl = ""
        }
        Finally {
        }

        $longestDate = ($filesAndFolders | Select-Object @{n="LastWriteTime";e={$_.Lastwritetime.ToString("f")}} | Sort-Object { "$_".Length } -descending | Select-Object -first 1).LastWriteTime

        $gitIncrease = 0
        if($isGitDirectory){
            $gitIncrease = 2
        }

        return @{
            longestOwnerAclLength = $longestOwnerAcl.Length
            longestGroupAclLength = $longestGroupAcl.Length
            longestDateLength = $longestDate.Length

            # Calculate max lengths of different long outputs so we can determine how much will fit in the console
            fullItemMaxLength = 11 + 2 + $longestOwnerAclLength + 2 + $longestGroupAclLength + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5 + $gitIncrease
            noGroupMaxLength = 11 + 2 + $longestOwnerAclLength + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5 + $gitIncrease
            noGroupOrOwnerMaxLength = 11 + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5 + $gitIncrease
            noGroupOrOwnerOrModeMaxLength = 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5 + $gitIncrease

            ownerColor = (ConvertFrom-RGBColor -RGB ("FDFFBA"))
            groupColor = (ConvertFrom-RGBColor -RGB ("D3D865"))
            lwColor = (ConvertFrom-RGBColor -RGB ("45B2A1"))
            sizeColor = (ConvertFrom-RGBColor -RGB ("FDFFBA"))
        }
    }
    return $null
}

function Get-ModeForLongListing{
    param(
        [Parameter(Mandatory = $true)]
        [string]$modeInput
    )

    $mode = ""
    foreach ($m in $modeInput.ToCharArray()) {
        switch($m){
            "-" {
                $mode += (ConvertFrom-RGBColor -RGB ("EEEEEE")) + "- "
            }
            "d" {
                $mode += (ConvertFrom-RGBColor -RGB ("EEEE8B")) + $glyphs["nf-fa-folder_o"] + " "
            }
            "a" {
                $mode += (ConvertFrom-RGBColor -RGB ("EE82EE")) + $glyphs["nf-fa-archive"] + " "
            }
            "r" {
                $mode += (ConvertFrom-RGBColor -RGB ("6382FF")) + $glyphs["nf-fa-lock"] + " "
            }
            "h" {
                $mode += (ConvertFrom-RGBColor -RGB ("BABABA")) + $glyphs["nf-mdi-file_hidden"] + " "
            }
            "s" {
                $mode += (ConvertFrom-RGBColor -RGB ("EDA1A1")) + $glyphs["nf-fa-gear"] + " "
            }
            default{
                $mode += (ConvertFrom-RGBColor -RGB ("EEEEEE")) +  $m + " "
            }
        }
    }
    return $mode
}