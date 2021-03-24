[CmdletBinding()]
param (
    [string]$UniArchive
)

Write-Host "Hola!"
$setupFolder = "C:\\SetUp\\uni\\"

function Unpack-Archive {
    param (
        [Parameter(ValueFromPipeline)][string] $Path
    )
    Write-Host "Start unpacking..."
    Remove-Item -Path ($setupFolder + "\" + $UniArchive.Replace('.zip', '')).ToString() -Recurse
    Expand-Archive -Path "$setupFolder\$UniArchive" -DestinationPath ("C:\Setup\uni\" + $UniArchive.Replace('.zip', '')).ToString()
    Remove-Item "$setupFolder\$UniArchive"
    return ("C:\Setup\uni\" + $UniArchive.Replace('.zip', '')).ToString()
}
 function Install-Archive() {
    param (
        [Parameter(ValueFromPipeline)][string]$UniArchiveFolder
    )

    $UniArchiveFolder
    $info = Get-Content -Raw "$UniArchiveFolder\info.json"| ConvertFrom-Json
    Write-Host $info.installWith $info.args ($UniArchiveFolder + $info.installerPath) | Out-File -FilePath C:\SetUp\log.txt

    &$info.installWith $info.args ($UniArchiveFolder + $info.installerPath)
 }  

Unpack-Archive | Install-Archive