# PowerShell скрипт: получить скриншот экрана пользователя и сохранить в PNG файл 
# подробности https://winitpro.ru/index.php/2020/02/10/powershell-poluchit-skrinshot-rabochego-stola-polzovatelya/

$Path = "C:\ps\screenshots"
# Проверяем, что каталог для хранения скриншотов создан, если нет - создаем его
If (!(test-path $path)) {
New-Item -ItemType Directory -Force -Path $path
}
Add-Type -AssemblyName System.Windows.Forms
$screen = [Windows.Forms.SystemInformation]::VirtualScreen 
# Получаем разрешение экрана
$image = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
# Создаем графический объект
$graphic = [System.Drawing.Graphics]::FromImage($image)
$point = New-Object System.Drawing.Point(0, 0)
$graphic.CopyFromScreen($point, $point, $image.Size);
$cursorBounds = New-Object System.Drawing.Rectangle([System.Windows.Forms.Cursor]::Position, [System.Windows.Forms.Cursor]::Current.Size)
# Получаем скриншот экрана 
[System.Windows.Forms.Cursors]::Default.Draw($graphic, $cursorBounds)

$screen_file = "$Path\" + $env:computername + "_" + $env:username + "_" + "$((get-date).tostring('yyyy.MM.dd-HH.mm.ss')).png"
# Сохранить скриншот в PNG файл 
$image.Save($screen_file, [System.Drawing.Imaging.ImageFormat]::Png)
# Очистка памяти 
$graphic.Dispose() 
$image.Dispose() 


