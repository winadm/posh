# Выбрать из первого файла уникальные данные, т.е. которых нет во втором файле

cls

$File1 = "d:\disk_C\log_newPingable.txt "
$File2 = "d:\disk_C\log_notPingable.txt"

$Strings = Get-Content $File1

Get-Content $File2 | 
%{
	$Unicum = $true
	For ($i=0; $i -lt $Strings.Count; $i++)
	{If ($_ -like $Strings[$i]) {$Unicum = $false}}
	
	If ($Unicum) {$_}
}
