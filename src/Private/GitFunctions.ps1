function Get-GitInfo {
    param(
        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders
    )

    $directoryName = Get-DirectoryName -filesAndFolders $filesAndFolders

    # determine if we should handle this as git directory
    $isGitDirectory = Get-ShowAsGitDirectory -directory $directoryName

    $lineCharsCounterIncrease = 0

    if($isGitDirectory){
        $gitStatusItems = Get-GitStatusItemList -directory $directoryName
        $lineCharsCounterIncrease = 2
    }

    return @{
        isGitDirectory = $isGitDirectory
        gitStatusItems = $gitStatusItems
        lineCharsCounterIncrease = $lineCharsCounterIncrease
    }
}


function Get-IsGitDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$directory
    )

    if ((Test-Path "${directory}/.git") -eq $TRUE) {
        return $TRUE
    }

    # Test within parent dirs
    $checkIn = (Get-Item ${directory}).parent
    while ($null -ne $checkIn) {
        $pathToTest = $checkIn.FullName + '/.git'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $TRUE
        } else {
            $checkIn = $checkIn.parent
        }
    }

    return $FALSE
}

function Get-ShowAsGitDirectory{
    param(
        [Parameter(Mandatory = $true)]
        [string]$directory
    )

    # check if git directory
    $isGitDirectory = Get-IsGitDirectory -directory $directory

    # check if git is installed
    $gitIsInstalled = Get-CommandExist -command "git"

    if(-not $gitIsInstalled){
        $isGitDirectory = $false
    }

    return $isGitDirectory
}

function Get-GitStatusItemList{
    param(
        [Parameter(Mandatory = $true)]
        [string]$directory
    )

    # get the current directory
    $currentPath = (Get-Location).Path

    Set-Location -Path $directory
    $gitStatus = git status --porcelain=v1
    $gitRoot = git rev-parse --show-toplevel
    Set-Location -Path $currentPath

    $gitStatusItems = @()

    foreach($gitStatusItem in $gitStatus){
        $gs = $gitStatusItem.Trim().Split(" ")
        $l = -join($gitRoot, "/", $gs[1])
        $gitStatusItems += @{
            status = $gs[0]
            path = $l
        }
    }
    return $gitStatusItems
}

function Get-GitColorAndIcon{
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$gitInfo,
        
        [Parameter(Mandatory = $true)]
        $fileSystemInfo, 
             
        [Parameter(Mandatory = $true)]
        [hashtable]$glyphs
    )

    if(-not $gitInfo.isGitDirectory){
        return ""
    }

    $gitGlyph = $glyphs["nf-fa-check"]
    $gitColor = (ConvertFrom-RGBColor -RGB ("00FF00"))
    foreach($gitStatusItem in $gitInfo.gitStatusItems){
        $updateGitStatus = $false
        $currentItemForGitCompare = $entity.FullName -Replace "\\", "/"
        if($currentItemForGitCompare -eq $gitStatusItem.path){
            $updateGitStatus = $true
        }elseif($isFolder -and ($gitStatusItem.path.StartsWith($currentItemForGitCompare,'CurrentCultureIgnoreCase'))){
            $updateGitStatus = $true
        }

        if($updateGitStatus){
            switch($gitStatusItem.status){
                "??" {
                    $gitGlyph = $glyphs["nf-fa-question"]
                    $gitColor = (ConvertFrom-RGBColor -RGB ("FF0000"))
                }
                default{
                    $gitGlyph = $gitStatusItem.status
                    $gitColor = (ConvertFrom-RGBColor -RGB ("FFFF00"))
                }
            }
        }
    }
    $gitColorAndIcon = "${gitColor}${gitGlyph} "
    return $gitColorAndIcon
}