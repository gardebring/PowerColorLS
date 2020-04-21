$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

.$ROOT\..\src\Helpers\FileAndFolderHelper.ps1
.$ROOT\..\src\Helpers\OptionsHelper.ps1

foreach($x in $a){
    Write-Host $x.Fullname
}

Describe "FileAndFolder Helper Tests" {
    Context "When Getting Friendly Size" {
        It "Should return expected size" {
            $friendlySize = Get-FriendlySize -bytes 1024
            $friendlySize | Should be "1 KB"
        }
    }

    Context "When Listing Files" {
        It "Should return expected files" {
            $optionsResults = Get-OptionsResult
            $arr = @{ Name = "README.MD" }
            Mock -CommandName Get-ChildItem -MockWith { [PSCustomObject]$arr  }
            $filesListing = Get-FilesAndFoldersListing -options $optionsResults -query "*.md"
            $filesListing  | Should Be $arr
        }
    }
}