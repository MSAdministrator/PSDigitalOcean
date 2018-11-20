<#
.SYNOPSIS
    Create new DigitalOcean Volume
.DESCRIPTION
    Create a new DigitalOcean Volume based on provided information
.EXAMPLE Create a new DigitalOcean Volume
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    New-DOVolume -Token $Token -Size 10 -Name 'My New Volume' -Description 'Creating a new Volume' -Region nyc1
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Volume.PSObject.  New-DOVolume returns a custom object.
.FUNCTIONALITY
    Create new DigitalOcean Volume
#>
function New-DOVolume {
    [CmdletBinding(DefaultParameterSetName='ext4',
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # DigitalOcean API Token
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='xfs'
                   )]
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='ext4'
                   )]
        [string]
        $Token,

        # Volume Size in Gigabytes
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='xfs'
                   )]
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='ext4'
                   )]
        [int]
        $Size,

        # Name of Volume
        [Parameter(Mandatory=$true,
                   Position=2,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='xfs'
                   )]
        [Parameter(Mandatory=$true,
                   Position=2,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='ext4'
                   )]
        [string]
        $Name,

        # Description of Volume
        [Parameter(Mandatory=$true,
                   Position=3,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='xfs'
                   )]
        [Parameter(Mandatory=$true,
                   Position=3,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='ext4'
                   )]
        $Description,

        # Volume Filesystem Type of ext4
        [Parameter(Mandatory=$false,
                   Position=5,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='ext4'
                   )]
        [switch]
        $ext4,

        # Volume Filesystem Type of xfs
        [Parameter(Mandatory=$false,
                   Position=6,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='xfs'
                   )]
        [switch]
        $xfs,

        # Volume label name
        [Parameter(Mandatory=$false,
                   Position=7,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='xfs'
                   )]
        [Parameter(Mandatory=$false,
                   Position=7,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='ext4'
                   )]
        [ValidateLength(1,12)]
        [string]
        $Label
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
        $ParameterAttribute.Position = 4

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
        
        Write-Verbose -Message 'Attempting to get ALL DigitalOcean Regions'

        $Body = @{}

        Write-Debug -Message "Dynamic Parameter Region has value of $($PSBoundParameters['Region'])"

        switch ($PSBoundParameters.Keys)
        {
            'Size'        { $Body.size_gigabytes   = $Size                        }
            'Name'        { $Body.name             = $Name                        }
            'Description' { $Body.description      = $Description                 }
            'Region'      { $Body.region           = $PSBoundParameters['Region'] }
            'SnapshotId'  { $Body.snapshot_id      = $SnapshotId                  }
            'ext4'        { $Body.filesystem_type  = 'ext4'                       }
            'xfs'         { $Body.filesystem_type  = 'xfs'                        }
            'Label'       { $Body.filesystem_label = $Label                       }
        }

        $props = @{
            Token    = $Token
            Endpoint = "volumes"
            Method   = 'POST'
            Body     = $Body | ConvertTo-Json
        }

        $Body

        $volume = (Invoke-DOApi @props).volume

        Write-Debug -Message 'Parsing DigitalOcean Volume creation response and creating new object'
        
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