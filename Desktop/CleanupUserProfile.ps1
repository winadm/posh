# Скрипт можно использовать для очистки папок в профиле пользователя (кэш, temp, downloads,кэш google chrome)
# PowerShell скрипт запускается из-под пользователя (права администратора) не требуются. Очищаются только временные файлы и кэш текущего пользователя.
# Оптимально для запуска через логофф скрипт GPO или через планировщик Task Sheduler  
# Можно использовать на RDS хостах, VDI или рабочих станциях для очистки профилей пользователей
# Рекомендуем сначала протестировать работу скрипта в вашем окружении, и после этого удалить опцию WhatIf для физического удаления файлов
# Более подробное описание здесь: https://winitpro.ru/index.php/2022/08/29/ochistka-temp-cache-failov-v-profile-polzovatelya/

$Logfile = "$env:USERPROFILE\cleanup_profile_script.log"
$OldFilesData = (get-date).adddays(-14)

# Полная очистка каталогов с кэшем
[array] $clear_paths = (
  'AppData\Local\Temp',
  'AppData\Local\Microsoft\Terminal Server Client\Cache',
  'AppData\Local\Microsoft\Windows\WER',
  'AppData\Local\Microsoft\Windows\AppCache',
  'AppData\Local\CrashDumps'
  #'AppData\Local\Google\Chrome\User Data\Default\Cache',
  #'AppData\Local\Google\Chrome\User Data\Default\Cache2\entries',
  #'AppData\Local\Google\Chrome\User Data\Default\Cookies',
  #'AppData\Local\Google\Chrome\User Data\Default\Media Cache',
  #'AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal'
  )
# Каталоги, в которых удаляются только старые файлы
  [array] $clear_old_paths = (
    'Downloads'
  )

function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}

WriteLog "Starting profile cleanup script"

# если вы хотите очистить каталог с кэшем Google Chrome, нужно  остановить процесс chrome.exe
$currentuser=$env:UserDomain + "\"+ $env:UserName
WriteLog  "Stopping Chrome.exe Process for $currentuser"
Get-Process -name chrome -ErrorAction SilentlyContinue| ? {$_.SI -eq (Get-Process -PID $PID).SessionId} | Stop-Process
Start-Sleep -Seconds 5

# очистка каталогов с кэшем
ForEach ($path In $clear_paths)
{
    If ((Test-Path -Path "$env:USERPROFILE\$path") -eq $true)
    {  
      WriteLog "Clearing $env:USERPROFILE\$path"
      Remove-Item -Path "$env:USERPROFILE\$path" -Recurse -Force -ErrorAction SilentlyContinue -whatif  -Verbose 4>&1 | Add-Content $Logfile
    }
}
# удаление старых файлов 
ForEach ($path_old In $clear_old_paths)
{
    If ((Test-Path -Path "$env:USERPROFILE\$path_old") -eq $true)
    {  
      WriteLog "Clearing $env:USERPROFILE\$path_old"
      Get-ChildItem -Path "$env:USERPROFILE\$path_old" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {($_.LastWriteTime -lt $OldFilesData )} | Remove-Item  -Recurse -Force -ErrorAction SilentlyContinue -whatif  -Verbose 4>&1 | Add-Content $Logfile
    }
}
WriteLog "End profile cleanup script"
