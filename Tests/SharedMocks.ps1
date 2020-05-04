function Add-MockProperty{
    param(
        $obj,
        [string]$name,
        $value
    )

    $ht = @{
        MemberType = [System.Management.Automation.PSMemberTypes]::NoteProperty
        Name = $name
        value = $value
        Force = $true   
    }

    $obj | Add-Member @ht -ErrorAction 0
}

$MockedDirectoryName = "c:\dummy"

function Get-MockedFileInfo{
    param(
        [string]$name,
        [datetime]$lastWriteTime
    )
    $obj = New-MockObject -Type System.IO.FileInfo
    Add-MockProperty -obj $obj -name "Name" -value $name
    Add-MockProperty -obj $obj -name "FullName" -value "${MockedDirectoryName}\${name}"
    Add-MockProperty -obj $obj -name "LastWriteTime" -value $lastWriteTime
    Add-MockProperty -obj $obj -name "Parent" -value @{FullName = $MockedDirectoryName}
    Add-MockProperty -obj $obj -name "DirectoryName" -value $null
    return $obj
}

function Get-MockedDirectoryInfo{
    param(
        [string]$name,
        [datetime]$lastWriteTime
    )
    $obj = New-MockObject -Type System.IO.DirectoryInfo
    Add-MockProperty -obj $obj -name "Name" -value $name
    Add-MockProperty -obj $obj -name "FullName" -value "${MockedDirectoryName}\${name}"
    Add-MockProperty -obj $obj -name "LastWriteTime" -value $lastWriteTime
    Add-MockProperty -obj $obj -name "Parent" -value @{FullName = ""}
    Add-MockProperty -obj $obj -name "DirectoryName" -value ${MockedDirectoryName}
    return $obj
}

function Get-MockedFileAndDirectoryListing{
    $a = Get-MockedDirectoryInfo    -Name "directory1"  -LastWriteTime (Get-Date -Date "2020-04-25 02:25:00Z")
    $b = Get-MockedDirectoryInfo    -Name "directory2"  -LastWriteTime (Get-Date -Date "2018-04-25 10:25:00Z")
    $c = Get-MockedFileInfo         -Name "file1.txt"   -LastWriteTime (Get-Date -Date "2020-04-25 11:25:00Z")
    $d = Get-MockedFileInfo         -Name "file2.txt"   -LastWriteTime (Get-Date -Date "2020-04-24 10:25:00Z")
    $e = Get-MockedFileInfo         -Name "file3.txt"   -LastWriteTime (Get-Date -Date "2019-04-25 10:25:00Z")
    
    $fakeListingOfFilesAndDirectories  = @($a, $b, $c, $d, $e)

    return $fakeListingOfFilesAndDirectories    
}

function Get-MockedOptions{
    param([hashtable]$adjustments)
    $options = @{
        showHiddenFiles = $false
        dirOnly = $false
        fileOnly = $false
        sortByModificationTime = $false
        filesFirst = $false
        dirsFirst = $false
        longFormat = $false
    }
    if($adjustments -ne $null){
        foreach($adjustmentKey in $adjustments.Keys){
            $options[$adjustmentKey] = $adjustments[$adjustmentKey]
        }
    }
    return $options
}

