<#
    .SYNOPSIS
    This script will attempt to uninstall Cubase 14.0.20 and dependacies.
    It will then delete all vst files from "C:\ProgramData"
#>

Start-Transcript -Path "$env:temp\Transcript.txt" -Force

# Cubase 14.0.10 installations
$Installations = @(
    [PSCustomObject]@{Product = '{9B51C20E-93B6-4825-9848-858A0957246C}'; Name = 'Steinberg Cubase 14'; Version = '14.0.20'},
    [PSCustomObject]@{Product = '{DE26CB00-5D4F-40B4-BEF5-5FBFDC7DCA52}'; Name = 'Steinberg built-in ASIO Driver 64bit'; Version = '1.0.9'},
    [PSCustomObject]@{Product = '{3A97C8A6-8CC0-4AF2-B32B-DD0334338580}'; Name = 'Steinberg Groove Agent 5'; Version = '5.2.20'},
    [PSCustomObject]@{Product = '{69043884-EB60-4C9A-9C41-3303C319E1A8}'; Name = 'Steinberg HALion Sonic 7'; Version = '7.1.30'},
    [PSCustomObject]@{Product = '{AA78592A-F13C-4C8E-B849-7A398001FA7F}'; Name = 'Steinberg Library Manager'; Version = '3.2.50'},
    [PSCustomObject]@{Product = '{9529D195-8127-42F5-BA54-8D862E941920}'; Name = 'Steinberg MediaBay '; Version = '1.2.40'},
    [PSCustomObject]@{Product = '{0224CA8C-FD43-4397-94CE-319B9471016A}'; Name = 'Steinberg Activation Manager'; Version = '1.6.0'}
)

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'

#$MsiArgs = "/x `"$ProdID`" /qn"
$AllExit = 0

# Uninstall each installation with MSIEXEC.
foreach ($Install in $Installations) {
    $RegKey = [System.IO.Path]::Combine($RegPath, $Install.Product)
    if (Test-Path -Path $RegKey -PathType Container) {
        Write-Host "MSI Product ID found in Registry"
        $DisplayVersion = (Get-ItemProperty -Path $RegKey -Name DisplayVersion).DisplayVersion
        if ($DisplayVersion -eq $Install.Version) {
            Write-Host "Version matches MSI Product ID"
            $Proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($Install.Product) /qn" -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
            $ProcExit = $Proc.ExitCode
            if ($null -eq $ProcExit -or $ProcExit -ne 0) {
                Write-Warning "Failed to uninstall `"$($Install.Name)`" `"$($DisplayVersion)`" with exit code: $ProcExit"
                $AllExit += $ProcExit
            }
        }
    }
}

if ($null -eq $AllExit -or $AllExit -gt 0) {
    Write-Warning "An Error has occured uninstalling one or more components."
    Exit 1
}

<#
    Delete C:\ProgramData\Steinberg
#>

$VstFiles = 'C:\ProgramData\Steinberg'

if (Test-Path -Path $VstFiles -PathType Container) {
    Remove-Item -Path $VstFiles -Recurse -Force	
}

Stop-Transcript