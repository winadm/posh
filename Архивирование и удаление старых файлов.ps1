# В папке  $FolderPath  архивируются и удаляются все файлы, кроме архивных (расширение ".rar"), у которых
# время создания больше  $DaysOfLive  дней 

If (Test-Path "C:\Program Files (x86)\WinRAR\winrar.exe") {$WinRarPath = "C:\Program Files (x86)\WinRAR\winrar.exe"}
ElseIf (Test-Path "C:\Program Files\WinRAR\winrar.exe") {$WinRarPath = "C:\Program Files\WinRAR\winrar.exe"}
Else {"WinRar не установлен"; return}
# $WinRarPath
$FolderPath = "d:\SecLog"
$Files = Get-ChildItem $FolderPath
$NowDate = Get-Date
[system.decimal]$DaysOfLive = 3
For ($i=0; $i -lt $Files.Count; $i++) {
	If ($Files[$i].Extension -ne ".rar") {
		$TimeDifference = $NowDate - $Files[$i].CreationTime
		$TimeDifference.TotalDays
		If ($TimeDifference.TotalDays -lt $DaysOfLive) {
			$ArchiveName = $Files[$i].FullName+".rar"
			& $WinRarPath a -m3 -ep1 -df $ArchiveName $Files[$i].FullName
			# a - добавить в архив
			# m3 - степень сжатия Normal
			# ep1 - исключить базовый каталог из имен
			# df - удалить файлы после архивирования
		}
	}
}