<#
.SYNOPSIS
    Get All DigitalOcean Volumes
.DESCRIPTION
    Based on the provided token, you can retrieve all DigitalOcean Volumes
.EXAMPLE Get DigitalOcean Volumes
    Get-DOAccount -Token '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Volumes.PSObject.  Get-DOVolumes returns a custom object.
.FUNCTIONALITY
    Get DigitalOcean Volumes
#>
function Get-DOVolumes {
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Digital Ocean API Token
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Token
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
        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.Position = 1

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        # Generate and set the ValidateSet 
        $arrSet = (Get-DORegions -Token $Token).Slug
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
        
        Write-Verbose -Message 'Attempting to get ALL DigitalOcean Volumes'

        $endpoint = "volumes"

        if ($PSBoundParameters.ContainsKey('Region')){
            $endpoint = "volumes?region=$Region"
        }
        $volumes = (Invoke-DOApi -Token $Token -Endpoint $endpoint).volumes

        Write-Debug -Message 'Parsing DigitalOcean Volumes and creating new object'
        
        try{
            $volumes.ForEach( {
                [PSCustomObject]@{
                    Id              = $_.id
                    Region          = $_.region
                    DropletIds      = $_.droplet_ids
                    Name            = $_.name
                    'Size (GB)'     = $_.size_gigabytes
                    CreatedAt       = $_.created_at
                    FilesystemType  = $_.filesystem_type
                    FilesystemLabel = $_.filesystem_label
                } | Add-ObjectDetail -TypeName PSDigitalOcean.Volumes.PSObject
            })
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to access DigitalOcean Volumes.  Please try again.'
        }
    }
    
    end {
    }
}