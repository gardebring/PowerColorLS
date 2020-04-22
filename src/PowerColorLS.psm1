#Requires -Modules Terminal-Icons
$terminalIconsFolder = [System.IO.Path]::GetDirectoryName((Get-Module Terminal-Icons).path)
$theme 		= "devblackops"
$glyphs     = . $terminalIconsFolder/Data/glyphs.ps1
$iconTheme 	= Import-PowerShellDataFile "${terminalIconsFolder}/Data/iconThemes/$theme.psd1"
$colorTheme	= Import-PowerShellDataFile "${terminalIconsFolder}/Data/colorThemes/$theme.psd1"
. $terminalIconsFolder/Private/ConvertFrom-RGBColor.ps1

. $PSScriptRoot/Helpers/CommandHelper.ps1
. $PSScriptRoot/Helpers/InfoHelper.ps1
. $PSScriptRoot/Helpers/GitHelper.ps1
. $PSScriptRoot/Helpers/OptionsHelper.ps1
. $PSScriptRoot/Helpers/LongFormatHelper.ps1
. $PSScriptRoot/Helpers/ColorHelper.ps1
. $PSScriptRoot/Helpers/IconHelper.ps1
. $PSScriptRoot/Helpers/FileAndFolderHelper.ps1
. $PSScriptRoot/Helpers/ReportHelper.ps1

function Splatter{
    param($x)
    return $x
}    


function Get-LongFormatPrintout{
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$e, 

        [Parameter(Mandatory = $true)]
        [bool]$isFolder, 

        [Parameter(Mandatory = $true)]
        [hashtable]$options, 

        [Parameter(Mandatory = $true)]
        [hashtable]$longFormatData,

        [Parameter(Mandatory = $true)]
        [string]$colorAndIcon, 

        [Parameter(Mandatory = $true)]
        [string]$nameOutput
    )
    
    try{
        $acl = Get-Acl $e.FullName
        $owner = $acl.Owner
        $group = $acl.Group
    }catch{
        $owner = ""
        $group = ""
    }

    $lw = ($e.LastWriteTime).ToString("f")
    if($isFolder){
        if($options.showDirectorySize){
            $size = Get-DirectorySize -directoryName $e.FullName
        }else{
            $size = ""
        }
    }else{
        $size = Get-FriendlySize -bytes $e.Length
    }

    $sizeWithSpace = $size.PadRight(8)

    $mode = Get-ModeForLongListing $e.Mode

    try{
        $ownerWithSpace = "${owner}" + (" "*($longFormatData.longestOwnerAclLength - $owner.length))
    }catch{
        $ownerWithSpace = ""
    }

    try{
        $groupWithSpace = "${group}" + (" "*($longFormatData.longestGroupAclLength - $group.length))
    }catch{
        $groupWithSpace = ""
    }
    $lwWithSpace = "${lw}" + (" "*($longFormatData.longestDateLength - $lw.Length))

    $ownerColor = $longFormatData.ownerColor
    $groupColor = $longFormatData.groupColor
    $sizeColor = $longFormatData.sizeColor
    $lwColor = $longFormatData.lwColor

    if($availableCharWith -gt $longFormatData.fullItemMaxLength){
        $printout = "${mode}  ${ownerColor}${ownerWithSpace}  ${groupColor}${groupWithSpace}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${colorAndIcon} ${nameOutput}"
    }elseif($availableCharWith -gt $longFormatData.noGroupMaxLength){
        $printout = "${mode}  ${ownerColor}${ownerWithSpace}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${colorAndIcon} ${nameOutput}"
    }elseif($availableCharWith -gt $longFormatData.noGroupOrOwnerMaxLength){
        $printout = "${mode}  ${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${colorAndIcon} ${nameOutput}"
    }elseif($availableCharWith -gt $longFormatData.noGroupOrOwnerOrModeMaxLength){
        $printout = "${sizeColor}${sizeWithSpace}  ${lwColor}${lwWithSpace}  ${colorAndIcon} ${nameOutput}"
    }else{
        $printout = "${sizeColor}${sizeWithSpace}  ${colorAndIcon} ${nameOutput}"
    }

    return $printout
}

function Splat {

    param(
        [string]
        $FunctionName,

        [hashtable]
        $Params
    )

    & $FunctionName @Params
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

    Usage: PowerColorLS [OPTION]... [FILE]..."

        options:
        -a, --all           do not ignore hidden files and files starting with .
        -l, --long          use a long listing format
        -r, --report        shows a brief report
        -1                  list one file per line
        -d, --dirs          show only directories
        -f, --files         show only files
        -ds, -sds, --sds, --show-directory-size
                            show directory size (can take a long time)

        sorting options:

        -sd, --sort-dirs, --group-directories-first
                            sort directories first
        -sf, --sort-files, --group-files-first
                            sort files first
        -t, -st, --st
                            sort by modification time, newest first

        general options:

        -h, --help     prints help information
        -v, --version  show version information

 .Example
   # Show help
   PowerColorLS -h

 .Example
   # Show a lising of all files and directories in the current location sorted by name
   PowerColorLS

 .Example
   # Show a lising of all files and directories in c:\test sorted by directories first
   PowerColorLS -sd c:\test

 .Example
   # Show a lising of all files and directories matching *name* in the current location sorted by files first
   PowerColorLS -sf *name*

 .Example
   # Show a lising of all files and directories in the current location, including hidden files
   PowerColorLS --all

 .Example
   # Show a lising of all files and directories in the current location, including hidden files, sorted by modification time
   PowerColorLS --all -t

 .Example
   # Show a lising of all files and directories in the current location in a long format
   PowerColorLS --long

 .Example
   # Show a lising of all files and directories in the current location in a long format including directory size
   PowerColorLS --long --show-directory-size

#>

    $get_optionsResult = Get-OptionsResult -arguments $args

    if($get_optionsResult.continue -eq $false){
        if($null -ne $get_optionsResult.errorMessage){
            $errMsg = (ConvertFrom-RGBColor -RGB ("FF0000")) + $glyphs["nf-fa-warning"] + " " + $get_optionsResult.errorMessage
            Write-Host $errMsg
        }
        return
    }

    $query = $get_optionsResult.query

    # load options
    $options = $get_optionsResult.options

    # get the items
    $filesAndFolders = Get-FilesAndFoldersListing -options $options -query $query

    if($filesAndFolders.Length -eq 0){ # nothing found
        return
    }

    # get the directory for the items listed
    $directoryName = Get-DirectoryName -filesAndFolders $filesAndFolders

    # determine if we should handle this as git directory
    $isGitDirectory = Get-ShowAsGitDirectory -directory $directoryName

    if($isGitDirectory){
        $gitStatusItems = Get-GitStatusItemList -directory $directoryName
    }

    # sorting
    $filesAndFolders = Get-SortedFilesAndFoldersListing -filesAndFolders $filesAndFolders -options $options

    # determine the longest items so we can adapt the list to the console window width
    $longestItem = $filesAndFolders | Select-Object Name, FullName | Sort-Object { "$_".Length } -descending | Select-Object -first 1
    $longestItemLength = ($longestItem).name.Length
    $longestItemIsFolder = Test-Path -path ($longestItem.FullName) -pathtype container
    if(($longestItemIsFolder) -and (-not $options.fileOnly)){
        $longestItemLength += 1
    }

    $longFormatData = Get-LongFormatData -options $options -filesAndFolders $filesAndFolders -IsGitDirectory $isGitDirectory

	$itemSpacerWidth = 4
    $lineCharsCounter = 0

    # get how many characters we have available in this console window
    $availableCharWith = (Get-Host).ui.rawui.buffersize.width

    $fileCount = 0
    $folderCount = 0

    # start iterating over our items
	foreach ($e in $filesAndFolders) {
		$isFolder = Get-IsFolder -fullName $e.FullName
        $fileExt = Get-FileExtension -fileName $e.FullName
        
		$name = $e.name
        $extra = ""

        $ignoreItem = Get-IgnoreItem -options $options -name $name -isFolder $isFolder

        if(-not $ignoreItem){

            if($isFolder){
                $extra = "\"
                $folderCount++
            }else{
                $fileCount++
            }

            $color = Get-ItemColor -isFolder $isFolder -name $name -fileExt $fileExt -colorTheme $colorTheme
            $icon = Get-ItemIcon -isFolder $isFolder -name $name -fileExt $fileExt -iconTheme $iconTheme -glyphs $glyphs
            $colorAndIcon = "${color}${icon}"

            $gitColorAndIcon = Get-GitColorAndIcon -isGitDirectory $isGitDirectory -entity $e -gitStatusItems $gitStatusItems -glyphs $glyphs

            if($IsGitDirectory){
                $colorAndIcon = "${gitColorAndIcon}${colorAndIcon}"
            }

            $nameOutput = "${name}${extra}"

            if($options.longFormat){
                $printout = Splat Get-LongFormatPrintout @{
                    e = $e
                    isFolder = $isFolder
                    options = $options
                    longFormatData = $longFormatData
                    colorAndIcon = $colorAndIcon
                    nameOutput = $nameOutput
                }

            }else{
                $printout = "${icon} ${nameOutput}" + (" "*($longestItemLength - $nameOutput.length + $itemSpacerWidth))
                $lineCharsCounter += $printout.length
                if($isGitDirectory){
                    $lineCharsCounter += 2
                }
            }
            
            if ((-not $options.oneEntryPerLine) -and(-not $options.longFormat) -and ( $lineCharsCounter -ge ($availableCharWith)) ) {
                Write-Host ""
                $lineCharsCounter = $printout.length
                if($isGitDirectory){
                    $lineCharsCounter += 2
                }
            }

            if($options.longFormat){
                Write-Host "${printout}"
            }elseif($options.oneEntryPerLine){
                Write-Host "${gitColorAndIcon}${color}${printout}"
            }else{
                Write-Host "${gitColorAndIcon}${color}${printout}" -nonewline
            }
        }
	}

    if($options.showReport){
        Get-Report -options $options -filesAndFolders $filesAndFolders -query $query -folderCount $folderCount -fileCount $fileCount
    }

    if(-not $options.longFormat){
        Write-Host ""
    }
}

Export-ModuleMember -Function PowerColorLs
