# Пустые группы рассылок (без "*_рас") и в определенном контейнере AD

cls
$DistributionGroups = Get-DistributionGroup
$i = 0
Foreach ($group in $DistributionGroups)
{
	$members = $null
	$members = Get-DistributionGroupMember -ResultSize Unlimited $group | select displayname
	If (($members -eq $null) -and ($group.DisplayName -notmatch "_рас") -and (($group.OrganizationalUnit -match "Roles") -or ($group.OrganizationalUnit -match "Sharep"))) 
	{
		$group | select name , OrganizationalUnit
		$i++
		Add-Content -Path D:\EmptyDistributionGroups.txt -Value ($group.Name+";"+$group.OrganizationalUnit+";"+$group.PrimarySmtpAddress)
	}
}
"Всего групп: "+$i
