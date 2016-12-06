class AWPInstall
{
    [string]   $computerName
    [string]   $uninstallString
    [bool]     $isInstalled = $false
    [version]  $version
    [datetime] $LogTime = (Get-Date)

    #Constructor Overload All Values
    AWPInstall (
        [string]  $computerName,
        [string]  $uninstallString,
        [version] $version
    ){
        $this.computerName    = $computerName
        $this.uninstallString = $uninstallString
        $this.Version         = $version

        $this.setIsInstalled()
    }

    [void] setIsInstalled()
    {
        if($this.uninstallString -and $this.version)
        {
            $this.isInstalled = $true
        }
    }

    [void] setLogTime()
    {
        $this.LogTime = Get-Date
    }
}