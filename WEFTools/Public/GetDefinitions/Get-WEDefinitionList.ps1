function Get-WEDefinitionList {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false,HelpMessage = 'Path were definitions are stored')]
        [ValidateScript( {Test-Path -Path $_ -PathType Container})]
        [string]
        $WEDefinitionPath
    )
    process {
        if($PSBoundParameters.ContainsKey('WEDefinitionPath')){
            $WEDefinitionPathFinal = $WEDefinitionPath
        }
        else {
            $WEDefinitionPathFinal = Get-Item -Path "$PSScriptRoot\..\..\Configuration\Definitions"
        }
        Write-Verbose "Will look for definitions in {$WEDefinitionPathFinal}"
        Get-ChildItem -Path $WEDefinitionPathFinal -File | Select-Object -ExpandProperty BaseName
    }
}