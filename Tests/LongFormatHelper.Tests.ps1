$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

.$ROOT\..\src\Private\LongFormatHelper.ps1
.$ROOT\..\src\Private\FileAndFolderFunctions.ps1

. $PSScriptRoot/SharedMocks.ps1

Describe "FileAndFolder Functions Tests" {
    
    BeforeAll {
        Mock -CommandName Get-ChildItem -MockWith { 
            return Get-MockedFileAndDirectoryListing
        }

        Mock -CommandName Get-Acl -MockWith {
            return Get-MockedAcl -Path $Path
        }
    }

    Context "When Getting long format data" {
        It "Should return null when not in long format" {
            #$options = Get-MockedOptions -adjustments @{fileOnly = $true;}
            $options = Get-MockedOptions 
            $query = "."
            [array]$filesAndFolders = (Get-FilesAndFoldersListing -options $options -query $query)
            $longestItemLength = Get-LongestItemLength -filesAndFolders $filesAndFolders
            $longFormatData = Get-LongFormatData -options $options -filesAndFolders $filesAndFolders -longestItemLength $longestItemLength
            $longFormatData | Should be $null
        }

        It "Should return expected values when in long format" {
            $options = Get-MockedOptions -adjustments @{longFormat = $true;}
            $query = "."
            [array]$filesAndFolders = (Get-FilesAndFoldersListing -options $options -query $query)
            $longestItemLength = Get-LongestItemLength -filesAndFolders $filesAndFolders
            $longFormatData = Get-LongFormatData -options $options -filesAndFolders $filesAndFolders -longestItemLength $longestItemLength
            $longFormatData.longestOwnerAclLength | Should be 0
        }
    }
}