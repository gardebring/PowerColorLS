function Get-FriendlySize {
    param(
        [Parameter(Mandatory = $true)]
        [long]$bytes
    )
    $sizes='B,KB,MB,GB,TB,PB,EB,ZB' -split ','
    for($i=0; ($bytes -ge 1kb) -and
        ($i -lt $sizes.Count); $i++) {$bytes/=1kb}
    $N=0; if($i -eq 0) {$N=0}
    "{0:N$($N)} {1}" -f $bytes, $sizes[$i]
}

function Get-IsDirectory{
    Param(
        [Parameter(Mandatory = $true)]
        $fileSystemInfo
    )
    return ($fileSystemInfo.GetType()) -eq [System.IO.DirectoryInfo]
}

function Get-FileExtension {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$fileName
    )
    return [System.IO.Path]::GetExtension($fileName)
}

function Get-FilesAndFoldersListing{
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$options, 
        
        [Parameter(Mandatory = $true)]
        [string]$query
    )
    if($options.showHiddenFiles){
        $filesAndFolders = Get-ChildItem -Path $query -force
    }else{
        $filesAndFolders = Get-ChildItem -Path $query
    }

    # Remove items that should not be displayed:
    $nl = @()
    foreach($fileOrFolder in $filesAndFolders){
        $ignoreItem = Get-IgnoreItem -options $options -fileSystemInfo $fileOrFolder
        if(-not $ignoreItem){
            $nl += $fileOrFolder
        }
    }

    if($nl.Length -eq 0){ # nothing left
        return
    }

    # Sort the list
    $filesAndFolders = Get-SortedFilesAndFoldersListing -filesAndFolders $nl -options $options

    return [array]$filesAndFolders
}

function Get-NameForDisplay{
    param(
        [Parameter(Mandatory = $true)]
        $fileSystemInfo
    )

    $isDirectory = Get-IsDirectory -fileSystemInfo $fileSystemInfo
    $name = $fileSystemInfo.Name

    if($isDirectory){
        if($IsWindows -eq $True){
            return "${name}\"
        }else{
            return "/${name}"
        }
    }else{
        return $name
    }
}

function Get-DirectoryName{
    param(
        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders
    )

    $f = $filesAndFolders[0]

    $directoryName = $f.Parent.FullName

    if($directoryName.Length -eq 0){
        $directoryName = $f.DirectoryName
    }

    # fix for strange bug that occurs intermittently where we no longer get a proper FileSystemInfo object to work with:
    if($null -eq $directoryName){
        if($filesAndFolders.Length -gt 1){
            $directoryName = [System.IO.Path]::GetDirectoryName($f.FullName)
        }
    }

    return $directoryName
}

function Get-DirectorySize{
    param(
        [Parameter(Mandatory = $true)]
        [string]$directoryName
    )
    $directorySizeInBytes = ((Get-Childitem $directoryName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Sum Length -ErrorAction SilentlyContinue | Select-Object sum).sum)
    return Get-FriendlySize -bytes $directorySizeInBytes
}

function Get-LongestItemLength{
    param(
        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders
    )


    #$longestItem = Get-LongestItem -items $filesAndFolders -scriptBlock {return $item.Name}
    #$longestItemLength = $longestItem.Name.Length

    # determine the longest items so we can adapt the list to the console window width
    #Sometimes it seems powershell go haywire and cannot propertly sort by length, so using his hacky approach to get the longest item instead:
    #$longestItem = $filesAndFolders | Select-Object Name, FullName | Sort-Object { "$_".Length } -descending | Select-Object -first 1
    $longestItemLength = 0
    $longestItem = $null
    foreach($fileOrFolder in $filesAndFolders){
        $l = $fileOrFolder.Name.Length
        if($l -gt $longestItemLength){
            $longestItemLength = $l
            $longestItem = $fileOrFolder
        }
    }

    $longestItemIsDirectory = Test-Path -path ($longestItem.FullName) -pathtype container
    if(($longestItemIsDirectory) -and (-not $options.fileOnly)){
        $longestItemLength += 1
    }

    return $longestItemLength
}

function Get-SortedFilesAndFoldersListing{
    param(
        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders, 

        [Parameter(Mandatory = $true)]
        [hashtable]$options
    )

   
    if($filesAndFolders.Length -eq 0){ # nothing found
        return
    }

    if($options.sortByModificationTime){
        return $filesAndFolders  | Sort-Object Lastwritetime -descending
    }elseif($options.filesFirst){
        return $filesAndFolders | Sort-Object {$_.GetType()} -descending #Attributes
    }elseif($options.dirsFirst){
        return $filesAndFolders | Sort-Object {$_.GetType()}  #Attributes
    }else{
        return $filesAndFolders  | Sort-Object Name
    }
}

function Get-IgnoreItem {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$options, 
        
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$fileSystemInfo
    )

    $isDirectory = Get-IsDirectory -fileSystemInfo $fileSystemInfo

    if((-not $options.showHiddenFiles) -and ($fileSystemInfo.name.StartsWith("."))) {
        return $true
    }

    if(($options.dirOnly) -and (-not $isDirectory)) {
        return $true
    }

    if(($options.fileOnly) -and ($isDirectory)) {
        return $true
    }

    return $false
}
