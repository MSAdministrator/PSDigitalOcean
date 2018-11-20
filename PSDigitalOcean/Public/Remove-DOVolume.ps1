<#
.SYNOPSIS
    Remove DigitalOcean Volume
.DESCRIPTION
    Remove DigitalOcean volume based on provided Volume Id or Name
.EXAMPLE Remove DigitalOcean Volume based on Volume ID
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    Get-DOVolume -Token $Token -Id 'b0d48cb3-ec38-11e8-b82a-0a58ac1443a9'
.EXAMPLE Remove DigitalOcean Volume  based on Volume Name
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    Get-DOVolume -Token $Token -Name 'My Volume'
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    None.
.FUNCTIONALITY
    Remove DigitalOcean Volume
#>
function Remove-DOVolume {
    [CmdletBinding(DefaultParameterSetName='volume',
                   SupportsShouldProcess=$true,
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # DigitalOcean API Token
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [string]
        $Token,

        # Volume Id to Remove
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='volume'
                   )]
        [Alias("VolumeId")]
        [int]
        $Id,

        # Name of Volume
        [Parameter(Mandatory=$true,
                   Position=2,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='volumebyname'
                   )]
        [string]
        $Name
    )

    DynamicParam {
        # Set the dynamic parameters' name
        $ParameterName = 'Region'
        
        # Create the dictionary 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 3
        $ParameterAttribute.ParameterSetName = 'volumebyname'

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        # Generate and set the ValidateSet 
        $arrSet = (Get-DORegions -Token $PSBoundParameters['Token']).Slug
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
    
    begin {
    }
    
    process {
        try{
            Write-Verbose -Message 'Attempting to get ALL DigitalOcean Regions'

            $volumeEndpoint = ''

            switch ($PSCmdlet.ParameterSetName) {
                'volume'       { $volumeEndpoint = "volumes/$Id" }
                'volumebyname' { $volumeEndpoint = "volumes?name=$Name&region=$($PSBoundParameters['Region'])"}
            }

            $props = @{
                Token    = $Token
                Endpoint = $volumeEndpoint
                Method   = 'DELETE'
            }

            if ($pscmdlet.ShouldProcess("Volume $Id", "Removing Volume named $Name")) {
                $volume = Invoke-DOApi @props
            }
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to remove Volume.  Please try again.'
        }
    }
    
    end {
    }
}