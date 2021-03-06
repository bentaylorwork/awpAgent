﻿$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace('tests\lint', '')
$scriptsModules = Get-ChildItem $here -Include *.psd1, *.psm1, *.ps1 -Exclude *.tests.ps1 -Recurse

Describe "Enviroment - Testing there is something to test and CMDLETS available." {
	Context "Checking files to test exist and Invoke-ScriptAnalyzer cmdLet is available" {
		It "Checking files exist to test." {
			$scriptsModules.count | Should Not Be 0
		}
		It "Checking Invoke-ScriptAnalyzer exists." {
			{ Get-Command Invoke-ScriptAnalyzer -ErrorAction Stop } | Should Not Throw
		}
	}
}

Describe "Script\Module  - Testing all scripts and modules" {
	$scriptAnalyzerRules = Get-ScriptAnalyzerRule

	forEach ($scriptModule in $scriptsModules) {
		switch -wildCard ($scriptModule) { 
			'*.psm1' { $typeTesting = 'Module' } 
			'*.ps1'  { $typeTesting = 'Script' } 
			'*.psd1' { $typeTesting = 'Manifest' } 
		}

		Context "Checking $typeTesting – $($scriptModule) - conforms to Script Analyzer Rules" {
			forEach ($scriptAnalyzerRule in $scriptAnalyzerRules) {
				It "Script Analyzer Rule $scriptAnalyzerRule" {
					(Invoke-ScriptAnalyzer -Path $scriptModule -IncludeRule $scriptAnalyzerRule).count | Should Be 0
				}
			}
		}
	}
}
