# PowerShell скрипт для поиска и удаления старых версий драйверов в хранилище драйверов Windows
# При обновлении драйвера Windows сохраняет старую версию и со временем размер хранилища драйверов сильно увеличивается
# https://winitpro.ru/index.php/2017/02/03/udalenie-staryx-versij-drajverov-iz-xranilishha-windows/

$dismOut = dism /online /get-drivers
$Lines = $dismOut | select -Skip 10
$Operation = "theName"
$Drivers = @()
foreach ( $Line in $Lines ) {
    $tmp = $Line
    $txt = $($tmp.Split( ':' ))[1]
    switch ($Operation) {
        'theName' { $Name = $txt
                     $Operation = 'theFileName'
                     break
                   }
        'theFileName' { $FileName = $txt.Trim()
                         $Operation = 'theEntr'
                         break
                       }
        'theEntr' { $Entr = $txt.Trim()
                     $Operation = 'theClassName'
                     break
                   }
        'theClassName' { $ClassName = $txt.Trim()
                          $Operation = 'theVendor'
                          break
                        }
        'theVendor' { $Vendor = $txt.Trim()
                       $Operation = 'theDate'
                       break
                     }
        'theDate' { # change the date format for easy sorting
                     $tmp = $txt.split( '.' )
                     $txt = "$($tmp[2]).$($tmp[1]).$($tmp[0].Trim())"
                     $Date = $txt
                     $Operation = 'theVersion'
                     break
                   }
        'theVersion' { $Version = $txt.Trim()
                        $Operation = 'theNull'
                        $params = [ordered]@{ 'FileName' = $FileName
                                              'Vendor' = $Vendor
                                              'Date' = $Date
                                              'Name' = $Name
                                              'ClassName' = $ClassName
                                              'Version' = $Version
                                              'Entr' = $Entr
                                            }
                        $obj = New-Object -TypeName PSObject -Property $params
                        $Drivers += $obj
                        break
                      }
         'theNull' { $Operation = 'theName'
                      break
                     }
    }
}
$last = ''
$NotUnique = @()
foreach ( $Dr in $($Drivers | sort Filename) ) {
    if ($Dr.FileName -eq $last  ) {  $NotUnique += $Dr  }
    $last = $Dr.FileName
}
$NotUnique | sort FileName | ft
# looking for duplicated driver 
$list = $NotUnique | select -ExpandProperty FileName -Unique
$ToDel = @()
foreach ( $Dr in $list ) {
    Write-Host "duplicate driver found" -ForegroundColor Yellow
    $sel = $Drivers | where { $_.FileName -eq $Dr } | sort date -Descending | select -Skip 1
    $sel | ft
    $ToDel += $sel
}
Write-Host "List of driver version  to remove" -ForegroundColor Red
$ToDel | ft
# removing old drivers
foreach ( $item in $ToDel ) {
    $Name = $($item.Name).Trim()
    Write-Host "deleting $Name" -ForegroundColor Yellow
   # Write-Host "pnputil.exe /remove-device  $Name" -ForegroundColor Yellow
   # Invoke-Expression -Command "pnputil.exe -d $Name"
}
