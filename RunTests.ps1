Import-Module Pester
Set-StrictMode -Version Latest

$Results = Invoke-Pester -PassThru .\Tests
