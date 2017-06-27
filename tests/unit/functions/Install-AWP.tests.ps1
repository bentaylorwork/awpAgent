if(-not (Get-Module awp)) {
  $here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\unit\functions', '')
  Import-Module (Join-Path $here 'awp.psd1') 
}

InModuleScope awp {
    Describe 'Install-AWP' {
        $testPath = "TestDrive:\awpInstall.exe"
        Set-Content $testPath -value "awpInstLLER"

        BeforeEach {
            Mock Copy-Item { $null }
        }

        Context 'General Tests' {
            It 'Parameter Tests' {
                Mock Test-AWPInstall {}
                Mock Invoke-Command { }

                { Install-AWP -path "$TestDrive\awpInstall.exe" } | Should Not Throw
                { Install-AWP -path "$TestDrive\awpInstall.exe" -cred } | Should throw
            }
        }

        Context 'Is Invoke-Command Called Correctly' {
            it 'When AWP agent is not installed' {
                Mock Test-AWPInstall {
                    @{
                        isInstalled = $false
                    }
                }

                Mock Invoke-Command { "$TestDrive\awpInstall.exe" }

                Install-AWP -path "$TestDrive\awpInstall.exe" | Out-Null

                Assert-MockCalled -CommandName Invoke-Command -Exactly 3 -Scope It
            }

            it 'When AWP agent is installed' {
                Mock Test-AWPInstall {
                    @{
                        isInstalled = $true
                    }
                }

                Mock Start-Process {}

                Install-AWP -path "$TestDrive\awpInstall.exe" | Out-Null

                Assert-MockCalled -CommandName Start-Process -Exactly 0 -Scope It
            }
        }
    }
}