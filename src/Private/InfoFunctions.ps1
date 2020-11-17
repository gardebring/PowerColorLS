function Get-Version{
    return $MyInvocation.MyCommand.Module.Version
}

function Show-Help{
    $v = Get-Version

    $help = "
Help for PowerColorLS version ${v}
Usage: PowerColorLS [OPTION]... [FILE]...
List information about files and directories (the current directory by default).
Entries will be sorted alphabetically if no sorting option is specified.

        -a, --all           do not ignore hidden files and files starting with .
        -l, --long          use a long listing format
        -r, --report        shows a brief report
        -1                  list one file per line
        -d, --dirs          show only directories
        -f, --files         show only files
        -ds, -sds, --sds, --show-directory-size
                            show directory size (can take a long time)
        -hi, --hide-icons   hide icons

sorting options:

        -sd, --sort-dirs, --group-directories-first
                            sort directories first
        -sf, --sort-files, --group-files-first
                            sort files first
        -t, -st, --st
                            sort by modification time, newest first
    
 general options:
    
        -h, --help          prints this help
        -v, --version       show version information
    "
    Write-Host $help
}

function Show-Version{
    $v = Get-Version
    Write-Host "PowerColorLS version ${v}"
}
