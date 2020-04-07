#Requires -Modules Terminal-Icons
$terminalIconsFolder = [System.IO.Path]::GetDirectoryName((Get-Module Terminal-Icons).path)
$theme 		= "devblackops"
$glyphs     = . $terminalIconsFolder/Data/glyphs.ps1
$iconTheme 	= Import-PowerShellDataFile "${terminalIconsFolder}/Data/iconThemes/$theme.psd1"
$colorTheme	= Import-PowerShellDataFile "${terminalIconsFolder}/Data/colorThemes/$theme.psd1"
. $terminalIconsFolder/Private/ConvertFrom-RGBColor.ps1

function Show-Help{
    Write-Host "Usage: PowerColorLs [OPTION]... [FILE]..."
    Write-Host "List information about files and directories (the current directory by default)."
    Write-Host "Entries will be sorted alphabetically if no sorting option is specified."
    Write-Host ""
    Write-Host "`t-a, --all`t`tdo not ignore hidden files and files starting with ."
    Write-Host "`t-l, --long`t`tuse a long listing format"
    Write-Host "`t-1`t`t`tlist one file per line"
    Write-Host "`t-d, --dirs`t`tshow only directories"
    Write-Host "`t-f, --files`t`tshow only files"
    Write-Host "`t-ds, --ds, -sds, --sds, --show-directory-size"
    Write-Host "`t`t`t`tshow directory size (can take a long time)"
    Write-Host ""
    Write-Host "sorting options:"
    Write-Host ""
    Write-Host "`t-sd, --sd, --sort-dirs, --group-directories-first"
    Write-Host "`t`t`t`tsort directories first"
    Write-Host "`t-sf, --sf, --sort-files, --group-files-first"
    Write-Host "`t`t`t`tsort files first"
    Write-Host "`t-t, -st, --st"
    Write-Host "`t`t`t`tsort by modification time, newest first"
    Write-Host ""
    Write-Host "general options:"
    Write-Host ""
    Write-Host "`t-h, --h, --help`t`tprints this help"
}

function Get-FriendlySize {
    param($Bytes)
    $sizes='B,KB,MB,GB,TB,PB,EB,ZB' -split ','
    for($i=0; ($Bytes -ge 1kb) -and
        ($i -lt $sizes.Count); $i++) {$Bytes/=1kb}
    $N=0; if($i -eq 0) {$N=0}
    "{0:N$($N)} {1}" -f $Bytes, $sizes[$i]
}

function PowerColorLS{
<#
 .Synopsis
  Displays a colorized directory and file listing with icons.

 .Description
  List information about files and directories (the current directory by default).
  Entries will be sorted alphabetically if no sorting option is specified.
  The directories and files will be displayed with an icon and color scheme.
  The module has a dependency on the powershell module Terminal-Icons (https://github.com/devblackops/Terminal-Icons/) 
  being installed and configured first.

    Usage: PowerColorLs [OPTION]... [FILE]..."

        options:   
        -a, --all           do not ignore hidden files and files starting with .
        -l, --long          use a long listing format
        -1                  list one file per line
        -d, --dirs          show only directories
        -f, --files         show only files
        -ds, --ds, -sds, --sds, --show-directory-size
                            show directory size (can take a long time)
    
        sorting options:
    
        -sd, --sd, --sort-dirs, --group-directories-first
                            sort directories first
        -sf, --sf, --sort-files, --group-files-first
                            sort files first
        -t, -st, --st
                            sort by modification time, newest first
    
        general options:
    
        -h, --h, --help     prints help information

 .Example
   # Show help
   Get-ColorizedDirectoryListing -h

 .Example
   # Show a lising of all files and directories in the current location sorted by name
   Get-ColorizedDirectoryListing

 .Example
   # Show a lising of all files and directories in c:\test sorted by directories first
   Get-ColorizedDirectoryListing -sd c:\test

 .Example
   # Show a lising of all files and directories matching *name* in the current location sorted by files first
   Get-ColorizedDirectoryListing -sf *name*

 .Example
   # Show a lising of all files and directories in the current location, including hidden files
   Get-ColorizedDirectoryListing --all

 .Example
   # Show a lising of all files and directories in the current location, including hidden files, sorted by modification time
   Get-ColorizedDirectoryListing --all -t

 .Example
   # Show a lising of all files and directories in the current location in a long format
   Get-ColorizedDirectoryListing --long   

 .Example
   # Show a lising of all files and directories in the current location in a long format including directory size
   Get-ColorizedDirectoryListing --long --show-directory-size

#>    
    $query = "."

    # options
    $option_oneEntryPerLine = $false
    $option_showHiddenFiles = $false
    $option_dirOnly = $false
    $option_fileOnly = $false
    $option_longFormat = $false
    $option_dirsFirst = $false
    $option_filesFirst = $false
    $option_sortByModificationTime = $false
    $option_showDirectorySize = $false

    # load options
    if($args){
        foreach($arg in $args){
            if($arg -eq $null){

            }else{
                $a = "$arg"
                $isPath = Test-Path -path $a
                if($isPath){
                    $query = $arg
                }else{
                    switch ($a) {
                        {(($a -eq "-h") -or ($a -eq "--h") -or ($a -eq "--help"))} { 
                            Show-Help
                            return
                       }
                        "-1" {
                             $option_oneEntryPerLine = $true
                        }
                        {(($a -eq "-a") -or ($a -eq "--all") -or ($a -eq "--almost-all"))} { 
                            $option_showHiddenFiles = $true
                        } 
                        {(($a -eq "-d") -or ($a -eq "--dirs") -or ($a -eq "--directory"))} { 
                            $option_dirOnly = $true
                        }
                        {(($a -eq "-f") -or ($a -eq "--files"))} { 
                            $option_fileOnly = $true
                        }
                        {(($a -eq "-l") -or ($a -eq "--long"))} { 
                            $option_longFormat = $true
                        }
                        {(($a -eq "-sd") -or ($a -eq "--sd") -or ($a -eq "--sort-dirs") -or ($a -eq "--group-directories-first"))} { 
                            $option_dirsFirst = $true
                        }
                        {(($a -eq "-sf") -or ($a -eq "--sf") -or ($a -eq "--sort-files") -or ($a -eq "--group-files-first"))} { 
                            $option_filesFirst = $true
                        }
                        {(($a -eq "-t") -or ($a -eq "--st") -or ($a -eq "-st"))} { 
                            $option_sortByModificationTime = $true
                        }
                        {(($a -eq "-ds") -or ($a -eq "--ds") -or ($a -eq "-sds") -or ($a -eq "--sds") -or ($a -eq "--show-directory-size"))} { 
                            $option_showDirectorySize = $true
                        }
                        default{
                            if($a -like('-*')){
                                Write-Host "invalid option $a"
                            }else{
                                Write-Host "$a is not a valid path"
                            }
                            return
                        }
                    } 
                    
                }
            }
        }
    }

    # use options

    # get the items
    if($option_showHiddenFiles){
        $filesAndFolders = Get-ChildItem $query -force
    }else{
        $filesAndFolders = Get-ChildItem $query
    }

    # sorting
    if($option_sortByModificationTime){
        $filesAndFolders = $filesAndFolders  | Sort Lastwritetime -descending 
    }elseif($option_dirsFirst){
    }elseif($option_filesFirst){
        $filesAndFolders = $filesAndFolders | Sort Attributes -descending 
    }else{
        $filesAndFolders = $filesAndFolders  | Sort Name 
    }
    
    # determine the longest items so we can adapt the list to the console window width
    $longestItem = $filesAndFolders | Select-Object Name, FullName | Sort-Object { "$_".Length } -descending | Select-Object -first 1
    $longestItemLength = ($longestItem).name.Length
    $longestItemIsFolder = Test-Path -path ($longestItem.FullName) -pathtype container
    if(($longestItemIsFolder) -and (-not $option_fileOnly)){
        $longestItemLength += 1
    }

    if($option_longFormat){
        $acls = $filesAndFolders | get-acl -ErrorAction SilentlyContinue
        $longestOwnerAcl = ($acls | Select-Object Owner | Sort-Object { "$_".Length } -descending | Select-Object -first 1).Owner
        $longestOwnerAclLength = $longestOwnerAcl.Length

        $longestGroupAcl = ($acls | Select-object Group | Sort-Object { "$_".Length } -descending | Select-Object -first 1).Group
        $longestGroupAclLength = $longestGroupAcl.Length

        $longestDate = ($filesAndFolders | Select-Object @{n="LastWriteTime";e={$_.Lastwritetime.ToString("f")}} | Sort-Object { "$_".Length } -descending | Select-Object -first 1).LastWriteTime
        $longestDateLength = $longestDate.Length

        $fullItemMaxLength = 11 + 2 + $longestOwnerAclLength + 2 + $longestGroupAclLength + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5
        $noGroupMaxLength = 11 + 2 + $longestOwnerAclLength + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5
        $noGroupOrOwnerMaxLength = 11 + 2 + 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5
        $noGroupOrOwnerOrModeMaxLength = 8 + 2 +  $longestDateLength + 2 + $longestItemLength + 5
    }

	$itemSpacerWidth = 4
    $lineCharsCounter = 0

    # get how many characters we have available in this console window
    $availableCharWith = (Get-Host).ui.rawui.buffersize.width

    # start iterating over our items
	foreach ($e in $filesAndFolders) {
		$isFolder = Test-Path -path ($e.FullName) -pathtype container
		$fileExt = [System.IO.Path]::GetExtension($e.name)
		$name = $e.name
        $extra = ""

        $ignoreFile = $false

        if((-not $option_showHiddenFiles) -and ($name.StartsWith("."))) {
            $ignoreFile = $true
        } 

        if(($option_dirOnly) -and (-not $isFolder)) {
            $ignoreFile = $true
        }

        if(($option_fileOnly) -and ($isFolder)) {
            $ignoreFile = $true
        }

        if(-not $ignoreFile){

            if($isFolder){
                $extra = "\"
                $colorHex = $colorTheme.Types.Directories.WellKnown[$name]
                if($colorHex -eq $null){
                    $colorHex = "EEEE8B"
                }

                $iconName = $iconTheme.Types.Directories.WellKnown[$name]
                if($iconName -eq $null){
                    $iconName = $iconTheme.Types.Directories[""]
                }
            }else{
                $colorHex = $colorTheme.Types.Files.WellKnown[$name]
                if($colorHex -eq $null){
                    $colorHex = $colorTheme.Types.Files[$fileExt]
                }
                if($colorHex -eq $null){
                    $colorHex = "EEEEEE"
                }

                $iconName = $iconTheme.Types.Files.WellKnown[$name]
                if($iconName -eq $null){
                    $iconName = $iconTheme.Types.Files[$fileExt]
                }
                if($iconName -eq $null){
                    $iconName = $iconTheme.Types.Files[""]
                }
            }

            $color = ConvertFrom-RGBColor -RGB ($colorHex)

            $nameOutput = "${name}${extra}"

            $icon = $glyphs[$iconName]
            if($option_longFormat){
                $acl = Get-Acl $e.FullName
                $lw = ($e.LastWriteTime).ToString("f")
                $owner = $acl.Owner
                $group = $acl.Group
                if($isFolder){
                    
                    if($option_showDirectorySize){
                        $size = Get-FriendlySize((Get-Childitem $e.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Sum Length -ErrorAction SilentlyContinue | select sum).sum)
                    }else{
                        $size = ""
                    }
                }else{
                    $size = Get-FriendlySize($e.Length)
                }
                $sizeWithSpace = $size.PadRight(8)

                $mode = ""
                foreach ($m in $e.Mode.ToCharArray()) {
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

                $ownerWithSpace = "${owner}" + (" "*($longestOwnerAclLength - $owner.length))
                $groupWithSpace = "${group}" + (" "*($longestGroupAclLength - $group.length))
                $lwWithSpace = "${lw}" + (" "*($longestDateLength - $lw.Length))

                $ownerColor = (ConvertFrom-RGBColor -RGB ("FDFFBA"))
                $groupColor = (ConvertFrom-RGBColor -RGB ("D3D865"))
                $lwColor = (ConvertFrom-RGBColor -RGB ("45B2A1"))
                $sizeColor = (ConvertFrom-RGBColor -RGB ("FDFFBA"))

                if($availableCharWith -gt $fullItemMaxLength){
                    $printout = "${mode}  ${ownerColor}${ownerWithSpace}  ${groupColor}${groupWithSpace}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${color}${icon} ${nameOutput}"
                }elseif($availableCharWith -gt $noGroupMaxLength){
                    $printout = "${mode}  ${ownerColor}${ownerWithSpace}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${color}${icon} ${nameOutput}"
                }elseif($availableCharWith -gt $noGroupOrOwnerMaxLength){
                    $printout = "${mode}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${color}${icon} ${nameOutput}"
                }elseif($availableCharWith -gt $noGroupOrOwnerOrModeMaxLength){
                    $printout = "${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${color}${icon} ${nameOutput}"
                }else{
                    $printout = "${sizeColor}${sizeWithSpace}  ${color}${icon} ${nameOutput}"
                }
            }else{
                $printout = "${icon} ${nameOutput}" + (" "*($longestItemLength - $nameOutput.length + $itemSpacerWidth))
                $lineCharsCounter += $printout.length
            }

            if ((-not $option_oneEntryPerLine) -and(-not $option_longFormat) -and ( $lineCharsCounter -ge ($availableCharWith)) ) {
                write-host ""
                $lineCharsCounter = $printout.length
            }

            if($option_longFormat){
                write-host "${printout}"
            }elseif($option_oneEntryPerLine){
                write-host "${color}${printout}"
            }else{
                write-host "${color}${printout}" -nonewline
            }
        }
	}
}

Export-ModuleMember -Function PowerColorLs

