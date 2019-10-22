# gdx-export-process
Scripts for processing GDx exports

## Installation

Download the repository as a ZIP file and extract to the location of your choice.

### Dependencies

The script depends on *inkscape*. Download and install the latest version for Windows [here](https://inkscape.org/release/). Take note of the installation directory and supply it to the script when running.

Alternately, download the compressed archive version of inkscape and extract it to a `deps` subfolder of this directory.

## Usage

Use the `Get-Help` cmdlet to view the help information for the script.

Specify source and destination directories and the path to inkscape. Test any changes with the `-DryRun` flag. Provide the `-Clean` flag to remove processed exports from the source directory.

```
NAME
    .\Import-GDx.ps1

SYNOPSIS
    Processes GDx export files


SYNTAX
    .\Import-GDx.ps1 [-SourceDirectory] <String> [-DestinationDirectory] <String> [[-InkscapePath] <String>] [-Clean] [-DryRun] [<CommonParameters>]


DESCRIPTION
    Processes GDx export files, rendering SVG content to PDF and PNG and copying the resulting
    files to a destination directory under new file names, created from the export metadata.


PARAMETERS
    -SourceDirectory <String>
        The source directory in which the GDx tests have been exported

    -DestinationDirectory <String>
        The destination directory in which the converted files will be saved

    -InkscapePath <String>
        Specifies the path to the inkscape executable

    -Clean [<SwitchParameter>]
        Remove source subdirectories when imported

    -DryRun [<SwitchParameter>]
        Don't actually make any changes

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>.\Import-GDx.ps1 -SourceDirectory \\server\export\gdx -DestinationDirectory \\server\maximEye\scanlink\images\gdx -DryRun

    Displays what would happen when processing the exports in the source directory '\\server\export\gdx' without
    making any changes.




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>.\Import-GDx.ps1 -SourceDirectory \\server\export\gdx -DestinationDirectory \\server\maximEye\scanlink\images\gdx

    Processes the exports in '\\server\export\gdx' using the inkscape executable at the default location
    (relative to the script, in '.\deps\inkscape'). Does not remove the exports from the source directory.


    

    -------------------------- EXAMPLE 3 --------------------------

    PS C:\>.\Import-GDx.ps1 -SourceDirectory \\server\export\gdx -DestinationDirectory \\server\maximEye\scanlink\images\gdx -InkscapePath 'C:\Program Files\Inkscape\inkscape.exe'

    Processes the exports in '\\server\export\gdx' using a custom inkscape executable.




    -------------------------- EXAMPLE 4 --------------------------

    PS C:\>.\Import-GDx.ps1 -SourceDirectory \\server\export\gdx -DestinationDirectory \\server\maximEye\scanlink\images\gdx -InkscapePath 'C:\Program Files\Inkscape\inkscape.exe' -Clean

    Processes the exports in '\\server\export\gdx' using a custom inkscape executable, removing the exports
    from the source directory.




REMARKS
    To see the examples, type: "get-help .\Import-GDx.ps1 -examples".
    For more information, type: "get-help .\Import-GDx.ps1 -detailed".
    For technical information, type: "get-help .\Import-GDx.ps1 -full".
```

