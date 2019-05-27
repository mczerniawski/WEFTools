function Get-WEDefinition {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false,HelpMessage = 'Name of file with definitions')]
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
        $DefinitionFiles = Get-ChildItem -Path $WEDefinitionPathFinal -File
        foreach ( $DefinitionFile in $DefinitionFiles ) {
            if($PSBoundParameters.ContainsKey('WEDefinitionName')) {
                $FileBaseName = $DefinitionFile | Select-Object -ExpandProperty BaseName
                if ( $FileBaseName -in $WEDefinitionName ) {
                    Get-ConfigurationData -ConfigurationPath $DefinitionFile.FullName -OutputType HashTable
                }
            }
            else {
                Get-ConfigurationData -ConfigurationPath $DefinitionFile.FullName -OutputType HashTable
            }
        }
    }
}