#!/snap/bin/powershell -Command
# Ansible managed
param(
	[parameter(Mandatory=$true)][string]$File,
	[parameter(Mandatory=$false)][string]$ClickHost = "localhost",
	[parameter(Mandatory=$false)][int]$ClickPort = 9000,
	[parameter(Mandatory=$false)][bool]$Secure = $false,
	[parameter(Mandatory=$false)][string]$ClickUser,
	[parameter(Mandatory=$false)][string]$ClickPassword
)
$ErrorActionPreference = "Stop"
Write-Host "Executing against $($ClickHost):$ClickPort file $File"


$args = @()

$args += "--host", $ClickHost, "--port", $ClickPort
if ($Secure) {
	$args += "--secure"
}

if ($ClickUser) {
	$args += "--user", $ClickUser
	if ($ClickPassword) {
		$args += "--password", $ClickPassword
	}
}

$args += "$Query"

if ($ExtraArgs) {
	$args += $ExtraArgs
}

$args += "--queries-file=$File"

$tempfile = New-TemporaryFile

$result = &clickhouse-client @args 2>$tempfile

Get-Content $tempfile | Write-Host -ForegroundColor Red

if (0 -ne $LASTEXITCODE) {
	Write-Host $result

	throw "Failed to start: $LASTEXITCODE clickhouse-client"
}

return $result
