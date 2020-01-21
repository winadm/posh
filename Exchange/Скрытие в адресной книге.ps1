# Скрытие в адресной книге

Clear-Host
$UserWithoutActiveBox = Get-Content -Path "d:\UserWithoutActiveBox.txt"
Foreach ($User in $UserWithoutActiveBox)
{
	$User = $User -replace " ARCHIV.+"
	$User
	$Name = $null
	Get-ADUser -Filter {displayname -like $User} | %{$Name = $_.samaccountname}
	$Name = "zaoeps\"+$Name
	# Get-Mailbox -Identity $User | Set-Mailbox -HiddenFromAddressListsEnabled $true
}


