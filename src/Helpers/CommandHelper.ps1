function Get-CommandExist{
    param (
        [Parameter(Mandatory = $true)]
        [string]$command
    )
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "stop"
    Try {if(Get-Command $command){return $true}}
    Catch {return $false}
    Finally {$ErrorActionPreference=$oldPreference}
}