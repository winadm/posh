cls
$Otstup = 0
$FileList = "D:\List.csv"
If (Test-Path $FileList) {Del $FileList}
$str = ""

function recurs 
{
	param ($Group)
	$GroupLowLevel = Get-ADGroupMember $Group | Where {$_.objectClass -like "group"} # получаем список групп
	$UsersLowLevel = Get-ADGroupMember $Group | Where {$_.objectClass -like "user"}  # получаем список пользователей
	Add-Content -Path $FileList -Value ($str+"@"+$Group)
#	$str+$Group
	If (($GroupLowLevel -ne $null) -or ($UsersLowLevel -ne $null)) 
	{	
		$Otstup++
#		$Otstup
		$str = ""
		For ($CountOtstup=0; $CountOtstup -lt $Otstup; $CountOtstup++)
		{
			$str+=";"
		}
		If ($UsersLowLevel -ne $null)
		{
			$Z = $UsersLowLevel.Count # количество пользователей
			If ($Z -gt 0) # если в списке пользователей больше одного
			{	
				For ($i=0; $i -lt $UsersLowLevel.Count; $i++)
				{
					Add-Content -Path $FileList -Value ($str+$UsersLowLevel[$i].name)
#					$UsersLowLevel[$i].name
				}
			}
			Else
			{
				Add-Content -Path $FileList -Value ($str+$UsersLowLevel.name)
#				$str+$UsersLowLevel.name
			}
		}
		If ($GroupLowLevel -ne $null)
		{
			$Z = $GroupLowLevel.Count # количество групп
			If ($Z -gt 0) # если в списке групп больше одной группы
			{	
				For ($i=0; $i -lt $GroupLowLevel.Count; $i++)
				{
#					$GroupLowLevel[$i].name
					recurs ($GroupLowLevel[$i].name)
				}
			}
			Else
			{
				Add-Content -Path $FileList -Value ($str+$GroupLowLevel.name)
#				$str+$GroupLowLevel.name
			}
		}
	}
	Else 
	{
		$Otstup = $Otstup-1
	}
}

Recurs "Департамент информационных технологий_стр"
