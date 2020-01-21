cls

$C=@()
Get-ADComputer -SearchBase "ou=Рабочие станции,ou=Компьютеры,ou=ХОЛДИНГ,dc=zaoeps,dc=local" -Filter {enabled -eq $true} -Properties memberof | 
%{
	$comp = $_
	$notStr = $true
	foreach ($memberof in $comp.memberof) 
	{
		If ($memberof -match "_стр") {$notStr=$false} 
	}
	if ($notStr) {$C+=$comp.name} 
}

#Where {$_.memberof -notmatch "_стр"}

Foreach ($comp in $C)
{
	$Computer = Get-ADComputer $comp
	Add-ADGroupMember -Identity "ЭПС нет группы_стр" -Members $Computer
}