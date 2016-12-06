# Auto Task Workplace Agent Management

## Overview
A powershell module to aide with deployment and management of Auto Task Workplace Agents.

## Requirements
- PowerShell Version 5.0

## Commands
* Install-AWP
* Uninstall-AWP
* Test-AWPInstall
* Test-AWPPreReq

## Examples

```PowerShell
# Example - Install-AWP
Install-AWP -computername 'computer-one', 'computer-two' -path '<path to installer>' -credential Get-Credential -verbose

# Example - Test-AWPInstall
Test-AWPInstall -computername 'computer-one', 'computer-two'

# Example - Uninstall-AWP
Uninstall-AWP -computername 'computer-one', 'computer-two' -verbose

# Example - Test-AWPPreReq
Test-AWPPreReq -computername 'computer-one', 'computer-two'
```

##

## Contributors
- Ben Taylor