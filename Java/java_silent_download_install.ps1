# PowerShell скрипт для автоматической загрузки и установки последней версии  Java SE (JRE) на компьютере
# Подробности в статье на https://winitpro.ru/

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# скачать онлайн установщик Java
$URL = (Invoke-WebRequest -UseBasicParsing https://www.java.com/en/download/manual.jsp).Content | % { [regex]::matches($_, '(?:<a title="Download Java software for Windows Online" href=")(.*)(?:">)').Groups[1].Value }

# скачать офлайн установщик Java
#$URL = (Invoke-WebRequest -UseBasicParsing https://www.java.com/en/download/manual.jsp).Content | % { [regex]::matches($_, '(?:<a title="Download Java software for Windows Offline" href=")(.*)(?:">)').Groups[1].Value }

Invoke-WebRequest -UseBasicParsing -OutFile jre8.exe $URL
Start-Process .\jre8.exe '/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0' -wait
echo $?



