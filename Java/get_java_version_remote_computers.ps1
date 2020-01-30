# PowerShell скрипт для проверки верси Java SE (JRE) на удаленных компьютерах/серверах
# Подробности в статье https://winitpro.ru/index.php/2020/01/30/proverit-versiyu-obnovit-udalit-java-iz-powershell/

# Проверить версию Java по списку компьютеров
# $computers = @('sever1,server2,server3')

# Проверить версию Java по списоку серверов в текстовом файле
#$computers=Get-content C:\PS\ServerList.txt

# Получить версию Java на всех серверах домена
 
$computers = ((get-adcomputer -Filter { enabled -eq "true" -and OperatingSystem -Like '*Windows Server*' }).name).tostring()
Get-WmiObject  -Class Win32_Product -ComputerName $computers -Filter "Name like '%Java%' and not Name like '%Java Auto Updater%'" | Select __Server, Version
