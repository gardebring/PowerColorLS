# PowerColorLS

A PowerShell module that displays a colorized directory and file listing with icons. Inspired by [colorls](https://github.com/athityakumar/colorls)

![Screenshot 1](./media/screens/powercolorls.png)

## Overview

*PowerColorLS* is a PowerShell module that displays a colorized directory and file listing with icons in the terminal.
For the module to work, you must first install [Terminal-Icons](https://github.com/devblackops/Terminal-Icons/) and setup the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts/)

## Installation
To install the module from the [PowerShell Gallery](https://www.powershellgallery.com/):
```powershell
Install-Module -Name PowerColorLS -Repository PSGallery
```

## Example usage
```powershell
Import-Module PowerColorLS
PowerColorLS
```

List all files and directories including hidden ones and ones starting with '.' in long listing (wide) format
```powershell
PowerColorLS -l
```
![Screenshot 2](./media/screens/powercolorls_a_l.png)
List all files and directories including hidden ones and ones starting with '.' in long listing (wide) format and also include directory size
```powershell
PowerColorLS -l
```
![Screenshot 3](./media/screens/powercolorls_a_l_show_directory_size.png)
List files only, followed by list directories only
```powershell
PowerColorLS -l
```
![Screenshot 4](./media/screens/powercolorls_f_d.png)

## Help
To get help about available arguments, run:
```powershell
PowerColorLS --help
```

Output of help command:
```
Usage: PowerColorLs [OPTION]... [FILE]...
List information about files and directories (the current directory by default).
Entries will be sorted alphabetically if no sorting option is specified.

        -a, --all               do not ignore hidden files and files starting with .
        -l, --long              use a long listing format
        -1                      list one file per line
        -d, --dirs              show only directories
        -f, --files             show only files
        -ds, --ds, -sds, --sds, --show-directory-size
                                show directory size (can take a long time)

sorting options:

        -sd, --sd, --sort-dirs, --group-directories-first
                                sort directories first
        -sf, --sf, --sort-files, --group-files-first
                                sort files first
        -t, -st, --st
                                sort by modification time, newest first

general options:

        -h, --h, --help         prints this help
```

## Alias to ls
```powershell
Set-Alias -Name ls -Value PowerColorLS -Option AllScope
```