<#
.SYNOPSIS
    Processes GDx export files
.DESCRIPTION
    Processes GDx export files, rendering SVG content to PDF and PNG and copying the resulting
    files to a destination directory under new file names, created from the export metadata.
.EXAMPLE
    PS C:\> .\Import-GDx.ps1 -SourceDirectory \\server\export\gdx -DestinationDirectory \\server\maximEye\scanlink\images\gdx -DryRun
    Displays what would happen when processing the exports in the source directory '\\server\export\gdx' without
    making any changes.
.EXAMPLE    
    PS C:\> .\Import-GDx.ps1 -SourceDirectory \\server\export\gdx -DestinationDirectory \\server\maximEye\scanlink\images\gdx
    Processes the exports in '\\server\export\gdx' using the inkscape executable at the default location
    (relative to the script, in '.\deps\inkscape'). Does not remove the exports from the source directory.
.EXAMPLE    
    PS C:\> .\Import-GDx.ps1 -SourceDirectory \\server\export\gdx -DestinationDirectory \\server\maximEye\scanlink\images\gdx -InkscapePath 'C:\Program Files\Inkscape\inkscape.exe'
    Processes the exports in '\\server\export\gdx' using a custom inkscape executable.
.EXAMPLE    
    PS C:\> .\Import-GDx.ps1 -SourceDirectory \\server\export\gdx -DestinationDirectory \\server\maximEye\scanlink\images\gdx -InkscapePath 'C:\Program Files\Inkscape\inkscape.exe' -Clean
    Processes the exports in '\\server\export\gdx' using a custom inkscape executable, removing the exports
    from the source directory.
#>
[CmdletBinding()]
param (
    # The source directory in which the GDx tests have been exported
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -PathType Container $_})]
    [string]
    $SourceDirectory,
    
    # The destination directory in which the converted files will be saved
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -PathType Container $_})]
    [string]
    $DestinationDirectory,

    # Specifies the path to the inkscape executable
    [Parameter(Mandatory=$false,
               HelpMessage="Path to the inkscape executable.")]
    [Alias("PSPath")]
    [ValidateNotNullOrEmpty()]
    [string]
    $InkscapePath = "./deps/inkscape/inkscape.exe",

    # Remove source subdirectories when imported
    [Parameter()]
    [switch]
    $Clean,

    # Don't actually make any changes
    [Parameter()]
    [switch]
    $DryRun
)

function ConvertTo-Png {
    [CmdletBinding()]
    param (
        # File name to convert
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -PathType Leaf -Include "*.svg" $_})]
        [string]
        $Path,
        # Export DPI
        [Parameter(Mandatory=$false)]
        [int]
        $Dpi=300
    )
    
    process {
        $DestinationPath = [System.IO.Path]::ChangeExtension($Path, "png")

        "Rendering $Path to PNG with DPI $Dpi as $DestinationPath" | Out-Host

        if (!$DryRun) {
            &$InkscapePath --without-gui --export-png "$DestinationPath" --export-dpi $Dpi --file "$Path" | Out-Null
        }
        
        return $DestinationPath
    }
}

function ConvertTo-Pdf {
    [CmdletBinding()]
    param (
        # File name to convert
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -PathType Leaf -Include "*.svg" $_})]
        [string]
        $Path
    )
    
    process {
        $DestinationPath = [System.IO.Path]::ChangeExtension($Path, "pdf")
        
        "Rendering $Path to PDF as $DestinationPath" | Out-Host

        if (!$DryRun) {
            &$InkscapePath --without-gui --export-pdf "$DestinationPath" --file "$Path" | Out-Null
        }
        
        return $DestinationPath
    }
}

function Get-Metadata {
    [CmdletBinding()]
    param (
        # File name containing metadata
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -PathType Leaf -Include "*.xml" $_})]
        [string]
        $Path
    )
    
    process {
        $DataObject = [xml](Get-Content -Path $Path)

        $Date = $xmlContent.Polarimeter.Session1.Date

        $Metadata = [PSCustomObject]@{
            FirstName = $DataObject.Polarimeter.PatientData.FirstName;
            LastName = $DataObject.Polarimeter.PatientData.LastName;
            ID = $DataObject.Polarimeter.PatientData.ID;
            Date = [datetime]($Date.Split('T')[0]);
        }

        "Got metadata from ${Path}:" | Out-Host
        $Metadata | Format-Table | Out-Host

        return $Metadata
    }
}

$ImportDirectories = Get-ChildItem -Directory $SourceDirectory

foreach ($ImportDirectory in $ImportDirectories) {
    "Processing $ImportDirectory" | Out-Host

    $SvgFile = (Get-ChildItem -Filter "*.svg" $ImportDirectory)[0]
    $XmlFile = (Get-ChildItem -Filter "*.xml" $ImportDirectory)[0]

    $PngFile = ConvertTo-Png -Path $SvgFile
    $PdfFile = ConvertTo-Pdf -Path $SvgFile

    $Metadata = Get-Metadata -Path $XmlFile

    $DateString = Get-Date -Date $Metadata.Date -Format "yyyyMMdd"

    $BaseFileName = "$($Metadata.ID)_$($Metadata.LastName)_$($Metadata.FirstName)_GDx_$($DateString)"

    $PngDestination = (Join-Path -Path $DestinationDirectory -ChildPath "$BaseFileName.png")
    $PdfDestination = (Join-Path -Path $DestinationDirectory -ChildPath "$BaseFileName.pdf")

    $Suffix = 1

    while ((Test-Path -Path $PngDestination) -or (Test-Path -Path $PdfDestination)) {
        "Destination file exists. Trying suffix $Suffix." | Write-Host
        $PngDestination = (Join-Path -Path $DestinationDirectory -ChildPath "${BaseFileName}_${Suffix}.png")
        $PdfDestination = (Join-Path -Path $DestinationDirectory -ChildPath "${BaseFileName}_${Suffix}.pdf")
        $Suffix += 1
    }

    if ((Test-Path -Path $PngDestination) -or (Test-Path -Path $PdfDestination)) {
        "Destination file already exists." | Write-Error
    } else {
        "Moving $PngFile to $PngDestination" | Out-Host

        if (!$DryRun) {
            Move-Item -Path $PngFile -Destination $PngDestination
        }
        
        "Moving $PdfFile to $PdfDestination" | Out-Host

        if (!$DryRun) {
            Move-Item -Path $PdfFile -Destination $PdfDestination
        }

        if ((Test-Path -Path $PngDestination -Type Leaf) -and (Test-Path -Path $PdfDestination -Type Leaf) -and $Clean) {
            "Removing directory $ImportDirectory" | Out-Host
    
            if (!$DryRun) {
                Remove-Item -Path $ImportDirectory -Recurse
            }
        }
    }
}
