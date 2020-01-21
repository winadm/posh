# Выводит в файл $File (line 19) название группы и её состав
# Список групп содержится в переменной $Groups (line 8,17), которую можно задать в явном виде с перечислением групп или
# взять из списка $PathToFileGroups (line 13)
# $DisplayNonGroupElement (line 21) определяет, требуется ли выводить в результате элементы, которые не являются группами

Clear-Host

#$Groups = "Ассистент ФО","Глобальные супервайзеры","Инспектор ФО2","контракты бухгалтерия","контракты юо",`
#"читатели бухгалтерия","читатели опсб","Ассистент Бухгалтерии","Глобальные читатели","Секретарь ОП СБ (док-ты)",`
#"Старший Операционист Кассы"

# Путь к файлу со списком групп
$PathToFileGroups = "D:\Groups.txt"
# Группы могут быть записаны в виде "ZAOEPS\Group" или "Group" с лишними пробелами и знаками табуляции в конце
# Так же в файле могут быть пустые строки

$Groups = Get-Content -Path $PathToFileGroups # Требуется закомментировать, если группы заданы в явном виде в самом скрипте (выше)

$File = "D:\GroupsMembers.txt" # Файл с результатами обработки

$DisplayNonGroupElement = $false
# $true - Будут выводится элементы, которые не являются группами
# $false - Не будут выводится с соответсвующей записью элементы, которые не являются группами

If (Test-Path $File) {Del $File}
Write-Host "Формирование списка членов групп..." -ForegroundColor DarkGreen
For ($i = 0; $i -lt $Groups.Count; $i++)
{
	$GroupName = $Groups[$i]
	$GroupName = $GroupName -replace "ZAOEPS\\"
	
	# ===============================
	# Удаление пробела или табуляции в конце строки
	Do
	{
		If (($GroupName[($GroupName.Length)-1] -like " ") -or ($GroupName[($GroupName.Length)-1] -like "	"))
		{
			$GroupNameWithoutEndSpace = $GroupName[0]
			For ($j=1; $j -lt ($GroupName.Length)-1; $j++)
			{
				$GroupNameWithoutEndSpace = $GroupNameWithoutEndSpace + $GroupName[$j]
			}
			$GroupName = $GroupNameWithoutEndSpace
		}
	}
	Until ( (-not($GroupName[($GroupName.Length)-1] -like " ")) -and (-not($GroupName[($GroupName.Length)-1] -like "	")) )
	# ================================
	
	If (-not($GroupName -like "")) 
	{
		$GroupName
		$GroupObject = $null
		$ErrorActionPreference = "SilentlyContinue"
		$GroupObject = Get-Group -Identity $GroupName
		$ErrorActionPreference = "Continue"
		If ($GroupObject -eq $null) 
		{
			If ($DisplayNonGroupElement)
			{
				Add-Content -Path $File -Value $GroupName
				Add-Content -Path $File -Value "НЕ ЯВЛЯЕТСЯ ГРУППОЙ!"
				Add-Content -Path $File -Value ""
				Add-Content -Path $File -Value ""
			}
		}
		Else 
		{
			Add-Content -Path $File -Value $GroupName
			Add-Content -Path $File -Value "-------------------"
			Get-ADGroupMember -identity $GroupName | %{Add-Content -Path $File -Value $_.name}
			Add-Content -Path $File -Value ""
			Add-Content -Path $File -Value ""
		}
	}
}
Write-Host "Список членов групп сформирован" -ForegroundColor DarkGreen