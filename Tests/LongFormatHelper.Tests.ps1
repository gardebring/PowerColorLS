$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

.$ROOT\..\src\Private\LongFormatHelper.ps1
.$ROOT\..\src\Private\FileAndFolderFunctions.ps1
.$ROOT\..\src\Private\Get-LongestItem.ps1
.$ROOT\..\src\Private\GitFunctions.ps1
.$ROOT\..\src\Private\Get-CommandExist.ps1
.$ROOT\..\src\Private\Get-Color.ps1

. $PSScriptRoot/SharedMocks.ps1

function Get-LongFormatTestData{
    param([int]$availableCharWith)
    $options = Get-MockedOptions -adjustments @{longFormat = $true;}
    $query = "."
    [array]$filesAndFolders = (Get-FilesAndFoldersListing -options $options -query $query)
    $longestItemLength = Get-LongestItemLength -filesAndFolders $filesAndFolders
    $longFormatData = Get-LongFormatData -options $options -filesAndFolders $filesAndFolders -longestItemLength $longestItemLength
    $colorAndIcon = " "
    $expectedMode = Get-ModeForLongListing -modeInput $filesAndFolders[0].Mode

    $lfp0 = Get-LongFormatPrintout -fileSystemInfo $filesAndFolders[0] -options $options -longFormatData $longFormatData -colorAndIcon $colorAndIcon -availableCharWith $availableCharWith
    $lfp2 = Get-LongFormatPrintout -fileSystemInfo $filesAndFolders[2] -options $options -longFormatData $longFormatData -colorAndIcon $colorAndIcon -availableCharWith $availableCharWith
    
    return @{
        lfp0 = $lfp0
        lfp2 = $lfp2
        mode0Ok = ($lfp0.Contains($expectedMode))
        mode2Ok = ($lfp2.Contains($expectedMode))
        dt0 = ($filesAndFolders[0].LastWriteTime).ToString("f")
        dt2 = ($filesAndFolders[2].LastWriteTime).ToString("f")
    }
}

Describe "LongFormatHelper Functions Tests" {
    
    BeforeAll {
        Mock -CommandName Get-ChildItem -MockWith { 
            return Get-MockedFileAndDirectoryListing
        }

        Mock -CommandName Get-Acl -MockWith {
            return Get-MockedAclFromPipeline
        }

        Mock -CommandName Get-Item -MockWith {
            return Get-MockedItem
        }

        Mock -CommandName Get-CommandExist -MockWith {
            return $true
        }

        Mock -CommandName Write-Host -MockWith {
        }
    }

    Context "When getting mode for long listing"{
        It "Should return expected mode for mode d----" {
            $mode = "d----"
            $modeForLongListing = Get-ModeForLongListing -modeInput $mode
            $color = Get-Mode-Attribute-Color -attribute "d"
            $dashcolor = Get-Mode-Attribute-Color -attribute "-"
            $modeForLongListing | Should be ("${color}glyph-nf-fa-folder_o ${dashcolor}- ${dashcolor}- ${dashcolor}- ${dashcolor}- ")
        }
        It "Should return expected mode for mode d--h-" {
            $mode = "d--h-"
            $modeForLongListing = Get-ModeForLongListing -modeInput $mode
            $colord = Get-Mode-Attribute-Color -attribute "d"
            $colorh = Get-Mode-Attribute-Color -attribute "h"
            $dashcolor = Get-Mode-Attribute-Color -attribute "-"
            $modeForLongListing | Should be ("${colord}glyph-nf-fa-folder_o ${dashcolor}- ${dashcolor}- ${colorh}glyph-nf-mdi-file_hidden ${dashcolor}- ")
        }

        It "Should return expected mode for mode -a---" {
            $mode = "-a---"
            $modeForLongListing = Get-ModeForLongListing -modeInput $mode
            $colora = Get-Mode-Attribute-Color -attribute "a"
            $dashcolor = Get-Mode-Attribute-Color -attribute "-"
            $modeForLongListing | Should be ("${dashcolor}- ${colora}glyph-nf-fa-archive ${dashcolor}- ${dashcolor}- ${dashcolor}- ")
        }

        It "Should return expected mode for mode d-r-s" {
            $mode = "d-r-s"
            $modeForLongListing = Get-ModeForLongListing -modeInput $mode
            $colord = Get-Mode-Attribute-Color -attribute "d"
            $colorr = Get-Mode-Attribute-Color -attribute "r"
            $colors = Get-Mode-Attribute-Color -attribute "s"
            $dashcolor = Get-Mode-Attribute-Color -attribute "-"
            $modeForLongListing | Should be ("${colord}glyph-nf-fa-folder_o ${dashcolor}- ${colorr}glyph-nf-fa-lock ${dashcolor}- ${colors}glyph-nf-fa-gear ")
        }

        It "Should return expected mode for mode la---" {
            $mode = "la---"
            $modeForLongListing = Get-ModeForLongListing -modeInput $mode
            $colora = Get-Mode-Attribute-Color -attribute "a"
            $dashcolor = Get-Mode-Attribute-Color -attribute "-"
            $modeForLongListing | Should be ("${dashcolor}l ${colora}glyph-nf-fa-archive ${dashcolor}- ${dashcolor}- ${dashcolor}- ")
        }
    }

    <#
    
la---
    #>

    Context "When getting long format data" {
        It "Should return null when not in long format" {
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
            $longFormatData.longestOwnerAclLength | Should be 10
            $longFormatData.longestGroupAclLength | Should be 10
            $longFormatData.longestDateLength | Should be 31
            $longFormatData.fullItemMaxLength | Should be 95
            $longFormatData.noGroupMaxLength | Should be 83
            $longFormatData.noGroupOrOwnerMaxLength | Should be 71
            $longFormatData.noGroupOrOwnerOrModeMaxLength | Should be 58
        }
    }

    Context "When Getting long format printout"{
        It "Should return expected printout when at max length"{
            $lftd = Get-LongFormatTestData -availableCharWith 300
            $dt0 = $lftd.dt0
            $dt2 = $lftd.dt2

            $lftd.mode0Ok | Should -Be $true
            $lftd.lfp0 | Should -BeLike "*OWNER\user*"
            $lftd.lfp0 | Should -BeLike "*GROUP\user*"
            $lftd.lfp0 | Should -BeLike "*${dt0}*"
            $lftd.lfp0 | Should -BeLike "*directory1\*"

            $lftd.mode2Ok | Should -Be $true
            $lftd.lfp2 | Should -BeLike "*OWNER\user*"
            $lftd.lfp2 | Should -BeLike "*GROUP\user*"
            $lftd.lfp2 | Should -BeLike "*${dt2}*"
            $lftd.lfp2 | Should -BeLike "*file1.txt*"
        }

        It "Should return expected printout when at 90 length"{
            $lftd = Get-LongFormatTestData -availableCharWith 90
            $dt0 = $lftd.dt0
            $dt2 = $lftd.dt2

            $lftd.mode0Ok | Should -Be $true
            $lftd.lfp0 | Should -BeLike "*OWNER\user*"
            $lftd.lfp0 | Should -Not -BeLike "*GROUP\user*"
            $lftd.lfp0 | Should -BeLike "*${dt0}*"
            $lftd.lfp0 | Should -BeLike "*directory1\*"

            $lftd.mode2Ok | Should -Be $true
            $lftd.lfp2 | Should -BeLike "*OWNER\user*"
            $lftd.lfp2 | Should -Not -BeLike "*GROUP\user*"
            $lftd.lfp2 | Should -BeLike "*${dt2}*"
            $lftd.lfp2 | Should -BeLike "*file1.txt*"
        }

        It "Should return expected printout when at 80 length"{
            $lftd = Get-LongFormatTestData -availableCharWith 80
            $dt0 = $lftd.dt0
            $dt2 = $lftd.dt2

            $lftd.mode0Ok | Should -Be $true
            $lftd.lfp0 | Should -Not -BeLike "*OWNER\user*"
            $lftd.lfp0 | Should -Not -BeLike "*GROUP\user*"
            $lftd.lfp0 | Should -BeLike "*${dt0}*"
            $lftd.lfp0 | Should -BeLike "*directory1\*"

            $lftd.mode2Ok | Should -Be $true
            $lftd.lfp2 | Should -Not -BeLike "*OWNER\user*"
            $lftd.lfp2 | Should -Not -BeLike "*GROUP\user*"
            $lftd.lfp2 | Should -BeLike "*${dt2}*"
            $lftd.lfp2 | Should -BeLike "*file1.txt*"
        }

        It "Should return expected printout when at 70 length"{
            $lftd = Get-LongFormatTestData -availableCharWith 70
            $dt0 = $lftd.dt0
            $dt2 = $lftd.dt2

            $lftd.mode0Ok | Should -Be $false
            $lftd.lfp0 | Should -Not -BeLike "*OWNER\user*"
            $lftd.lfp0 | Should -Not -BeLike "*GROUP\user*"
            $lftd.lfp0 | Should -BeLike "*${dt0}*"
            $lftd.lfp0 | Should -BeLike "*directory1\*"

            $lftd.mode2Ok | Should -Be $false
            $lftd.lfp2 | Should -Not -BeLike "*OWNER\user*"
            $lftd.lfp2 | Should -Not -BeLike "*GROUP\user*"
            $lftd.lfp2 | Should -BeLike "*${dt2}*"
            $lftd.lfp2 | Should -BeLike "*file1.txt*"
        }

        It "Should return expected printout when at 50 length"{
            $lftd = Get-LongFormatTestData -availableCharWith 50
            $dt0 = $lftd.dt0
            $dt2 = $lftd.dt2

             $lftd.mode0Ok | Should -Be $false
            $lftd.lfp0 | Should -Not -BeLike "*OWNER\user*"
            $lftd.lfp0 | Should -Not -BeLike "*GROUP\user*"
            $lftd.lfp0 | Should -Not -BeLike "*${dt0}*"
            $lftd.lfp0 | Should -BeLike "*directory1\*"

            $lftd.mode2Ok | Should -Be $false
            $lftd.lfp2 | Should -Not -BeLike "*OWNER\user*"
            $lftd.lfp2 | Should -Not -BeLike "*GROUP\user*"
            $lftd.lfp2 | Should -Not -BeLike "*${dt2}*"
            $lftd.lfp2 | Should -BeLike "*file1.txt*"
        }
    }
}

