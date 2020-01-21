# в excel не верно строит

cls
$Otstup = 0
$FileList = "D:\List.csv"
If (Test-Path $FileList) {Del $FileList}
$str = ""

# Созадём объект Excel
$Excel = New-Object -ComObject Excel.Application
# Делаем его видимым
$Excel.Visible = $true
# Добавляем рабочую книгу
$WorkBook = $Excel.Workbooks.Add()
# Переменная для обращения к листу
$List = $WorkBook.Worksheets.Item(1)

$Listname = $false
$Column = 1

function recurs
{
	param ($Group)
	# Переименовываем лист
	If (!($ListName)) 
	{
		
		$List.Name = ($Group -replace "[\:\\\/\?\*\[\]]").substring(0,30)
		$ListName = $true
		$List.Cells.Item(1,1).Font.ThemeFont = 1
		$List.Cells.Item(1,1).Font.ThemeColor = 4
		$List.Cells.Item(1,1).Font.ColorIndex = 55
		$List.Cells.Item(1,1).Font.Color = 8210719
	}
	$GroupLowLevel = Get-ADGroupMember $Group | Where {$_.objectClass -like "group"} # получаем список групп
	$UsersLowLevel = Get-ADGroupMember $Group | Where {$_.objectClass -like "user"}  # получаем список пользователей
	Add-Content -Path $FileList -Value ($str+"@"+$Group)
	$Row = (Get-Content $FileList).Count
	$List.Cells.Item($Row,$Column) = $Group
	$List.Cells.Item($Row,$Column).Font.Bold = $true
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
					$Column = $Otstup+1
					$Row = (Get-Content $FileList).Count
					$List.Cells.Item($Row,$Column) = $UsersLowLevel[$i].name
				}
			}
			Else
			{
				Add-Content -Path $FileList -Value ($str+$UsersLowLevel.name)
				$Column = $Otstup+1
				$Row = (Get-Content $FileList).Count
				$List.Cells.Item($Row,$Column) = $UsersLowLevel.name
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
				$Column = $Otstup+1
				$Row = (Get-Content $FileList).Count
				$List.Cells.Item($Row,$Column) = $GroupLowLevel.name
#				$str+$GroupLowLevel.name
			}
		}
	}
	Else 
	{
		$Otstup = $Otstup-1
	}
}

Recurs "Подразделения Шагабутдинова Р.Р._стр"
