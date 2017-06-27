if(-not (Get-Module awp)) {
  $here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\unit\functions', '')
  Import-Module (Join-Path $here 'awp.psd1') 
}

InModuleScope awp {
    Describe 'Test-AWPPreReq' {
        Mock New-CimInstance { }

        Context 'General Tests' {
            Mock Get-CimInstance { 
                [PSCustomObject]@{
                    version = [version]8.1
                }
            } -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' }

            Mock Invoke-Command {
                [psCustomObject]@{
                    release = 394802
                }
            }

            It 'Parameter Tests' {
                { Test-AWPPreReq } | Should Not Throw
                { Test-AWPPreReq -cred } | Should throw
            }
        }
        Context 'AWP Agent PreReq Passes' {
            Mock Get-CimInstance { 
                [PSCustomObject]@{
                    version = [version]8.1
                }
            } -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' }

            Mock Invoke-Command {
                [psCustomObject]@{
                    release = 394802
                }
            }

            It '.net relase and OS version correct' { 
            (Test-AWPPreReq).preReqPass | Should Be $true
            }
        }

        Context 'AWP Agent PreReq Fails' {
            It '.net release incorrect' { 
                Mock Get-CimInstance { 
                    [PSCustomObject]@{
                        version = [version]6.1.0
                    }
                } -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' }

                Mock Invoke-Command {
                    [psCustomObject]@{
                        release = 10000
                    }
                }

            (Test-AWPPreReq).preReqPass | Should Be $false
            }

            It 'OS version incorrect' { 
                Mock Get-CimInstance { } -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' }

                Mock Invoke-Command {
                    [psCustomObject]@{
                        release = 394802
                    }
                }
        
            (Test-AWPPreReq).preReqPass | Should Be $false
            }
        }
    }
}