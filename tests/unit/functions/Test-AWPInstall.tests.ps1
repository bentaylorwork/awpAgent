if(-not (Get-Module awp)) {
  $here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\unit\functions', '')
  Import-Module (Join-Path $here 'awp.psd1') 
}

InModuleScope awp {
    Describe 'Test-AWPInstall' {
        Mock New-PSSession { }

        Context 'General Tests' {
            Mock Invoke-Command {
                @{
                    UninstallString  = '{23478236378hjdfgsdfg78dftsd}'
                    DisplayVersion = '6.76.5'
                }
            }

            It 'Parameter Tests' {
                { Test-AWPInstall } | Should Not Throw
                { Test-AWPInstall -cred } | Should throw
            }
        }
        Context 'AWP Agent Installed' {
            Mock Invoke-Command {
                @{
                    UninstallString = '/x {23478236378hjdfgsdfg78dftsd}'
                    DisplayVersion = '6.76.5'
                }
            }

            It 'Un-Install string and DisplayVersion exists' { 
            (Test-AWPInstall).isInstalled | Should Be $true
            }
        }

        Context 'AWP Agent Not Installed' { 
            Mock Invoke-Command { }

            It 'Un-Install string and DisplayVersion does not exists' { 
            (Test-AWPInstall).isInstalled | Should Be $false
            }
        }
    }
}