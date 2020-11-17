function Get-OptionsResult{
    
    param(
        [array] $arguments
    )

    $options = @{
        oneEntryPerLine = $false
        showHiddenFiles = $false
        dirOnly = $false
        fileOnly = $false
        longFormat = $false
        dirsFirst = $false
        filesFirst = $false
        sortByModificationTime = $false
        showDirectorySize = $false
        showReport = $false
        hideIcons = $false
    }

    $get_optionsResult = @{
        continue = $true
        errorMessage = $null
        query = "."
    }

    if($arguments){
        foreach($arg in $arguments){
            if($null -ne $arg){
                $a = "$arg"
                $isPath = Test-Path -path $a
                if($isPath){
                    $get_optionsResult.query = $arg
                }else{
                    $aDashParsed = $a -replace "--", "-"
                    switch ($aDashParsed) {
                        {(($aDashParsed -eq "-h") -or ($aDashParsed -eq "-help"))} {
                            Show-Help
                            $get_optionsResult.continue = $false
                            return $get_optionsResult
                        }
                        {(($aDashParsed -eq "-v") -or ($aDashParsed -eq "-version"))} {
                            Show-Version
                            $get_optionsResult.continue = $false
                            return $get_optionsResult
                        }
                        "-1" {
                             $options.oneEntryPerLine = $true
                        }
                        {(($aDashParsed -eq "-a") -or ($aDashParsed -eq "-all") -or ($aDashParsed -eq "-almost-all"))} {
                            $options.showHiddenFiles = $true
                        }
                        {(($aDashParsed -eq "-d") -or ($aDashParsed -eq "-dirs") -or ($aDashParsed -eq "-directory"))} {
                            $options.dirOnly = $true
                        }
                        {(($aDashParsed -eq "-f") -or ($aDashParsed -eq "-files"))} {
                            $options.fileOnly = $true
                        }
                        {(($aDashParsed -eq "-l") -or ($aDashParsed -eq "-long"))} {
                            $options.longFormat = $true
                        }
                        {(($aDashParsed -eq "-sd") -or ($aDashParsed -eq "-sort-dirs") -or ($aDashParsed -eq "-group-directories-first"))} {
                            $options.dirsFirst = $true
                        }
                        {(($aDashParsed -eq "-sf") -or ($aDashParsed -eq "-sort-files") -or ($aDashParsed -eq "-group-files-first"))} {
                            $options.filesFirst = $true
                        }
                        {(($aDashParsed -eq "-t") -or ($aDashParsed -eq "-st"))} {
                            $options.sortByModificationTime = $true
                        }
                        {(($aDashParsed -eq "-ds") -or ($aDashParsed -eq "-sds") -or ($aDashParsed -eq "-sds") -or ($aDashParsed -eq "-show-directory-size"))} {
                            $options.showDirectorySize = $true
                        }
                        {(($aDashParsed -eq "-r") -or ($aDashParsed -eq "-report"))} {
                            $options.showReport = $true
                        }
                        {(($aDashParsed -eq "-hi") -or ($aDashParsed -eq "-hide-icons"))} {
                            $options.hideIcons = $true
                        }
                        default{
                            if($a -like('-*')){
                                $get_optionsResult.errorMessage = "invalid option $a"
                                $get_optionsResult.continue = $false
                                return $get_optionsResult

                            }else{
                                $get_optionsResult.errorMessage = "$a is not a valid path"
                                $get_optionsResult.continue = $false
                                return $get_optionsResult
                            }
                        }
                    }
                }
            }
        }
    }

    $get_optionsResult.options = $options
    return $get_optionsResult
}
