Add-Type -AssemblyName System.Windows.Forms
# $Win32ShowWindowAsync = Add-Type –memberDefinition @”
# [DllImport("user32.dll")]
# public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
# “@ -name “Win32ShowWindowAsync” -namespace Win32Functions –passThru

Add-Type @”
using System;
using System.Runtime.InteropServices;
public class Windower {

    [DllImport("user32.dll")] 
    public static extern IntPtr GetWindow(IntPtr hWnd, GetWindowType uCmd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    public enum GetWindowType : uint
    {
         GW_HWNDFIRST = 0,
         GW_HWNDLAST = 1,
         GW_HWNDNEXT = 2,
         GW_HWNDPREV = 3,
         GW_OWNER = 4,
         GW_CHILD = 5,
         GW_ENABLEDPOPUP = 6
    }
}
“@

try {
    $remote = Start-Job -ScriptBlock {ruby -W0 "D:\code\ruby\remote_control\remote.rb"}
    while ($remote.ChildJobs.Error.Length -le 0) { }#Start-Sleep -Milliseconds 100 }
    $image_location = $remote.ChildJobs.error[0].ToString()
    $image = [Drawing.Image]::FromFile( (Get-Item $image_location) )
    $picturebox = [System.Windows.Forms.PictureBox]::new()
    $picturebox.Size = $image.Size
    $picturebox.Image = $image
    $picturebox.location = '20,150'


    $form = New-Object System.Windows.Forms.Form

    $form.ClientSize         = '500,510'
    $form.text               = "Запускатель бананов"

    $label = New-Object System.Windows.Forms.Label
    $label.Text = 'Бананы будут запущены вскоре'
    $label.autosize = $true
    $label.location = '20,115'

    $form.controls.Add($label)
    $form.controls.Add($picturebox)

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 100
    $timer.Add_Tick({
#         $wid = ($Script:banana | Get-Process).MainWindowHandle
        $wid = $Script:banana.MainWindowHandle
        $pop_wid = [Windower]::GetWindow($wid, 6)
        if ([Windower]::IsWindowVisible($wid)) {
            $null = [Windower]::ShowWindowAsync($wid, 0)
        }
        if ([Windower]::IsWindowVisible($pop_wid)) {
            $null = [Windower]::ShowWindowAsync($pop_wid, 0)
            $script:timer.stop()
        }
    })

    $initial_device = Get-AudioDevice -Playback
    $new_device = Set-AudioDevice -ID '{0.0.0.00000000}.{de733fd6-06a8-475c-9a83-0d2d6afdb389}' -DefaultOnly

    $banana = Start-Process "C:\Program Files (x86)\VB\Voicemeeter\voicemeeterpro.exe" -PassThru
    $timer.Start()

    $label.text = 'Банана запущена и спрятана', "`r`n", 'Звук переключён на ', $new_device.Name, "`r`n`r`n", 'Закрой меня чтобы вернуть всё взад' -join ''
    [void]$form.ShowDialog()
}
finally {
    Stop-Process $banana.Id
    $null = Set-AudioDevice -InputObject $initial_device -DefaultOnly
    $form.Dispose()
    $timer.Dispose()
    Stop-Job $remote
    Remove-Job $remote
}
