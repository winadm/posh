
<#
.SYNOPSIS
    Поиск потерянных (orphaned) MSI/MSP файлов в C:\Windows\Installer.
    Более подробное описание здесь: https://winitpro.ru/index.php/2026/10/01/ochistka-windows-installer/
    
.DESCRIPTION
    Скрипт подключается напрямую к Windows Installer через COM API и
    собирает список всех зарегистрированных кешированных пакетов:
        - MSI продуктов через ProductInfo(..., 'LocalPackage')
        - MSP патчей через PatchInfo(..., 'LocalPackage')
    Затем скрипт проверяет файлы .MSI и .MSP в:
        C:\Windows\Installer

    Если файл физически существует в папке Installer, но его путь отсутствует
    среди зарегистрированных LocalPackage, он считается потенциально orphaned.

    Cкрипт работает только в режиме сканирования.

.NOTES
    Требуются права администратора.

    ВАЖНО:
    C:\Windows\Installer является системной папкой Windows Installer.
    Не удаляйте файлы без предварительной проверки отчёта.
#>

#Requires -RunAsAdministrator



#Requires -RunAsAdministrator

$InstallerPath = "$env:WINDIR\Installer"

Write-Host "Подключение к Windows Installer..." -ForegroundColor Cyan
$Installer = New-Object -ComObject WindowsInstaller.Installer

# 1. Собираем все зарегистрированные пакеты (MSI + MSP) через COM API
Write-Host "Сканирование продуктов..." -ForegroundColor Cyan
$Products = @($Installer.Products())

$registeredPaths = @{}

foreach ($ProductCode in $Products) {
    try {
        $path = $Installer.ProductInfo($ProductCode, 'LocalPackage')
        if ($path -and (Test-Path $path)) {
            $registeredPaths[$path.ToLower()] = $true
        }
    } catch {}
    
    # Патчи (MSP) для каждого продукта
    try {
        $patches = @($Installer.Patches($ProductCode))
        foreach ($PatchCode in $patches) {
            try {
                $path = $Installer.PatchInfo($PatchCode, 'LocalPackage')
                if ($path -and (Test-Path $path)) {
                    $registeredPaths[$path.ToLower()] = $true
                }
            } catch {}
        }
    } catch {}
}

Write-Host "Зарегистрировано пакетов: $($registeredPaths.Count)" -ForegroundColor Green

# 2. Все файлы в папке Installer
Write-Host "`nСканирование папки $InstallerPath..." -ForegroundColor Cyan
$allFiles = Get-ChildItem -Path $InstallerPath -File -Force -ErrorAction SilentlyContinue

# 3. Потерянные файлы
$orphaned = $allFiles | Where-Object {
    $ext = $_.Extension.ToLower()
    $ext -in @('.msi', '.msp') -and $registeredPaths.Keys -notcontains $_.FullName.ToLower()
}

if ($orphaned) {
    Write-Host "`nПотерянных файлов: $($orphaned.Count)" -ForegroundColor Yellow
    
    $report = $orphaned | ForEach-Object {
        $file = $_
        $subject = ''
        $author = ''
        
        try {
            $db = $Installer.OpenDatabase($file.FullName, 0)
            $view = $db.OpenView("SELECT Value FROM Property WHERE Property = 'ProductName'")
            $view.Execute()
            $rec = $view.Fetch()
            if ($rec) { $subject = $rec.StringData(1) }
            
            $view = $db.OpenView("SELECT Value FROM Property WHERE Property = 'Manufacturer'")
            $view.Execute()
            $rec = $view.Fetch()
            if ($rec) { $author = $rec.StringData(1) }
        } catch {
            $subject = 'N/A'
            $author = 'N/A'
        }
        
        [PSCustomObject]@{
            Path     = $file.FullName
            SizeMB   = [math]::Round($file.Length / 1MB, 2)
            Subject  = $subject
            Author   = $author
            Modified = $file.LastWriteTime
        }
    }
    
    $report | Format-Table -AutoSize -Wrap
    $totalMB = [math]::Round(($orphaned | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    Write-Host "`nВсего: $totalMB MB" -ForegroundColor Magenta
} else {
    Write-Host "`nПотерянных файлов не найдено." -ForegroundColor Green
}
