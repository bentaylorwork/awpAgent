$filesToImport  = Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 -ErrorAction Stop

#Check if any public functions to access
if($null -ne $filesToImport)
{
	$filesToImport += Get-ChildItem -Path $PSScriptRoot\classes\*.ps1 -recurse -ErrorAction SilentlyContinue

	#Import All Public\Private Functions and Classes
	forEach($fileToImport in $filesToImport)
	{
		try 
		{
			. $fileToImport
		}
		catch
		{
			Write-Error "ERROR: Failed to import function $($fileToImport)"
		}
	}

	#Format Views
	$formatViews = Get-ChildItem -Path $PSScriptRoot\classes\views\*format.ps1xml -ErrorAction SilentlyContinue

	foreach ($formatView in $formatViews)
	{
		Update-FormatData -PrependPath $formatView
	}
}
else
{
	Write-Error "ERROR: No public functions to load."
}