<#
.SYNOPSIS
    Get DigitalOcean Volume
.DESCRIPTION
    Get DigitalOcean Volume and volume snapshots based on provided information
.EXAMPLE Get DigitalOcean Volume by ID
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    Get-DOVolume -Token $Token -Id 'b0d48cb3-ec38-11e8-b82a-0a58ac1443a9'
.EXAMPLE Get DigitalOcean Volume by Name & Region
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    Get-DOVolume -Token $Token -Name 'My Volume' -Region nyc1
.EXAMPLE Get DigitalOcean Volume Snapshots by Id
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    Get-DOVolume -Token $Token -Id 'b0d48cb3-ec38-11e8-b82a-0a58ac1443a9' -Snapshots
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Volume.PSObject.  New-DOVolume returns a custom object.
.FUNCTIONALITY
    Get DigitalOcean Volume
#>
function Get-DOVolume {
    [CmdletBinding(DefaultParameterSetName='volume',
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

        # Volume Id
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='volume'
                   )]
        [Alias("VolumeId")]
        [string]
        $Id,

        # Volume Name
        [Parameter(Mandatory=$false,
                   Position=2,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='volumebyname'
                   )]
        [string]
        $Name,

        # Volume snapshots
        [Parameter(Mandatory=$false,
                   Position=4,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='volume'
                   )]
        [switch]
        $Snapshots
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
        
        Write-Verbose -Message 'Attempting to get DigitalOcean Volume by Id'

        $volumeEndpoint = ''

        switch ($PSCmdlet.ParameterSetName) {
            'volume'       { $volumeEndpoint = "volumes/$Id"
                             $objName = 'volume'
                            }
            'volumebyname' { $volumeEndpoint = "volumes?name=$Name&region=$($PSBoundParameters['Region'])"
                             $objName = 'volumes' 
                            }
        }


        if ($Snapshots){
            Get-DOVolumeSnapshot -Token $Token -Id $Id | Write-Output
            return
        }

        $props = @{
            Token    = $Token
            Endpoint = $volumeEndpoint
            Method   = 'GET'
        }

        $volume = (Invoke-DOApi @props).$objName

        Write-Debug -Message 'Parsing DigitalOcean Volume information and creating new object'
        $volume
        try{
            $volume.ForEach( {
                [PSCustomObject]@{
                    Id             = $_.id
                    Region         = $_.region
                    DropletIds     = $_.droplet_ids
                    Name           = $_.name
                    Description    = $_.description
                    'Size (GB)'    = $_.size_gigabytes
                    CreatedAt      = $_.created_at
                    FilesystemType = $_.filesystem_type
                    FilesytemLabel = $_.filesystem_label
                } | Add-ObjectDetail -TypeName PSDigitalOcean.Volume.PSObject
            })
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to access DigitalOcean Regions.  Please try again.'
        }
    }
    
    end {
    }
}