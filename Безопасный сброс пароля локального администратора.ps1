# Пароль в открытом виде конвертируется в безопасный объект (SecurityString) powershell
# Затем этот отбъект конвертируется в зашифрованную строку, её сохраняем в файле (вариант для хранения)
# читается зашифрованная строка (она можеть быть расшифрована только под той
#	учетной записью, под которой была зашифрована) и конвертируется в безопасный объект (SecurityString) powershell
# И только теперь можно SecurityString

cls

$adminPassword = "sd8Ddfnds88" | ConvertTo-SecureString -asPlainText -Force
Set-Content d:\1.txt -Value (ConvertFrom-SecureString $adminPassword)

$computerName = "w003323"
$adminUser = [ADSI] "WinNT://$computerName/Администратор"
$NewPass = (Get-Content d:\1.txt) | ConvertTo-SecureString
#Конвертирование из SecureString в открытый вид
$Pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPass))
$adminUser.SetPassword($Pass)
Remove-Variable * -ErrorAction SilentlyContinue



#Всё, только коротко и без этапа шифрования на диск
#$password = Read-Host -prompt "Enter new password for user" -assecurestring
#$decodedpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
#$user = [adsi]"WinNT://w003323/Администратор"
#$user.SetPassword($decodedpassword)