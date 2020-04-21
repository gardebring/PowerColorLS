$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

.$ROOT\..\src\Helpers\CommandHelper.ps1

Describe "Command Helper Tests" {
    Context "When testing for command that does not exist" {
        It "Should return false" {
            $exists = Get-CommandExist -command "ThisDoesNotExist"
            $exists | Should be $False
        }
    }

    Context "When testing for command that exist" {
        It "Should return true" {
            $exists = Get-CommandExist -command "git"
            $exists | Should be $True
        }
    }

}