function Get-FriendlySize {
    param($bytes)
    $sizes='B,KB,MB,GB,TB,PB,EB,ZB' -split ','
    for($i=0; ($bytes -ge 1kb) -and
        ($i -lt $sizes.Count); $i++) {$bytes/=1kb}
    $N=0; if($i -eq 0) {$N=0}
    "{0:N$($N)} {1}" -f $bytes, $sizes[$i]
}

function Get-FilesAndFoldersListing{
    Param($options, $query)
    if($options.showHiddenFiles){
        return Get-ChildItem $query -force
    }else{
        return Get-ChildItem $query
    }
}

function Get-DirectoryName{
    Param($filesAndFolders)

    $f = $filesAndFolders[0]

    $directoryName = $f.Parent.FullName
    if($directoryName.Length -eq 0){
        $directoryName = $f.DirectoryName
    }
    return $directoryName
}

function Get-SortedFilesAndFoldersListing{
    Param($filesAndFolders, $options)
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