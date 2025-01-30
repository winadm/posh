# PowerShell скрипт: получить скриншот только активного приложения на экране пользователя и сохранить в PNG файл 
# подробности https://winitpro.ru/index.php/2020/02/10/powershell-poluchit-skrinshot-rabochego-stola-polzovatelya/

Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class User32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
    
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@

$hWnd = [User32]::GetForegroundWindow()

$rect = New-Object User32+RECT
[User32]::GetWindowRect($hWnd, [ref]$rect)
$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top

$image = New-Object System.Drawing.Bitmap($width, $height)

$graphic = [System.Drawing.Graphics]::FromImage($image)

$point = New-Object System.Drawing.Point($rect.Left, $rect.Top)
$graphic.CopyFromScreen($point, [System.Drawing.Point]::Empty, $image.Size)

$Path = "C:\ps\screenshots"
If (!(Test-Path $Path)) {
    New-Item -ItemType Directory -Force -Path $Path
}

$screenFile = "$Path\" + $env:computername + "_" + $env:username + "_" + "$((get-date).tostring('yyyy.MM.dd-HH.mm.ss')).png"

$image.Save($screenFile, [System.Drawing.Imaging.ImageFormat]::Png)

$graphic.Dispose()
$image.Dispose()

