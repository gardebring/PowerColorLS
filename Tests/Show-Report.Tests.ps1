$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

.$ROOT\..\src\Private\Show-Report.ps1
.$ROOT\..\src\Private\FileAndFolderFunctions.ps1
.$ROOT\..\src\Private\Get-Color.ps1

. $PSScriptRoot/SharedMocks.ps1

Describe "Show-Report Tests" {
    BeforeAll {
        Mock -CommandName Get-ChildItem -MockWith { 
            return Get-MockedFileAndDirectoryListing
        }

        Mock -CommandName Write-Host -MockWith { 
        }

        
    }

    $directoryCount = 2
    $fileCount = 3                
    $query = "."

    Context "When showing short format report" {
        It "Should write out expexted report" {
            $options = Get-MockedOptions
            [array]$filesAndFolders = (Get-FilesAndFoldersListing -options $options -query $query)
            $report = Show-Report -options $options -filesAndFolders $filesAndFolders -query $query
            Assert-MockCalled Write-Host -Exactly 2 -Scope It
            Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -like "*Found 5 files and folders matching*" }
            Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -like "*Folders:    $directoryCount*" }
            Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -like "*Files:      $fileCount*" }
        }
    }

    Context "When showing long format report" {
        It "Should write out expexted report" {

            $options = Get-MockedOptions -adjustments @{longFormat = $true;}

            [array]$filesAndFolders = (Get-FilesAndFoldersListing -options $options -query $query)
            $report = Show-Report -options $options -filesAndFolders $filesAndFolders -query $query
            Assert-MockCalled Write-Host -Exactly 1 -Scope It
            Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -like "*Found 5 files and folders matching*" }
            Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -like "*Folders:    $directoryCount*" }
            Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -like "*Files:      $fileCount*" }
        }
    }
}
