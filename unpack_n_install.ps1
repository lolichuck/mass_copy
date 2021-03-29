[CmdletBinding()]
param (
    [string]$UniArchive,
    [string]$FullPath
)

$setupFolder = "C:\\SetUp\\uni\\"
$installFolder = ("C:\Setup\uni\" + $UniArchive.Replace('.zip', '').ToString())

function Get-Archive {
    # Пока только чере SMB, позже запилю FTP
    $copyFromSMB = "\\" + $env:Computername + "\" + $FullPath.Replace(":", "$")
    Copy-Item $copyFromSMB -Destination $setupFolder
}

function Unpack-Archive {
    param (
        [Parameter(ValueFromPipeline)][string] $Path
    )

    if ([System.IO.File]::Exists($installFolder)) {
        Remove-Item -Path $folder -Recurse
    }

    if(!(Test-Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\")){
        [void][System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
        [IO.Compression.ZipFile]::ExtractToDirectory("$setupFolder\$UniArchive", ($installFolder))
    } else {
        try {
            & "${env:ProgramFiles}\7-Zip\7z.exe" x "$setupFolder\$UniArchive" "-o$($installFolder)" -y
        } 
        catch {
            write "Extraction Error!" | Out-File -FilePath "$setupFolder\log.txt"
        }
    }

    Remove-Item "$setupFolder\$UniArchive"
    return $installFolder
}
 function Install-Archive() {
    param (
        [Parameter(ValueFromPipeline)][string]$UniArchiveFolder
    )

    cd $installFolder
    
    $info = Get-Content -Raw ".\info.json"| ConvertFrom-Json
    foreach($unit in $info) {
        if ($unit.installWith -match ".msi") {
            &msiexec /i $unit.args ($UniArchiveFolder + $unit.installWith)
        } else {
            &($UniArchiveFolder + "\" + $unit.installWith
            ) $unit.args
        }
    }
 }
 
Get-Archive
Unpack-Archive | Install-Archive
