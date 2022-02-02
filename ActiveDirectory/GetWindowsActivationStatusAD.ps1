# Скрипт для получения статуса активации Windows на всех компьютерах в Active Directory
# Подробности здесь: https://winitpro.ru/index.php/2015/08/17/proverka-statusa-aktivacii-windows-10/
enum Licensestatus{
    Unlicensed = 0
    Licensed = 1
    Out_Of_Box_Grace_Period = 2
    Out_Of_Tolerance_Grace_Period = 3
    Non_Genuine_Grace_Period = 4
    Notification = 5
    Extended_Grace = 6
}
$Report = @()
$complist = Get-ADComputer -Filter {enabled -eq "true" -and OperatingSystem -Like '*Windows*'}
Foreach ($comp in $complist) {
If ((Test-NetConnection $comp.name -WarningAction SilentlyContinue).PingSucceeded -eq $true){
    $activation_status= Get-CimInstance -ClassName SoftwareLicensingProduct -ComputerName $comp.name -Filter "Name like 'Windows%'" |where { $_.PartialProductKey } |  select PSComputerName, @{N=’LicenseStatus’; E={[LicenseStatus]$_.LicenseStatus}}
    $windowsversion= Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $comp.name| select Caption, Version
    $objReport = [PSCustomObject]@{
    ComputerName = $activation_status.PSComputerName
    LicenseStatus= $activation_status.LicenseStatus
    Version = $windowsversion.caption
    Build = $windowsversion.Version
    }
}
else {
    $objReport = [PSCustomObject]@{
     ComputerName = $comp.name
     LicenseStatus = "Offline"
      }
}
$Report += $objReport
}
$Report |Out-GridView 



