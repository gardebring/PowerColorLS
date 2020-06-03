$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

.$ROOT/../src/Private/FileAndFolderFunctions.ps1

. $PSScriptRoot/SharedMocks.ps1

# internal help functions
function Get-MockedGetChildItem{
    param($Path)

    $file1 = New-Object -TypeName System.IO.FileInfo -ArgumentList ".dotfile"
    $directory1 = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList ".git"
    $directory2 = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList "a-dir4"
    $file2 = New-Object -TypeName System.IO.FileInfo -ArgumentList "b-file2"
    $directory3 = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList "dir2.dirext"
    $directory4 = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList "dir3.dirext"
    $file3 = New-Object -TypeName System.IO.FileInfo -ArgumentList "file3.doc"
    $file4 = New-Object -TypeName System.IO.FileInfo -ArgumentList "file4.txt"
    $file5 = New-Object -TypeName System.IO.FileInfo -ArgumentList "file5.txt"

    $fakeListingOfDirectories  = @($directory1, $directory2, $directory3, $directory4, $file1, $file2, $file3, $file4, $file5)

    if($Path -ne "."){
        $fakeListingOfDirectories = @($fakeListingOfDirectories | Where-Object Name -Like $Path)
    }

    return [array]$fakeListingOfDirectories
}

# tests

Describe "FileAndFolder Functions Tests" {
    BeforeAll {
        Mock -CommandName Get-ChildItem -MockWith { Get-MockedGetChildItem -Path $Path  }

        $countTestCases = @(
            @{
                testName = "count when not including hidden files and directories"
                options = Get-MockedOptions
                expectedLength = 7
            }
            @{
                testName = "count when including hidden files and directories"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true})
                expectedLength = 9
            }
            @{
                testName = "file count when not including hidden files"
                options = (Get-MockedOptions -adjustments @{fileOnly = $true})
                expectedLength = 4
            }
            @{
                testName = "file count when including hidden files"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true; fileOnly = $true})
                expectedLength = 5
            }
            @{
                testName = "directory count when not including hidden directories"
                options = (Get-MockedOptions -adjustments @{dirOnly = $true})
                expectedLength = 3
            }
            @{
                testName = "directory count when including hidden directories"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true; dirOnly = $true})
                expectedLength = 4
            }
            @{
                testName = "count when using query filter and not including hidden files and directories"
                options = Get-MockedOptions
                expectedLength = 2
                query = "*.txt"
            }
            @{
                testName = "count when using query filter and not including hidden files and directories"
                options = Get-MockedOptions
                expectedLength = 1
                query = "*.doc"
            }
            @{
                testName = "count when using query filter and including hidden files and directories"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true; })
                expectedLength = 1
                query = ".dotfile"
            }
            @{
                testName = "count when using query filter and including hidden files and directories"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true; })
                expectedLength = 2
                query = ".*"
            }
        )

        $orderTestCases = @(
            @{
                testName = "default sorting and not showing hidden files and directories"
                options = Get-MockedOptions
                expectedfirstFileName = "a-dir4"
            }
            @{
                testName = "default sorting and showing hidden files and directories"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true})
                expectedfirstFileName = ".dotfile"
            }
            @{
                testName = "default sorting and not showing hidden files"
                options = (Get-MockedOptions -adjustments @{fileOnly = $true})
                expectedfirstFileName = "b-file2"
            }
            @{
                testName = "default sorting and not showing hidden files"
                options = (Get-MockedOptions -adjustments @{filesFirst = $true})
                expectedfirstFileName = "b-file2"
            }
            @{
                testName = "default sorting and showing hidden files"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true; fileOnly = $true})
                expectedfirstFileName = ".dotfile"
            }
            @{
                testName = "default sorting and not showing hidden directories"
                options = (Get-MockedOptions -adjustments @{dirOnly = $true})
                expectedfirstFileName = "a-dir4"
            }
            @{
                testName = "default sorting and not showing hidden directories"
                options = (Get-MockedOptions -adjustments @{dirsFirst = $true})
                expectedfirstFileName = "a-dir4"
            }
            @{
                testName = "default sorting and showing hidden directories"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true; dirOnly = $true})
                expectedfirstFileName = ".git"
            }
            @{
                testName = "default sorting and query filter and not showing hidden directories"
                options = Get-MockedOptions
                expectedfirstFileName = "file4.txt"
                query = "*.txt"
            }
            @{
                testName = "default sorting and query filter and showing hidden directories"
                options = (Get-MockedOptions -adjustments @{showHiddenFiles = $true;})
                expectedfirstFileName = ".dotfile"
                query = ".*"
            }
        )
    }

    Context "When Getting Friendly Size" {
        It "Should return 1 KB for 1024 bytes" {
            $friendlySize = Get-FriendlySize -bytes 1024
            $friendlySize | Should be "1 KB"
        }

        It "Should return 123 B for 123 bytes" {
            $friendlySize = Get-FriendlySize -bytes 123
            $friendlySize | Should be "123 B"
        }
    }

    Context "When Listing Files" {
        It "Should return expected <testname>" -TestCases $countTestCases {
            param($options, $expectedLength, $query = ".")
            [array]$filesListing = (Get-FilesAndFoldersListing -options $options -query $query)
            $filesListing.Length  | Should Be $expectedLength
        }

        It "Should return expected sort order when using <testname>" -TestCases $orderTestCases {
            param($options, $expectedfirstFileName, $query = ".")
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $filesListing[0].Name  | Should Be $expectedfirstFileName
        }
    }
}

Describe "FileAndFolder Functions Tests" {
    
    BeforeAll {
        Mock -CommandName Get-ChildItem -MockWith { 
            return Get-MockedFileAndDirectoryListing
        }
    }

    Context "When Getting directory name" {
        It "Should return directory name for file" {
            $options = Get-MockedOptions -adjustments @{fileOnly = $true;}
            $query = "."
            [array]$filesAndFolders = (Get-FilesAndFoldersListing -options $options -query $query)
            $directoryName = Get-DirectoryName -filesAndFolders $filesAndFolders
            $directoryName | Should be $MockedDirectoryName
        }

        It "Should return directory name for directory" {
            $options = Get-MockedOptions -adjustments @{dirOnly = $true;}
            $query = "."
            [array]$filesAndFolders = (Get-FilesAndFoldersListing -options $options -query $query)
            $directoryName = Get-DirectoryName -filesAndFolders $filesAndFolders
            $directoryName | Should be $MockedDirectoryName
        }
    }
    

    Context "When Listing Files" {
        It "Should return expected sort order when sorting by last modified datetime"{
            $options = Get-MockedOptions -adjustments @{sortByModificationTime = $true}
            $query = "."
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $filesListing[0].Name  | Should Be "file1.txt"
            $filesListing[1].Name  | Should Be "directory1"
            $filesListing[2].Name  | Should Be "file2.txt"
            $filesListing[3].Name  | Should Be "file3.txt"
            $filesListing[4].Name  | Should Be "directory2"
        }

        It "Should return expected sort order when using default sorting"{
            $options = Get-MockedOptions
            $query = "."
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $filesListing[0].Name  | Should Be "directory1"
            $filesListing[1].Name  | Should Be "directory2"
            $filesListing[2].Name  | Should Be "file1.txt"
            $filesListing[3].Name  | Should Be "file2.txt"
            $filesListing[4].Name  | Should Be "file3.txt"
        }

        It "Should return expected sort order when sorting files first"{
            $options = Get-MockedOptions -adjustments @{filesFirst = $true}
            $query = "."
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $filesListing[0].Name  | Should Be "file1.txt"
            $filesListing[1].Name  | Should Be "file2.txt"
            $filesListing[2].Name  | Should Be "file3.txt"
            $filesListing[3].Name  | Should Be "directory1"
            $filesListing[4].Name  | Should Be "directory2"
        }

        It "Should return expected sort order when sorting directories first"{
            $options = Get-MockedOptions -adjustments @{dirsFirst = $true}
            $query = "."
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $filesListing[0].Name  | Should Be "directory1"
            $filesListing[1].Name  | Should Be "directory2"
            $filesListing[2].Name  | Should Be "file1.txt"
            $filesListing[3].Name  | Should Be "file2.txt"
            $filesListing[4].Name  | Should Be "file3.txt"
        }
    }
}

Describe "Get-LongestItemLength Functions Tests" {
    Context "When getting longest item" {
        It "Should return the expected longest item for file"{
            Mock -CommandName Get-ChildItem -MockWith { Get-MockedGetChildItem -Path $Path  }
            $options = Get-MockedOptions @{fileOnly = $true}
            $query = "."
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $li = Get-LongestItemLength -filesAndFolders $filesListing
            $li | Should Be 9
        }
        It "Should return the expected longest item for directory"{
            Mock -CommandName Get-ChildItem -MockWith { Get-MockedGetChildItem -Path $Path  }
            $options = Get-MockedOptions @{dirOnly = $true}
            $query = "."
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $li = Get-LongestItemLength -filesAndFolders $filesListing
            $li | Should Be 11
        }
    }
}

Describe "Get-NameForDisplay Functions Tests" {
    BeforeAll {
        Mock -CommandName Get-ChildItem -MockWith { Get-MockedGetChildItem -Path $Path  }
    }
    Context "When getting name for display" {
        It "Should return the expected name for file"{
            $options = Get-MockedOptions
            $query = "."
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $nameForDisplay = Get-NameForDisplay -fileSystemInfo $filesListing[1]
            $nameForDisplay | Should Be "b-file2"
        }

        It "Should return the expected name for directory"{
            $options = Get-MockedOptions
            $query = "."
            [array]$filesListing = Get-FilesAndFoldersListing -options $options -query $query
            $nameForDisplay = Get-NameForDisplay -fileSystemInfo $filesListing[0]
            $nameForDisplay | Should Be "a-dir4\"
        }
    }
}

Describe "Get-FileExtension Functions Tests" {
    Context "When getting file extension for file" {
        It "Should return the expected extension when filename has extension"{
            $ext = Get-FileExtension -fileName "file1.txt"
            $ext | Should be ".txt"
        }

        It "Should return no extension when filename has no extension"{
            $ext = Get-FileExtension -fileName "file1"
            $ext | Should be ""
        }
    }
}

Describe "Get-IsDirectory Functions Tests" {
    Context "When running Get-IsDirectory" {
        It "Should return true for a directory"{
            $dir = Get-MockedDirectoryInfo -Name "directory"
            $isDir = Get-IsDirectory -fileSystemInfo $dir
            $isDir | Should be $true
        }

        It "Should return false for a file"{
            $file = Get-MockedFileInfo -file "file1.txt"
            $isDir = Get-IsDirectory -fileSystemInfo $file
            $isDir | Should be $false
        }
    }
}