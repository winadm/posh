cls
$DeepCount = 4 # глубина вложенности папок

$FileCSV = "d:\log.csv"
If (Test-Path $FileCSV) {Del $FileCSV}

function Get-Folder
{
	param ($FolderPath)
	$Folders = Get-ChildItem $FolderPath | Where {$_.Attributes -like "Directory"}
	
	Foreach ($Folder in $Folders)
	{
		$s = $Folder.FullName -split "\\"
		$Otstup = ""
		$s | %{$Otstup+=";"}
		$Otstup+$Folder.FullName
		Add-Content $FileCSV -Value ($Otstup+$Folder.Name)
		If ($s.Count -le ($DeepCount+3)) 
		{
			If ($Folder.Name -cnotmatch "^[А-Я][а-я]+ [А-Я].[А-Я]$") # Исключим из дальнейшей обработки личные папки
			{Get-Folder $Folder.FullName}
		}
	}	

#	Get-ChildItem $FolderPath | Where {$_.Attributes -like "Directory"} | %{Get-FolderPermissions $_.FullName}
}

Get-Folder "\\b000393\ИТ\Хавалкин И.А"