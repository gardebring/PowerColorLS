$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "Importing" {
    Context "When module is being imported" {
        It "Should not have any warnings" {
            $warn = $false
            $out = (powershell -noprofile "Import-Module $ROOT\..\PowerColorLS.psm1")
            $out | % { $warn = $warn -or ($_ -Match "WARNING") }
            $warn | Should be $false
        }
    }
}