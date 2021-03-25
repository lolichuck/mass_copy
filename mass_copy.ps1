Clear-Host

#Copy and install items
function Copy-Installation() {
    


    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()][switch] $File,
        [Parameter()][string[]] $Address,
        [Parameter()][ValidateRange(1,255)][int] $ThrottleLimit
    )

        #Pick up items
    function Get-FileDialog() {
        param (
            [Parameter()][switch] $Folder,
            [string]$Filter,
            [string]$Header
        )
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.Title = $Header
        $OpenFileDialog.Filter = $Filter
        $result = $OpenFileDialog.ShowDialog()
        if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
            break
        } else {
            return $OpenFileDialog.FileName
        }
    }

    #Check file into archive
    Function Check-ZippedFiles() {
        param (
            [Parameter(Mandatory)][string] $Path
        )

        [void][System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
        if ([IO.Compression.ZipFile]::OpenRead($Path).Entries.FullName -match "info.json") {
            return $true
        } else {
            return $false
        }
    }

    ################################################################################################################################

    if ($File.IsPresent) {
        $Address = Get-Content (Get-FileDialog -Filter "Text File | *.txt" -Header "Выберите файл с адресами")
    } 

    $Item = Get-FileDialog -Filter "Zip Folder | *.zip" -Header "Выберите архив" | Get-ItemProperty
    if (Check-ZippedFiles -Path $Item.FullName) {         
        $Address | ForEach-Object -Parallel {
            if (Test-Connection $_ -Quiet) {
                if (!(Test-Path -Path "\\$_\c$\setup\uni\")) {
                    New-Item -ItemType Directory -Path "\\$_\c$\setup\uni\"
                }
                Copy-Item $using:Item -Destination "\\$_\c$\setup\uni\"
                Copy-Item "unpack_n_install.ps1" -Destination "\\$_\c$\setup\uni\"
                $setupPath = ("C:\Setup\uni\" + $using:Item.Name).ToString()
                if (Test-Path $setupPath) {
                    &PsExec /i "\\$_" powershell.exe -executionpolicy bypass -file C:\SetUp\uni\unpack_n_install.ps1 ($using:Item.Name).ToString()  
                }
            } 
        } -ThrottleLimit $ThrottleLimit
    } else {
        Write-Host "Config file not found here"
        Write-Host "Press any key to close..."
        [System.Console]::ReadKey()
    }
}

Copy-Installation -Address 192.168.4.76 -ThrottleLimit