function Uninstall-AWP
{
    <#
        .Synopsis
            Un-installs an AWP agent on remote computers.
        .DESCRIPTION
            Un-installs an AWP agent on remote computers.
        .EXAMPLE
            Uninstall-AWP -computerName 'computer1', 'computer2' -Verbose
        .NOTES
            Written by Ben Taylor
            Version 1.0, 18.11.2016
    #>
	[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
	[OutputType()]
	Param (
		[Parameter(Mandatory = $false, ValueFromPipeline=$True, valuefrompipelinebypropertyname=$true,  Position=0)]
		[ValidateNotNullOrEmpty()]
		[Alias('IPAddress', 'Name')]
		[string[]]
		$computerName = $env:COMPUTERNAME,
		[Parameter()]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential
	)

	Begin
	{
		$commonSessionParams = @{
			ErrorAction = 'Stop'
		}

		If ($PSBoundParameters['Credential'])
		{
			$commonSessionParams.Credential = $Credential
		}
	}
	Process
	{
		forEach ($computer in $computerName)
		{
			$commonSessionParams.Computer = $computer

			try
			{
				Write-Verbose "[$(Get-Date -Format G)] - $computer - Creating Remote PS Session"
				$psSession = New-PSSession @commonSessionParams

				Write-Verbose "[$(Get-Date -Format G)] - $computer - Checking if OMS is Installed"
				$awpInstall = Test-AWPInstall @commonSessionParams

				if($awpInstall.isInstalled -eq $true)
				{
					Write-Verbose "[$(Get-Date -Format G)] - $computer - OMS is installed so will try to uninstall"
					If ($Pscmdlet.ShouldProcess($computer, 'Uninstall OMS Agent'))
					{
						Invoke-Command -Session $psSession -ScriptBlock {
							$uninstallExe = ($USING:awpInstall.uninstallString).ToLower().Replace('"', '').Replace("/uninstall", "").trim()

							Start-Process $uninstallExe -ArgumentList '/uninstall /quiet' -Wait
						} -ErrorAction Stop

						$awpInstallStatus = Test-AWPInstall @commonSessionParams

						if($awpInstallStatus.isInstalled -eq $false)
						{
							Write-Verbose "[$(Get-Date -Format G)] - $computer - OMS uninstalled correctly"
						}
						else
						{
							Write-Error "[$(Get-Date -Format G)] - $computer - OMS didn't uninstall correctly based registry check"
						}
					}
				}
				else
				{
					Write-Verbose "[$(Get-Date -Format G)] - $computer - OMS not installed so skipping uninstall process"
				}
			}
			catch
			{
				Write-Error $_
			}
			finally
			{
				if($null -ne $psSession)
				{
					Write-Verbose "[$(Get-Date -Format G)] - $computer - Closing Remote PS Session"
					Remove-PSSession $psSession -WhatIf:$false -Confirm:$false
				}
			}
		}
	}
}