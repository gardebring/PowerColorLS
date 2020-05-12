param(
    [string]$scriptFile
)

$runCoverage = $false

if("" -eq $scriptFile){
    $scriptFile = ".\Tests"
    $runCoverage = $true
}

Import-Module Pester
Set-StrictMode -Version Latest

if($runCoverage){
    $Results = Invoke-Pester -PassThru -CodeCoverage "src/Private/*.ps1" $scriptFile
}else{
    $Results = Invoke-Pester -PassThru $scriptFile
}
