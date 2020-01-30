# PowerShell скрипт для удаления всех версий Java SE (JRE) на компьютере
# Подробности в статье  https://winitpro.ru/index.php/2020/01/30/proverit-versiyu-obnovit-udalit-java-iz-powershell/

$uninstall32 = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -like "*Java*" } | select UninstallString
$uninstall64 = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -like "*Java*" } | select UninstallString

# Удаление 64 битных версий Java
if ($uninstall64) {
    $uninstall64 = $uninstall64.UninstallString -Replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", ""
    $uninstall64 = $uninstall64.Trim()
    Write "Uninstalling..."
    start-process "msiexec.exe" -arg "/X $uninstall64 /qb" -Wait
}
# Удаление 32 битных версий Java
if ($uninstall32) {
    $uninstall32 = $uninstall32.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
    $uninstall32 = $uninstall32.Trim()
    Write "Uninstalling all Java SE versions..."
    start-process "msiexec.exe" -arg "/X $uninstall32 /qb" -Wait
}
 
