[CmdletBinding()]
param (
    [string]$UniArchive
)

$setupFolder = "C:\\SetUp\\uni\\"

function Unpack-Archive {
    param (
        [Parameter(ValueFromPipeline)][string] $Path
    )

    $folder = ($setupFolder + "\" + $UniArchive.Replace('.zip', '')).ToString()
    if ([System.IO.File]::Exists($folder)) {
        Remove-Item -Path $folder -Recurse
    }

    if(Test-Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"){
        if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -le 378389) {
            write "New Net Framework version required" | Out-File -NoClobber -Append -FilePath "C:\\Setup\\uni_log.txt"
            break
        }
        # unpack the archive via .NET methods instead of cmdlet, but .NET <= 4.5 required
        [void][System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
        [IO.Compression.ZipFile]::ExtractToDirectory("$setupFolder\$UniArchive", ("C:\Setup\uni\" + $UniArchive.Replace('.zip', '')).ToString())

        #Expand-Archive -Path "$setupFolder\$UniArchive" -DestinationPath ("C:\Setup\uni\" + $UniArchive.Replace('.zip', '')).ToString()
    }

    Remove-Item "$setupFolder\$UniArchive"
    return ("C:\Setup\uni\" + $UniArchive.Replace('.zip', '')).ToString()
}
 function Install-Archive() {
    param (
        [Parameter(ValueFromPipeline)][string]$UniArchiveFolder
    )

    $info = Get-Content -Raw "$UniArchiveFolder\info.json"| ConvertFrom-Json
    Write-Host ($UniArchiveFolder + $info.installerPath) $info.args

    if ($info.installerPath -match ".msi") {
        &$info.installWith $info.args ($UniArchiveFolder + $info.installerPath)
    } else {
        &($UniArchiveFolder + "\" + $info.installerPath) $info.args
    }
 }  

Unpack-Archive | Install-Archive