# Скрипт (https://github.com/winadm/posh/blob/master/Desktop/CleanupUserProfile.ps1) изменен для удаления файлов в папке Windows\Temp


$Logfile = "$env:USERPROFILE\cleanup_script.log"
$OldFilesData = (get-date).adddays(-14)

# Полная очистка каталогов с кэшем
[array] $clear_paths = (
  'AppData\Local\Temp',
  'AppData\Local\Microsoft\Windows\AppCache',
  'AppData\Local\CrashDumps'
  )
# Каталоги, в папке Windows(!!!) ВНИМАТЕЛЬНО ТУДА ДОБАВЛЯЕМ ИЛИ НЕ ДОБАВЛЯЕМ.
  [array] $clear_Win_paths = (
    'Temp'
	
  )

function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}

# очистка каталогов с кэшем
ForEach ($path In $clear_paths)
{
    If ((Test-Path -Path "$env:USERPROFILE\$path") -eq $true)
    {  
      WriteLog "Clearing $env:USERPROFILE\$path"
      Remove-Item -Path "$env:USERPROFILE\$path" -Recurse -Force -ErrorAction SilentlyContinue  | Add-Content $Logfile
    }
}
# удаление старых файлов 
ForEach ($path_w In $clear_Win_paths)
{
    If ((Test-Path -Path "$env:SystemRoot\$path_w") -eq $true)
    {  
      WriteLog "Clearing $env:SystemRoot\$path_w"
      Get-ChildItem -Path "$env:SystemRoot\$path_w" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {($_.LastWriteTime -lt $OldFilesData )} | Remove-Item  -Recurse -Force -ErrorAction SilentlyContinue | Add-Content $Logfile
    }
}
WriteLog "End profile cleanup script"
