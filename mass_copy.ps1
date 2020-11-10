clear

#Переменные
$setupFolder = "c:\setup\"
#$sourceFolder = Get-Folder

#Метод для выбора папки с исходжными файлами
function Get-Folder()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
    Out-Null
    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.SelectedPath = $HOME
    $OpenFolderDialog.ShowDialog() | Out-Null
    $OpenFolderDialog.ShowNewFolderButton = $false
}

#Метод для вызова проводника
function Get-File()
{   
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
    Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.ShowDialog()
    $OpenFileDialog.FileName
}

#Выбираем файл для копирования
Write-Host "Выберите файл, который необходимо скопировать и устаовить"
$file = Get-File

$file.GetType()
$file.ForEach(


if ($file.ToString() -match "Cancel")
{
    Write-Host "Выбран файл $file" -ForegroundColor Yellow
} else {
    Write-Host "Файл не выбран!"
}

#Выбираем файл с адресами
Write-Host "Выберите файл с IP-адресами"
$addressesList = Get-FileName
if ($file -match "Cancel")
{
    Write-Host "Выбран файл с адресами $addressesList" -ForegroundColor Yellow
} else {
    Write-Host "Файл с адресами не выбран!"
    Break
}
$addresses = Get-Content $addressesList
foreach($address in $addresses)
{
    Write-Host "$address`:`t" -NoNewline
    #Копируем файл
    if(Test-Path "\\$address\c$\setup\$filename")
    {
        Write-Host -ForegroundColor Green "Установочный файл уже находится в папке установки. "
    } 
    else 
    {
        Write-Host "Начинаем копирование... " -NoNewline
        try 
        {
            Copy-Item $file "\\$address\c$\setup\"
        }
        catch
        {
            Write-Host -ForegroundColor Red "Копирование не завершено!" 
        }
        
        if(Test-Path "\\$address\c$\setup\$filename")
        {
            Write-Host -ForegroundColor Green "Копирование завершено!"
        }
        
    }

    #Устанавливаем Файл

}

#Удаляем лишние переменные
Remove-Variable -Name setupFolder, fileName, file, addressesList, addresses, address






