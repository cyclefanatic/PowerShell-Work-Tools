\<#
	.SYNOPSIS
	Install Steinberg Activation Manager and license the Cubase 14
	
#>



<#
	Install Activation Manager
#>

# UPdate the following with the MSI file name.
$MsiFile = "SteinbergActivationManager.msi"

$MsiPath = $PSScriptRoot + "\" + $MsiFile
$MsiArgs = "/i `"$MsiPath`" ALLUSERS=1 /qn"

# Check if install file exists
if (-not (Test-Path -Path $MsiPath -PathType Leaf)) {
    Write-Host "installation file not found: $$MsiPath"
    Exit 1
}

Write-Host "Preparing installation: `"Start-Process -FilePath `"msiexec.exe`" -ArgumentList $MsiArgs -Wait -passthru`""

$install = Start-Process -FilePath "msiexec.exe" -ArgumentList $MsiArgs -Wait -passthru -ErrorAction SilentlyContinue

# Check if MSI installation succeeded
$InstallExitCode = $install.InstallExitCode
if ($null -ne $InstallExitCode -and $InstallExitCode -ne 0 ) {
    Write-Output "MSI installation failed with exit code: $InstallExitCode"
    Exit $InstallExitCode
}



<#
    Check and install license file.
	
#>

# Get the path to the Steinberg License Engine
$SteinbergLicenseEnginePath = Resolve-Path -Path "$env:CommonProgramFiles\Steinberg\Activation Manager\SteinbergLicenseEngine.exe"
# Path to License files.
$LicPath = "#"
# Request files.
$ReqFile = "$($LicPath)\steinberg-license-$($env:COMPUTERNAME).smtgreq"
# Processed License files to be installed.
$LicFile = "$($LicPath)\steinberg-license-$($env:COMPUTERNAME).smtglic"
# Licence Log Path
$LicLogPath = "$env:CommonProgramFiles\Steinberg\Activation Manager"
$LicLogFile = "CubaseElements14.txt"

# First check if there is a licence file to install.
if (Test-Path -Path $LicFile -PathType leaf) {
	Write-Output "Installing licence file: $($LicFile)"
	& $SteinbergLicenseEnginePath --install-licenses $LicFile --force --allusers
	# Append log file - this will be used to confirm installation
	if (Test-Path -Path "$($LicLogPath)\$($LicLogFile)" -PathType leaf) {
		Add-Content -Path "$($LicLogPath)\$($LicLogFile)" -Value "$(Get-Date -Format "yyyyMMddHHmmss") - Cubase Elements 14 licence installed.`n"
	} else {
		New-Item -Path $LicLogPath -Name $LicLogFile -ItemType "file" -Value "Cubase Elements 14 licence requested.`n"
	}
} else {
	# Get the Steinberg Licensing hardware ID by invoking the license engine
	$HwId = & $SteinbergLicenseEnginePath --show-hardware-id
	Write-Output $HwId
	# Does the request file exist?
	if (!(Test-Path $ReqFile -PathType Leaf)) {
		# If it doesn't, generate the request file by invoking the license e
		& $SteinbergLicenseEnginePath --generate-license-request $ReqFile
		if (Test-Path $ReqFile -PathType Leaf) {
			New-Item -Path $LicLogPath -Name $LicLogFile -ItemType "file" -Value "$(Get-Date -Format "yyyyMMddHHmmss") - Cubase Elements 14 licence requested.`n"
		}
		exit 1
	} else {
		Write-Output "Requested licence not processed."
		exit 1
	}
}