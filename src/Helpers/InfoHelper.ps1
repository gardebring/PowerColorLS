function Get-Version{
    return $MyInvocation.MyCommand.Module.Version
}

function Show-Help{
    $v = Get-Version
    Write-Host "Help for PowerColorLS version ${v}"
    Write-Host "Usage: PowerColorLS [OPTION]... [FILE]..."
    Write-Host "List information about files and directories (the current directory by default)."
    Write-Host "Entries will be sorted alphabetically if no sorting option is specified."
    Write-Host ""
    Write-Host "`t-a, --all`t`tdo not ignore hidden files and files starting with ."
    Write-Host "`t-l, --long`t`tuse a long listing format"
    Write-Host "`t-r, --report`t`tshows a brief report"
    Write-Host "`t-1`t`t`tlist one file per line"
    Write-Host "`t-d, --dirs`t`tshow only directories"
    Write-Host "`t-f, --files`t`tshow only files"
    Write-Host "`t-ds, -sds, --sds, --show-directory-size"
    Write-Host "`t`t`t`tshow directory size (can take a long time)"
    Write-Host ""
    Write-Host "sorting options:"
    Write-Host ""
    Write-Host "`t-sd, --sort-dirs, --group-directories-first"
    Write-Host "`t`t`t`tsort directories first"
    Write-Host "`t-sf, --sort-files, --group-files-first"
    Write-Host "`t`t`t`tsort files first"
    Write-Host "`t-t, -st, --st"
    Write-Host "`t`t`t`tsort by modification time, newest first"
    Write-Host ""
    Write-Host "general options:"
    Write-Host ""
    Write-Host "`t-h, --help`t`tprints this help"
    Write-Host "`t-v, --version`t`tshow version information"
}

function Show-Version{
    $v = Get-Version
    Write-Host "PowerColorLS version ${v}"
}
