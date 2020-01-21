cls

$Group = "Департамент Голикова Р.В.-Махмудова М.М._рас"

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

Recurs $Group

# Созадём объект Excel
$Excel = New-Object -ComObject Excel.Application
# Делаем его видимым
$Excel.Visible = $true
# Добавляем рабочую книгу
$WorkBook = $Excel.Workbooks.Add()
# Переменная для обращения к листу
$List = $WorkBook.Worksheets.Item(1)

If ($Group.Length -lt 30) {$GroupLength = $Group.Length} Else {$GroupLength = 30} # $GroupLength - найдем длину строки и если она более 30, то ограничим её 30-тью, чтобы можно было задать имя листа в Excel
$List.Name = ($Group -replace "[\:\\\/\?\*\[\]]").substring(0,$GroupLength) #удаление спец.символов и ограничение 30-ю символами 
$List.Cells.Item(1,1).Font.ThemeFont = 1
$List.Cells.Item(1,1).Font.ThemeColor = 4
$List.Cells.Item(1,1).Font.ColorIndex = 55
$List.Cells.Item(1,1).Font.Color = 8210719
$List.Cells.Item(1,1).Font.Bold = $true
$List.Cells.Item(1,1) = $Group

$Row = 1
Get-Content $FileList |
%{
	$str = $_
	$Row++
	$Bold = $false
	If ($str -match "@") {$Bold = $true; $str = $str -replace "@"}
	$Column = 1
	If ($str -match "^;") 
	{
		Do
		{
			$str = $str -replace "^;"
			$Column++
		}
		While ($str -match ";")
	}
	$List.Cells.Item($Row,$Column) = $str
	If ($Bold) {$List.Cells.Item($Row,$Column).Font.Bold = $true}
}