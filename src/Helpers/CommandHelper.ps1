function Get-CommandExist{
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "stop"
    Try {if(Get-Command $command){return $true}}
    Catch {return $false}
    Finally {$ErrorActionPreference=$oldPreference}
}