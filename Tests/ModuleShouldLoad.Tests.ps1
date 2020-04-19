$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "Importing" {
    Context "When module is being imported" {
        It "Should not have any warnings" {
            $warn = $false
            $out = (pwsh -noprofile "Import-Module $ROOT\..\src\PowerColorLS.psm1")
            $out | % { $warn = $warn -or ($_ -Match "WARNING") }
            if($true -eq $warn){
                Write-Host -Message $out
            }
            $warn | Should be $false
        }
    }

    Context "When module definition is being imported" {
        It "Should not have any warnings" {
            $warn = $false
            $out = (pwsh -noprofile "Import-Module $ROOT\..\src\PowerColorLS.psd1")
            $out | % { $warn = $warn -or ($_ -Match "WARNING") }
            $warn | Should be $false
        }
    }
}