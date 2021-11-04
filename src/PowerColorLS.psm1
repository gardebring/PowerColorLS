#Requires -Modules Terminal-Icons
. $PSScriptRoot/Init/Import-Dependencies.ps1

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
        -hi, --hide-icons   hide icons

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

    # get our options
    $get_optionsResult = Get-OptionsResult -arguments $args

    if($get_optionsResult.continue -eq $false){
        if($null -ne $get_optionsResult.errorMessage){
            # something was wrong with the parameters provided:
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

    $fileAndFolderCount = ($filesAndFolders | Measure-Object).Count

    if($fileAndFolderCount -eq 0){ # nothing found
        return
    }

    # are we in a git directory? If so, get the data we need
    $gitInfo = Get-GitInfo -filesAndFolders $filesAndFolders

    # determine the longest items so we can adapt the list to the console window width
    $longestItemLength = Get-LongestItemLength -filesAndFolders $filesAndFolders

    $longFormatData = Splat Get-LongFormatData @{
        options = $options
        filesAndFolders = $filesAndFolders
        longestItemLength = $longestItemLength
    }

	$itemSpacerWidth = 4
    $lineCharsCounter = 0

    # get how many characters we have available in this console window
    $availableCharWith = $host.ui.rawui.buffersize.width

    if($null -eq $availableCharWith){
        $availableCharWith = 150
    }

    # start iterating over our items
	foreach ($fileSystemInfo in $filesAndFolders) {

        $color = Get-Color -fileSystemInfo $fileSystemInfo -colorTheme $colorTheme
        if(-not $options.hideIcons){
            $icon = Get-Icon -fileSystemInfo $fileSystemInfo -iconTheme $iconTheme -glyphs $glyphs
        }

        $colorAndIcon = "${color}${icon}"

        $gitColorAndIcon = Get-GitColorAndIcon -gitInfo $gitInfo -fileSystemInfo $fileSystemInfo -glyphs $glyphs -hideIcons $options.hideIcons
        $colorAndIcon = "${gitColorAndIcon}${colorAndIcon}"


        if($options.longFormat){
            $printout = Splat Get-LongFormatPrintout @{
                fileSystemInfo = $fileSystemInfo
                options = $options
                longFormatData = $longFormatData
                colorAndIcon = $colorAndIcon
                availableCharWith = $availableCharWith
            }

        }else{
            $nameForDisplay = Get-NameForDisplay -fileSystemInfo $fileSystemInfo
            if($options.hideIcons){
                $printout = "${icon}${nameForDisplay}" + (" "*($longestItemLength - $nameForDisplay.length + $itemSpacerWidth))
            }else{
                $printout = "${icon} ${nameForDisplay}" + (" "*($longestItemLength - $nameForDisplay.length + $itemSpacerWidth))
            }
            $lineCharsCounter += ($printout.length + $gitInfo.lineCharsCounterIncrease)
        }

        if ((-not $options.oneEntryPerLine) -and(-not $options.longFormat) -and ( $lineCharsCounter -ge ($availableCharWith)) ) {
            Write-Host ""
            $lineCharsCounter = ($printout.length + $gitInfo.lineCharsCounterIncrease)
        }

        if($options.longFormat){
            Write-Host "${printout}"
        }elseif($options.oneEntryPerLine){
            Write-Host "${gitColorAndIcon}${color}${printout}"
        }else{
            Write-Host "${gitColorAndIcon}${color}${printout}" -nonewline
        }
	}

    if($options.showReport){
        Show-Report -options $options -filesAndFolders $filesAndFolders -query $query
    }

    if(-not $options.longFormat){
        Write-Host ""
    }
}

Export-ModuleMember -Function PowerColorLs
