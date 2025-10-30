#!/snap/bin/powershell -Command
# Ansible managed
param(
	[parameter(Mandatory=$false)][string]$ClickHost = "localhost",
	[parameter(Mandatory=$false)][int]$ClickPort = 9000,
	[parameter(Mandatory=$false)][bool]$Secure = $false,
	[parameter(Mandatory=$false)][string]$ClickUser,
	[parameter(Mandatory=$false)][string]$ClickPassword,
	[parameter(Mandatory=$false)][string]$Database,
	[parameter(Mandatory=$false)][string]$BackupDisk,
	[parameter(Mandatory=$false)][string]$SubFolder,
	[parameter(Mandatory=$false)][string]$Settings
)

$ErrorActionPreference = "Stop"

$start = Get-Date

try
{
	$date = [DateTime]::UtcNow
	if ($Settings) {
		$backupSettings = "SETTINGS $Settings";
	}
	$folder = "$($date.ToString('yyyy-MM-dd_HH-mm_ss.fff'))/"

	if ($SubFolder) {
		$folder = "$SubFolder/$folder"
	}

	Write-Host "Backing up $Database into $BackupDisk/$folder"

	$Query =
@"
BACKUP DATABASE $Database TO Disk('$BackupDisk', '$folder')
$backupSettings;
"@

	/usr/local/bin/Invoke-ClickSQL.ps1 `
		-Query $Query `
		-ClickHost $ClickHost `
		-ClickPort $ClickPort `
		-Secure $Secure `
		-ClickUser $ClickUser `
		-ClickPassword $ClickPassword

	Write-Host -ForegroundColor Green "Backed up successfully $Database into $BackupDisk/$folder"
}
catch {
	throw
}
finally {
	Write-Host "Took: " ((Get-Date) - $start)
}
