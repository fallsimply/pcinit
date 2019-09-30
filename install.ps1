$location = Get-Location
$installDir = "$env:USERPROFILE\AppData\Local"

#region URLs
$goUrl = "https://dl.google.com/go/go1.13.windows-amd64.zip"
$codeUrl = "https://aka.ms/win32-x64-user-stable"
$pwshUrl = "https://github.com/PowerShell/PowerShell/releases/download/v6.2.3/PowerShell-6.2.3-win-arm64.zip"
$mingwUrl = "https://nuwen.net/files/mingw/mingw-16.1-without-git.exe"
#endregion

#region Choice Setup
$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes'
$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$pwsh = $host.ui.PromptForChoice("", "Install Powershell Core (pwsh)", $options, 0)
if ($pwsh -eq 0 ) { $pwshcm = $host.ui.PromptForChoice("", "Add Powershell Core to the context Menu", $options, 0) }
$go = $host.ui.PromptForChoice("", "Install Go", $options, 0)
$code = $host.ui.PromptForChoice("", "Install VS Code", $options, 1)
$mingw = $host.ui.PromptForChoice("", "Install MinGW (GCC)", $options, 0)
#endregion

#region Helpers
function AddToStart($item, $expath = "$location\$item\bin\$item.exe" ) {
	$WshShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\$item.lnk")
	$Shortcut.TargetPath = "$installDir\$expath"
	$Shortcut.Save()
}
function AddToPath($item) {
	if (Test-Path "$installDir\$item\bin") {
		$env:Path += ";$installDir\bin" 
	}
}
#endregion

#region Install Functions
function Download($item, $url, $ext = "zip") {
	Write-Host "[$item]: Download Started"
	Invoke-WebRequest -Uri $URL -OutFile "$location\apps\$item.$ext"
	Write-Host "[$item]: Downloaded"
}
function Install($item) {
	Write-Host "[$item]: Install Started"
	Expand-Archive -Path "$location\apps\$item.zip" -DestinationPath "$installDir\$item"
	AddToPath($item)
	Write-Host "[$item]: Installed"
}
function InstallExe($item, $exArgs = @()) {
	Write-Host "[$item]: Install Started"
	& "$location\apps\$item.exe" $exArgs
	Write-Host "[$item]: Installed"
}
#endregion

New-Item -ItemType Directory -Force -Path "$location\apps" | Out-Null

if ($pwsh -eq 0) {
	Write-Host "`nPowershell Core"
	if (-Not(Test-Path "$location\apps\pwsh.zip")) {
		Download -item "pwsh" -url $pwshurl
	}
	Install -item "pwsh"
	AddToStart "pwsh" "$installDir/pwsh.exe"
}

if ($go -eq 0) {
	Write-Host "`nGo"
	if (-Not (Test-Path "$location\apps\go.zip")) {
		Download -item "go" -url $gourl
	}
	Install -item "go"
}

if ($code -eq 0) {
	Write-Host "`nVSCode"
	if (-Not (Test-Path "$location\apps\code.exe")) {
		Download -item "code" -url $codeurl -ext exe
	}
	InstallExe "code"
}

if ($mingw -eq 0) {
	Write-Host "`nMinGW GCC"
	if (-Not (Test-Path "$location\apps\gcc.exe")) {
		Download -item "mingw" -url $mingwUrl -ext exe
	}
	InstallExe "mingw" @("-O$($installDir)mingw\", "-y")
	AddToPath "mingw"
}