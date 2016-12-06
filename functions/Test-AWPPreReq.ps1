function Test-AWPPreReq
{
    <#
        .Synopsis
            Checks a computer has the Pre-Reqs to install the Autotask WorkPlace Agent.
        .DESCRIPTION
            Checks a computer has the Pre-Reqs to install the Autotask WorkPlace Agent. Looks at Windows Version and .Net framework version.
        .EXAMPLE
            Test-AutoTaskWorkPlacePreReq -computerName 'computerOne', 'computerTwo'
        .EXAMPLE
            'computerOne', 'computerTwo' | Test-AutoTaskWorkPlacePreReq -credential Get-Credential
        .NOTES
			Written by Ben Taylor
			Version 1.0, 17.11.2016

            Maybe should have been a OVT pester test
    #>
    [CmdletBinding(SupportsShouldProcess)]
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
		$cimCommonParams = @{
			ErrorAction = 'Stop'
		}

		If ($PSBoundParameters['Credential'])
        {
			$cimCommonParams.Credential = $Credential
		}
    }
    Process
    {
        foreach($computer in $computerName)
        {
            try
            {
				$cimCommonParams.ComputerName = $computer

                $dotNetRelease = Invoke-Command @cimCommonParams -scriptBlock {
                    Get-ItemProperty -Path 'HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full'
                }
                
                Write-Verbose 'Getting connection protocol'
                try
                {
					Test-WSMan @cimCommonParams | Out-Null
					$ProtocolAuto = 'WsMan'
				}
                catch
                {
					$ProtocolAuto = 'DCOM'
				}

				$cimSession = New-CimSession @cimCommonParams -SessionOption (New-CimSessionOption -Protocol $ProtocolAuto)      
                $osVersion = Get-CimInstance Win32_OperatingSystem -CimSession $cimSession -ErrorAction Stop | Select-Object -ExpandProperty Version

                [AWPPreReq]::new($computer, ($dotNetRelease | Select-Object -ExpandProperty Release), $osVersion)
            }
            catch
            {
				Write-Error "$computer - $_"
            }
            finally
            {
				if($null -ne $cimSession)
                {
					Remove-CimSession $cimSession -ErrorAction SilentlyContinue
				}

            }
        }
    }
}