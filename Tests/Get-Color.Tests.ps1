$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

.$ROOT/../src/Private/Get-Color.ps1
.$ROOT/../src/Private/FileAndFolderFunctions.ps1

. $PSScriptRoot/SharedMocks.ps1

function Get-MockedColorTheme{
    return @{
        Types = @{
            Directories = @{
                WellKnown = @{
                    '.git' = 'FF4500'
                }
            }
            Files = @{
                WellKnown = @{
                    '.gitignore' = 'FF4500'
                    'LICENSE.md' = 'CD5C5C'
                }
                '.zip' = 'DAA520'
                '.xml' = '98FB98'
            }
        }
    }
    
}


Describe "Get-Color Functions Tests" {
    BeforeAll {
    }
    Context "When getting color" {
        It "Should return expected color for well known directory"{
            $dir = Get-MockedDirectoryInfo -name ".git"
            $colorTheme = Get-MockedColorTheme
            $expectedColor = ConvertFrom-RGBColor -RGB ("FF4500")
            $color = Get-Color -fileSystemInfo $dir -colorTheme $colorTheme
            $color | Should be $expectedColor
        }

        It "Should return expected color for not well known directory"{
            $dir = Get-MockedDirectoryInfo -name "directoryname"
            $colorTheme = Get-MockedColorTheme
            $expectedColor = ConvertFrom-RGBColor -RGB ("EEEE8B")
            $color = Get-Color -fileSystemInfo $dir -colorTheme $colorTheme
            $color | Should be $expectedColor
        }

        It "Should return expected color for well known file"{
            $dir = Get-MockedFileInfo -name ".gitignore"
            $colorTheme = Get-MockedColorTheme
            $expectedColor = ConvertFrom-RGBColor -RGB ("FF4500")
            $color = Get-Color -fileSystemInfo $dir -colorTheme $colorTheme
            $color | Should be $expectedColor
        }

        It "Should return expected color for known file extension"{
            $dir = Get-MockedFileInfo -name "test.zip"
            $colorTheme = Get-MockedColorTheme
            $expectedColor = ConvertFrom-RGBColor -RGB ("DAA520")
            $color = Get-Color -fileSystemInfo $dir -colorTheme $colorTheme
            $color | Should be $expectedColor
        }

        It "Should return expected color for not known file extension"{
            $dir = Get-MockedFileInfo -name "test.unknown"
            $colorTheme = Get-MockedColorTheme
            $expectedColor = ConvertFrom-RGBColor -RGB ("EEEEEE")
            $color = Get-Color -fileSystemInfo $dir -colorTheme $colorTheme
            $color | Should be $expectedColor
        }
    }
}
