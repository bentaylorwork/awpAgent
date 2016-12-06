class AWPPreReq
{
    [string]   $computerName
    [int]      $dotNetFourFrameWorkRelease
    [version]  $dotNetFourFrameWorkVersion
    [version]  $osVersion
    [datetime] $LogTime = (Get-Date)
    [bool]     $preReqPass

    #Constructor Overload All Values
    AWPPreReq (
        [string]  $computerName,
        [string]  $dotNetFourFrameWorkRelease,
        [version] $osVersion
    ){
        $this.computerName               = $computerName
        $this.dotNetFourFrameWorkRelease = $dotNetFourFrameWorkRelease
        $this.osVersion                  = $osVersion

        $this.getdotNetFourFrameWorkVersion()
        $this.getPreReqPass()
    }

    [void] getdotNetFourFrameWorkVersion()
    {
        $this.dotNetFourFrameWorkVersion = switch -regex ($this.dotNetFourFrameWorkRelease)
        {
            '378389'        { [Version]'4.5' }
            '378675|378758' { [Version]'4.5.1' }
            '379893'        { [Version]'4.5.2' }
            '393295|393297' { [Version]'4.6' }
            '394254|394271' { [Version]'4.6.1' }
            '394802|394806' { [Version]'4.6.2' }
            {$_ -gt 394806} { [Version]'100' }
        }
    }

    [void] getPreReqPass()
    {
        if(($this.dotNetFourFrameWorkVersion -ge [version]'4.6.1') -and ($this.osVersion -ge [Version]6.1))
        {
            $this.preReqPass = $true
        }
        else
        {
            $this.preReqPass = $false
        }
    }

    [void] setLogTime()
    {
        $this.LogTime = Get-Date
    }
}