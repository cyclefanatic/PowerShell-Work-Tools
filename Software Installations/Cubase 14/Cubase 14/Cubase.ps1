\<#
	.SYNOPSIS
    Installs the main Cubase application after all the dependancies and extra applications are isntalls. It also imports VST sound files using Library Mnagaer.

    Dependancies:
    Steinberg Activation Manager
    Steinberg Library Manager
    Steinberg MediaBay

    
	
#>



<#
	Copy VST files with Steinberg Library Manager
#>

$SLMPath = "$PSScriptRoot\Library Manager\Steinberg Library Manager.exe"
$VSTSound = "#"
$ArgList = "$VSTSound -unattended -hide -supportold -copyto configured -progressFile $env:tmp\slm-progress.log"

$VSTCopy = Start-Process -FilePath $SLMPath -ArgumentList $ArgList -Wait -PassThru -ErrorAction SilentlyContinue

$VSTExitCode = $VSTCopy.InstallExitCode
# Check if MSI installation succeeded
if ($VSTExitCode -ne 0 -and $VSTExitCode -ne $null) {
    Write-Host "VST copy failed with exit code: $InstallExitCode"
    Exit $VSTExitCode
}



<#
	Install Cubase
#>

# UPdate the following with the MSI file name.
$MsiFile = "Cubase14.msi"

$MsiPath = $PSScriptRoot + "\" + $MsiFile
$MsiArgs = "/i `"$MsiPath`" ALLUSERS=1 /qn"

# Check if install file exists
if (-not (Test-Path -Path $MsiPath -PathType Leaf)) {
    Write-Host "installation file not found: $$MsiPath"
    Exit 1
}

Write-Host "Preparing installation: `"Start-Process -FilePath `"msiexec.exe`" -ArgumentList $MsiArgs -Wait -passthru`""

$install = Start-Process -FilePath "msiexec.exe" -ArgumentList $MsiArgs -Wait -passthru -ErrorAction SilentlyContinue

$InstallExitCode = $install.InstallExitCode
# Check if MSI installation succeeded
if ($InstallExitCode -ne 0 -and $InstallExitCode -ne $null) {
    Write-Host "MSI installation failed with exit code: $InstallExitCode"
    Exit $InstallExitCode
} else {
	exit 0
}