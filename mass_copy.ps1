Clear-Host

#Переменные
$setupFolder = "c:\setup"
$filename

#Метод для выбора папки с исходжными файлами
function Get-Folder()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
    Out-Null
    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.SelectedPath = $HOME
    $OpenFolderDialog.ShowNewFolderButton = $false
    $OpenFolderDialog.ShowDialog() | Out-Null
}

#Метод для вызова проводника
function Get-File()
{   
    param 
    (
        $Extention
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
    Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = $Extention
    $result = $OpenFileDialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
        return $false
    } else {
        return $OpenFileDialog.FileName
    }
}

#Выбираем файл для копирования
Write-Host "Выберите файл, который необходимо скопировать и устаовить`: " -NoNewLine
$file = Get-File -extention "MSI/EXE Installer | *.msi; *.exe"
if ($file -ne $False)
{
    $filename = (Get-ItemProperty $file).Name
    Write-Host "$filename" -ForegroundColor Yellow
} else {
    Write-Host "Файл установщика не выбран!" -ForegroundColor Red
    Break
}

#Выбираем файл с адресами
Write-Host "Выберите файл с IP-адресами`: " -NoNewLine
$addressesList = Get-File $file -extention "Text file | *.txt"
if ($file -ne $False)
{
    Write-Host "$addressesList" -ForegroundColor Yellow
    $addresses = Get-Content $addressesList
} else {
    Write-Host "Файл с адресами не выбран!" -ForegroundColor Red
    Break
}

foreach($address in $addresses)
{
    $isAvailable = $false
    Write-Host "$address`:`t" -NoNewline
    #Копируем файл
    if ((Test-Connection $address -Quiet) -eq $True) {
            
        if(Test-Path "\\$address\c$\setup\$filename")
        {
            Write-Host -ForegroundColor Green "Установочный файл уже находится в папке установки. " -NoNewline
            $isAvailable = $True
        } 
        else 
        {   
            Write-Host "Копируем файл... "
            Copy-Item $file \\$address\c$\setup\$filename
            if(Test-Path "\\$address\c$\setup\$filename")
            {
                Write-Host "Файл скопирован!"
                $isAvailable = $True
            }    
        }            
    } 
    else 
    {
        Write-Host "Хост недоступен." -ForegroundColor Red
    }
    #Устанавливаем Файл
    if ($isAvailable -eq $True)
    {
        Write-Host ""
        &PsExec "\\$address" msiexec /i "$setupfolder\$filename" | Out-Null
    }
    Write-Host
}

#Удаляем лишние переменные
Remove-Variable -Name setupFolder, fileName, file, addressesList, addresses, address, isAvailable -ErrorAction "SilentlyContinue"