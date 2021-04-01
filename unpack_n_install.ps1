[CmdletBinding()]
param (
    [string]$UniArchive,
    [string]$FullPath
)

$setupFolder = "C:\SetUp\uni\"
$installFolder = ("C:\Setup\uni\" + $UniArchive.Replace('.zip', '').ToString())
$logFile = $setupFolde + "log.txt"

# function Get-Archive ($URL) {
#     try {
#         $webClient = New-Object System.Net.WebClient
#         $webClient.DownloadFile($FTPAddress, $setupFolder)
#     }
#     catch {
#         $Error | Out-File C:\SetUp\log.txt -Append -NoClobber
#     }
# }

function Unpack-Archive {
    param (
        [Parameter(ValueFromPipeline)][string] $Path
    )
    try {
        if ([System.IO.File]::Exists($installFolder)) {
            try {
                Remove-Item -Path $folder -Recurse -Force
                Remove-Item -Path $installFolder -Recurse -Force
            }
            catch {
                Write-Host "Extraction Error!" | Out-File -FilePath "$setupFolder\log.txt"
            }
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
    catch {
        $Error | Out-File C:\SetUp\log.txt -Append -NoClobber
    }
}

 function Install-Archive() {
    param (
        [Parameter(ValueFromPipeline)][string]$UniArchiveFolder
    )

    $info = Get-Content -Raw "$installFolder\info.json"| ConvertFrom-Json
    foreach($unit in $info) {
        if ($unit.installWith -match ".msi") {
            # &msiexec /i $unit.args ($UniArchiveFolder + $unit.installWith)
            Write-Host $unit.args ($UniArchiveFolder + $unit.installWith) | Out-File $logFile
        } else {
            # &($UniArchiveFolder + $unit.installWith) $unit.args
            Write-Host ($UniArchiveFolder + $unit.installWith) $unit.args | Out-File $logFile
        }
    }
 }
 
Unpack-Archive | Install-Archive
