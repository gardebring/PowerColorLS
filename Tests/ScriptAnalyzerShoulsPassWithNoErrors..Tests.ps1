$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "Analyzing script" {
    Context "When script analyzer analyzes the module" {
        It "should have no issues" {
            $out = (powershell -noprofile "Invoke-ScriptAnalyzer $ROOT\..\src\PowerColorLS.psm1 -ExcludeRule PSAvoidUsingWriteHost")
			$out | Should be $null
        }
    }
    Context "When script analyzer analyzes the module manifest" {
        It "should have no issues" {
            $out = (powershell -noprofile "Invoke-ScriptAnalyzer $ROOT\..\src\PowerColorLS.psd1")
			$out | Should be $null
        }
    }
}