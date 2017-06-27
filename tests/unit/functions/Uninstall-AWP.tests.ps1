if(-not (Get-Module awp)) {
  $here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\unit\functions', '')
  Import-Module (Join-Path $here 'awp.psd1') 
}

InModuleScope awp {
    Describe 'Uninstall-AWP' {
        BeforeEach {
            Mock Invoke-Command {}
        }

        Context 'General Tests' {
            It 'Parameter Tests' {
                Mock Test-AWPInstall {}

                { Uninstall-AWP } | Should Not Throw
                { Uninstall-AWP -cred } | Should throw
            }
        }

        Context 'Is Invoke-Command Called Correctly' {
            it 'When AWP agent is not installed' {
                Mock Test-AWPInstall {
                    @{
                        isInstalled = $false
                    }
                }

                UnInstall-AWP | Out-Null

                Assert-MockCalled -CommandName Invoke-Command -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Test-AWPInstall -Exactly 1 -Scope It
            }

            it 'When AWP agent is installed' {
                $script:i = 1

                Mock Test-AWPInstall {
                    if ($script:i -ge 2)
                    {
                        @{
                            isInstalled = $false
                        }
                    }
                    else
                    {
                        @{
                            isInstalled = $true
                        }
                    }

                    $script:i++
                }

                UnInstall-AWP | Out-Null

                Assert-MockCalled -CommandName Invoke-Command -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Test-AWPInstall -Exactly 2 -Scope It
            }
        }
    }
}