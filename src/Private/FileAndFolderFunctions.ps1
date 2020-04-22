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

#function Get-IsFolder {
#    Param(
#        [Parameter(Mandatory = $true)]
#        [string]$fullName
#    )
#    return Test-Path -path ($fullName) -pathtype container
#}

function Get-IsDirectory{
    Param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$fileSystemInfo
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

function Get-FilesAndFoldersListing{
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$options, 
        
        [Parameter(Mandatory = $true)]
        [string]$query
    )
    if($options.showHiddenFiles){
        return Get-ChildItem $query -force
    }else{
        return Get-ChildItem $query
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

function Get-SortedFilesAndFoldersListing{
    param(
        [Parameter(Mandatory = $true)]
        [array]$filesAndFolders, 

        [Parameter(Mandatory = $true)]
        [hashtable]$options
    )
    if($options.sortByModificationTime){
        return $filesAndFolders  | Sort-Object Lastwritetime -descending
    }elseif($options.filesFirst){
        return $filesAndFolders | Sort-Object Attributes -descending
    }elseif($options.dirsFirst){
        return $filesAndFolders
    }else{
        return $filesAndFolders  | Sort-Object Name
    }
}