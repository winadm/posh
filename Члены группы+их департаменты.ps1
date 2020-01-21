cls
Get-ADGroupMember "Remote_Otp_Users" | sort name |
%{
	$User = $_.SamAccountName
	$DN = (Get-ADUser $User -Properties memberof).memberof | Where {$_ -match "_стр,"}
	If ($DN -match "Служебные учетные записи_стр")
	{
		$Dep = "Служебные учетные записи"
	}
	Else
	{
		$Dep = $DN -replace ",OU=Административная группа,OU=ЭПС.+$" -replace ",OU=Коммерческая группа,OU=ЭПС.+$" -replace "^.+OU="
	}
	$_.name+": "+$Dep
}