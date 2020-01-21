# Уникальные пользователи в группах

cls

$File = "d:\temp.txt"
If (Test-Path $File) {Del $File}
$Users = @()

$FirstGroup = "_Настройка параметров портов (USB_DVD_FDD - включено)"
$SecondGroup = "_Настройка параметров портов (USB-включено_DVD_FDD-выключено)"

Get-ADGroupMember -Identity $FirstGroup -Recursive | %{$Users += $_.name}

Get-ADGroupMember -Identity $SecondGroup -Recursive | 
%{
	$Unicum = $true
	For ($i=0; $i -lt $Users.Count; $i++)
	{If ($_.name -like $Users[$i]) {$Unicum = $false}}
	
	If ($Unicum) {Add-Content -Path $File -Value $_.name}
}

