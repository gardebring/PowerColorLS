Import-Module Pester
Set-StrictMode -Version Latest

$Results = Invoke-Pester -PassThru -CodeCoverage "src/Private/*.ps1" .\Tests 
