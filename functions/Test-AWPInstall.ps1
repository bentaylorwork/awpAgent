function Test-AWPInstall
{
    <#
        .Synopsis
            Checks a computer to see if the Autotask WorkPlace Agent is installed.
        .DESCRIPTION
            Checks a computer to see if the Autotask WorkPlace Agent is installed. It looks for the uninstall registry key.
        .EXAMPLE
            Test-AWPInstall -computerName 'computerOne', 'computerTwo'
        .EXAMPLE
            'computerOne', 'computerTwo' | Test-AWPInstall -credential Get-Credential
        .NOTES
			Written by Ben Taylor
			Version 1.0, 17.11.2016

            Maybe should have been a OVT pester test
    #>
    [CmdletBinding()]
    [OutputType('AWPPreReq')]
    Param
    (
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $computerName = $env:COMPUTERNAME,
		[Parameter(Mandatory = $false, Position = 1)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential
    )

    Begin
    {
		$sessionCommonParams = @{
			ErrorAction = 'Stop'
		}

		If ($PSBoundParameters['Credential'])
        {
			$sessionCommonParams.Credential = $Credential
		}
    }
    Process
    {
        foreach($computer in $computerName)
        {
            try
            {
				$sessionCommonParams.ComputerName = $computer

                $soonRAgent = Invoke-Command @sessionCommonParams -scriptBlock {
                    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.displayName -eq 'Soonr Desktop Agent' -and $_.Installed }
                }

                [AWPInstall]::new($computer, $soonRAgent.UninstallString , $soonRAgent.DisplayVersion)
            }
            catch
            {
				Write-Error "$computer - $_"
            }
        }
    }
}