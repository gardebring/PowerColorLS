Import-Module PSScriptAnalyzer
$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

function Show-ScriptAnalyzerErrors{
    Param($analyzerResults)
    if($null -ne $analyzerResults){
        foreach($r in $analyzerResults){
            $errMsg = -join($r.RuleName, " error on line ", $r.Line, ". ", $r.Message)
            Write-Warning $errMsg
        }
        
    }
}

Describe "Analyzing script" {
    Context "When script analyzer analyzes the module" {
        It "should have no issues" {
            $analyzerResults = Invoke-ScriptAnalyzer -Path "$ROOT\..\src\PowerColorLS.psm1" -ExcludeRule PSAvoidUsingWriteHost
            Show-ScriptAnalyzerErrors $analyzerResults
			$analyzerResults | Should be $null
        }
    }
    Context "When script analyzer analyzes the module manifest" {
        It "should have no issues" {
            $analyzerResults = Invoke-ScriptAnalyzer -Path "$ROOT\..\src\PowerColorLS.psd1"
            Show-ScriptAnalyzerErrors $analyzerResults
			$analyzerResults | Should be $null
        }
    }
}