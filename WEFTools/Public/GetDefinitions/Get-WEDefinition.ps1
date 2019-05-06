function Get-WEDefinition {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,HelpMessage = 'Name of file with definitions')]
        [ValidateSet('ADComputerCreatedChanged','ADGroupChanges','ADGroupCreateDelete','ADPasswordChange','ADUserAccountEnabledDisabled','ADUserLocked','ADUserUnlocked','LogClearSystem','LogClearSecurity')]
        [string[]]
        $WEDefinitionName,

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
        $DefinitionFiles = Get-ChildItem -Path $WEDefinitionPathFinal -File
        foreach ( $DefinitionFile in $DefinitionFiles ) {
            $FileBaseName = $DefinitionFile | Select-Object -ExpandProperty BaseName
            if ( $FileBaseName -in $WEDefinitionName ) {
                Get-ConfigurationData -ConfigurationPath $DefinitionFile.FullName -OutputType HashTable
            }
        }
    }
}