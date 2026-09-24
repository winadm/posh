# PowerShell скрипт для поиска и удаления старых версий драйверов в хранилище драйверов Windows
# При обновлении драйвера Windows сохраняет старую версию и со временем размер хранилища драйверов сильно увеличивается
# https://winitpro.ru/index.php/2017/02/03/udalenie-staryx-versij-drajverov-iz-xranilishha-windows/

# Исправления:
# 2026-09
#   - Корректная работа с датой через [datetime]
#   - Группировка по Original Name (одинаковые INF для разных устройств)
#   - Использование pnputil /delete-driver вместо /delete-device

$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Write-Host "Scanning driver store for duplicates..." -ForegroundColor Cyan

# Получаем список всех драйверов в хранилище
$Drivers = pnputil /enum-drivers | ForEach-Object {
    if ($_ -match "Published Name\s*:\s*(.+)") {
        $PublishedName = $matches[1].Trim()
    }
    if ($_ -match "Original Name\s*:\s*(.+)") {
        $OriginalName = $matches[1].Trim()
    }
    if ($_ -match "Provider Name\s*:\s*(.+)") {
        $Provider = $matches[1].Trim()
    }
    if ($_ -match "Class\s*:\s*(.+)") {
        $Class = $matches[1].Trim()
    }
    if ($_ -match "Driver Date and Version\s*:\s*(.+)") {
        # Формат: "Driver Date and Version : 05/12/2023 10.0.19041.3636"
        $DateVersion = $matches[1].Trim()
        if ($DateVersion -match "(\d{2}/\d{2}/\d{4})\s+(.+)") {
            $DateStr = $matches[1]
            $Version = $matches[2]
            # Преобразуем строку даты в [datetime] для корректного сравнения
            $Date = [datetime]::ParseExact($DateStr, "MM/dd/yyyy", $null)
        }
    }
    
    if ($PublishedName -and $OriginalName) {
        [PSCustomObject]@{
            PublishedName  = $PublishedName
            OriginalName   = $OriginalName
            Provider       = $Provider
            Class          = $Class
            Date           = $Date
            Version        = $Version
        }
        $PublishedName = $null
        $OriginalName = $null
        $Provider = $null
        $Class = $null
        $Date = $null
        $Version = $null
    }
}

Write-Host "Found $($Drivers.Count) drivers in store" -ForegroundColor Green

# Группируем по Original Name (базовое имя INF), так как один INF может использоваться несколькими устройствами
$Duplicates = $Drivers | Group-Object OriginalName | Where-Object { $_.Count -gt 1 }

$ToRemove = @()
foreach ($Group in $Duplicates) {
    # Сортируем по дате (от новых к старым) и берём все, кроме последнего (самого нового)
    $OldVersions = $Group.Group | Sort-Object Date -Descending | Select-Object -SkipLast 1
    $ToRemove += $OldVersions
}

if ($ToRemove.Count -eq 0) {
    Write-Host "No duplicate drivers found." -ForegroundColor Green
    exit
}

Write-Host "`nFound $($ToRemove.Count) old driver versions to remove:" -ForegroundColor Yellow
$ToRemove | Format-Table PublishedName, OriginalName, Provider, Class, Date, Version -AutoSize

# Удаление старых версий
foreach ($Driver in $ToRemove) {
    $Name = $Driver.PublishedName
    Write-Host "Deleting $Name ($($Driver.OriginalName))..." -ForegroundColor Yellow
   # Автоматическое удаление драйверов отключено по умолчанию
   # pnputil /delete-driver $Name /force
}

Write-Host "`nCleanup complete." -ForegroundColor Green
