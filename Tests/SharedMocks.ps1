$glyphs =@{
     'nf-fa-folder_o' = 'glyph-nf-fa-folder_o'
    'nf-fa-archive' = 'glyph-nf-fa-archive'
    'nf-fa-lock' = 'glyph-nf-fa-lock'
    'nf-mdi-file_hidden' = 'glyph-nf-mdi-file_hidden'
    'nf-fa-gear' = 'glyph-nf-fa-gear'
}

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
    Add-MockProperty -obj $obj -name "PSPath" -value "Microsoft.PowerShell.Core\FileSystem::${MockedDirectoryName}\${name}"
    Add-MockProperty -obj $obj -name "Name" -value $name
    Add-MockProperty -obj $obj -name "FullName" -value "${MockedDirectoryName}\${name}"
    Add-MockProperty -obj $obj -name "LastWriteTime" -value $lastWriteTime
    Add-MockProperty -obj $obj -name "Parent" -value @{FullName = $MockedDirectoryName}
    Add-MockProperty -obj $obj -name "DirectoryName" -value $null
    Add-MockProperty -obj $obj -name "Extension" -value [System.IO.Path]::GetExtension($name)
    Add-MockProperty -obj $obj -name "Exists" -value $true
    Add-MockProperty -obj $obj -name "Mode" -value "-a---"
    return $obj
}

function Get-MockedDirectoryInfo{
    param(
        [string]$name,
        [datetime]$lastWriteTime
    )
    $obj = New-MockObject -Type System.IO.DirectoryInfo
    Add-MockProperty -obj $obj -name "PSPath" -value "Microsoft.PowerShell.Core\FileSystem::${MockedDirectoryName}\${name}"
    Add-MockProperty -obj $obj -name "Name" -value $name
    Add-MockProperty -obj $obj -name "FullName" -value "${MockedDirectoryName}\${name}"
    Add-MockProperty -obj $obj -name "LastWriteTime" -value $lastWriteTime
    Add-MockProperty -obj $obj -name "Parent" -value @{FullName = ""}
    Add-MockProperty -obj $obj -name "DirectoryName" -value ${MockedDirectoryName}
    Add-MockProperty -obj $obj -name "Extension" -value [System.IO.Path]::GetExtension($name)
    Add-MockProperty -obj $obj -name "Exists" -value $true
    Add-MockProperty -obj $obj -name "Mode" -value "d----"
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

function Get-MockedItem{
    param([string]$Path)
    $files = Get-MockedFileAndDirectoryListing
    $fileOrDir = $files[0]
    if(($null -ne $Path) -and ("" -ne $Path)){
        
    }
    $fileOrDir.Parent = $null
    return $fileOrDir
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
        showDirectorySize = $false
        oneEntryPerLine = $false
        showReport = $false
    }
    if($adjustments -ne $null){
        foreach($adjustmentKey in $adjustments.Keys){
            $options[$adjustmentKey] = $adjustments[$adjustmentKey]
        }
    }
    return $options
}

function Get-MockedDirectoryAcl{
    param([string]$Path)
    $obj = New-Object PSObject -Property @{
        Owner       = "OWNER\user"
        Group       = "GROUP\user"
    }
    return $obj
}

function Get-MockedFileAcl{
    param([string]$Path)
    $obj = New-Object PSObject -Property @{
        Owner       = "OWNER\user"
        Group       = "GROUP\user"
    }
    return $obj
}


function Get-MockedAclFromPipeline{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        $Name,
        [parameter(ValueFromPipelineByPropertyName)]
        $FullName,
        [parameter(ValueFromPipelineByPropertyName)]
        $DirectoryName
    )

    process {
        if($null -eq $DirectoryName){
            return Get-MockedDirectoryAcl
        }else{
            return Get-MockedFileAcl
        }
    }
}
