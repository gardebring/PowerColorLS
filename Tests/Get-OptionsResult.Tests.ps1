$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

.$ROOT\..\src\Private\Get-OptionsResult.ps1
.$ROOT\..\src\Private\InfoFunctions.ps1

. $PSScriptRoot/SharedMocks.ps1

Describe "Get-OptionsResult Tests" {
    BeforeAll {
        Mock -CommandName Show-Version
        Mock -CommandName Show-Help
        
        $getOptionsTestCases = @(
            @{
                testName = "default options when no option is specified"
                optionsResult = Get-OptionsResult
                expectedOptions = Get-MockedOptions
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "oneEntryPerLine option when -1 flag is specified"
                optionsResult = Get-OptionsResult -arguments "-1"
                expectedOptions = Get-MockedOptions -adjustments @{oneEntryPerLine = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "showHiddenFiles option when -a flag is specified"
                optionsResult = Get-OptionsResult -arguments "-a"
                expectedOptions = Get-MockedOptions -adjustments @{showHiddenFiles = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "dirOnly option when -d flag is specified"
                optionsResult = Get-OptionsResult -arguments "-d"
                expectedOptions = Get-MockedOptions -adjustments @{dirOnly = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "fileOnly option when -f flag is specified"
                optionsResult = Get-OptionsResult -arguments "-f"
                expectedOptions = Get-MockedOptions -adjustments @{fileOnly = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "longFormat option when -l flag is specified"
                optionsResult = Get-OptionsResult -arguments "-l"
                expectedOptions = Get-MockedOptions -adjustments @{longFormat = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "dirsFirst option when -sd flag is specified"
                optionsResult = Get-OptionsResult -arguments "-sd"
                expectedOptions = Get-MockedOptions -adjustments @{dirsFirst = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "filesFirst option when -sf flag is specified"
                optionsResult = Get-OptionsResult -arguments "-sf"
                expectedOptions = Get-MockedOptions -adjustments @{filesFirst = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "sortByModificationTime option when -t flag is specified"
                optionsResult = Get-OptionsResult -arguments "-t"
                expectedOptions = Get-MockedOptions -adjustments @{sortByModificationTime = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "showDirectorySize option when -sds flag is specified"
                optionsResult = Get-OptionsResult -arguments "-sds"
                expectedOptions = Get-MockedOptions -adjustments @{showDirectorySize = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "showReport option when -r flag is specified"
                optionsResult = Get-OptionsResult -arguments "-r"
                expectedOptions = Get-MockedOptions -adjustments @{showReport = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "showReport and showDirectorySize option when -r -sds flags are specified"
                optionsResult = Get-OptionsResult -arguments "-r -sds".Split(" ")
                expectedOptions = Get-MockedOptions -adjustments @{showReport = $true;showDirectorySize = $true;}
                continue = $true
                errorMessage = $null
                query = "."
            }
            @{
                testName = "default options with expected query when no option and query is specified"
                optionsResult = Get-OptionsResult "*.txt"
                expectedOptions = Get-MockedOptions
                continue = $true
                errorMessage = $null
                query = "*.txt"
            }
            @{
                testName = "longFormat option and expected query when --long option and query is specified"
                optionsResult = Get-OptionsResult "--long *.md".Split(" ")
                expectedOptions = Get-MockedOptions -adjustments @{longFormat = $true;}
                continue = $true
                errorMessage = $null
                query = "*.md"
            }

        )
    }
    Context "When getting options"{
        It "Should return <testname>" -TestCases $getOptionsTestCases {
            param($optionsResult, $expectedOptions, $continue, $errorMessage, $query)
            $options = $optionsResult.options
            $optionsResult.continue | Should be $continue
            $optionsResult.errorMessage | Should be $errorMessage
            $optionsResult.query | Should be $query

            $options.oneEntryPerLine | Should be $expectedOptions.oneEntryPerLine
            $options.showHiddenFiles | Should be $expectedOptions.showHiddenFiles
            $options.dirOnly | Should be $expectedOptions.dirOnly
            $options.fileOnly | Should be $expectedOptions.fileOnly
            $options.longFormat | Should be $expectedOptions.longFormat
            $options.dirsFirst | Should be $expectedOptions.dirsFirst
            $options.filesFirst | Should be $expectedOptions.filesFirst
            $options.sortByModificationTime | Should be $expectedOptions.sortByModificationTime
            $options.showDirectorySize | Should be $expectedOptions.showDirectorySize
            $options.showReport | Should be $expectedOptions.showReport
        }

        It "Should show version when -v flag is specified" {
            $optionsResult = (Get-OptionsResult -arguments "-v")
            $optionsResult.continue | Should be $false
            $optionsResult.errorMessage | Should be $null
            Assert-MockCalled Show-Version -Times 1 
        }

        It "Should show help when -h flag is specified" {
            $optionsResult = (Get-OptionsResult -arguments "-h")
            $optionsResult.continue | Should be $false
            $optionsResult.errorMessage | Should be $null
            Assert-MockCalled Show-Help -Times 1 
        }

        It "Should result in invalid option message when invalid option is passed" {
            $optionsResult = (Get-OptionsResult -arguments "-invalidoption")
            $optionsResult.continue | Should be $false
            $optionsResult.errorMessage | Should be "invalid option -invalidoption"
            Assert-MockCalled Show-Help -Times 1 
        }

    }
}