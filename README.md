# PowerColorLS

A PowerShell module that displays a colorized directory and file listing with icons. Inspired by [colorls](https://github.com/athityakumar/colorls)

## Overview

*PowerColorLS* is a PowerShell module that displays a colorized directory and file listing with icons in the terminal.
For the module to work, you must first install [Terminal-Icons](https://raw.githubusercontent.com/devblackops/Terminal-Icons/) and setup the [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)

## Usage
From the root directory, run:
```powershell
import-module PowerColorLS
PowerColorLS
```

## Alias to ls
```powershell
Set-Alias -Name ls -Value PowerColorLS -Option AllScope
```