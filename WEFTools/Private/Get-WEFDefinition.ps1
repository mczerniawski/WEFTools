function Get-WEFDefinition {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [psobject]
        $DefinitionPath,

        [Parameter(Mandatory, HelpMessage = '')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $NodeName
    )
    process {
        Get-ConfigurationData -ConfigurationPath
    }
}