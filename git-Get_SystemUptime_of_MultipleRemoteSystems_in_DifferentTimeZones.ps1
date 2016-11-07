<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.127
	 Created on:   	10/7/2016 10:39 AM
	 Created by:   	Serge Nikalaichyk, Richard Smith, GSweet
	 Organization: 	Comment post on 4sysOps.com (Serge), Richard & GS
	 Filename:     	git-Get_SystemUptime_of_MultipleRemoteSystems_in_DifferentTimeZones.ps1
	===========================================================================
	.DESCRIPTION
		- Get system up time of multiple remote system in different time zones

	.WEBSITE 
		- https://4sysops.com/archives/calculating-system-uptime-with-powershell/ 
#>

# Function - Logging file
FUNCTION Logging($pingerror, $Computer, $UpTime)
{
	$outputfile = "\\FILE_SERVER\shares\UTILITY\log_GetSystemUptime.txt";
	
	$timestamp = (Get-Date).ToString();
	
	#$logstring = "Computer / Uptime: {0}, {1}" -f $Computer, $UpTime;
	$logstring = ($Server + "		" + $UpTime);
	#$logstring = ($UpTime);
	
	"$timestamp - $logstring" | out-file $outputfile -Append;
	
	if ($pingerror -eq $false)
	{
		Write-Host "$timestamp - $logstring";
	}
	else
	{
		Write-Host "$timestamp - $logstring" -foregroundcolor red;
	}
	return $null;
}

FUNCTION Get-UpTime
{
	[CmdletBinding()]
	param (
		[Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
		[Alias("CN")]
		[String]$ComputerName = $Env:ComputerName,
		[Parameter(Position = 1, Mandatory = $false)]
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	process
	{
		"{0} 	Uptime: {1:%d} Days {1:%h} Hours {1:%m} Minutes {1:%s} Seconds" -f $ComputerName,
		(New-TimeSpan -Seconds (Get-WmiObject Win32_PerfFormattedData_PerfOS_System -ComputerName $ComputerName -Credential $Credential).SystemUpTime)
	}
}

# Sets the Server Inclusion List from a Text File
$ServerList = Get-Content "\\FILE_SERVER\shares\UTILITY\targets_Uptime.txt"

ForEach ($Server in $ServerList)
{
# This function can be used in a pipeline
	$Uptime = $Server | Get-UpTime
	
# Dump results to logging function 
	Logging $False $Server $UpTime;
}