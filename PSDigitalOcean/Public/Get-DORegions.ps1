<#
.SYNOPSIS
    Get DigitalOcean Regions
.DESCRIPTION
    Based on the provided token, you can list all available DigitalOcean regions
.EXAMPLE Get All DigitalOcean Regions
    Get-DORegions -Token '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Regions.PSObject.  Get-DORegions returns a custom object.
.FUNCTIONALITY
    Get DigitalOcean Regions
#>
function Get-DORegions {
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false, 
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Token
    )
    
    begin {
    }
    
    process {
        
        Write-Verbose -Message 'Attempting to get ALL DigitalOcean Regions'

        $regions = (Invoke-DOApi -Token $Token -Endpoint "regions").regions

        Write-Debug -Message 'Parsing DigitalOcean Regions and creating new object'
        
        try{
            $regions.ForEach( {
                [PSCustomObject]@{
                    Slug       = $_.slug
                    Name       = $_.name
                    Sizes      = $_.sizes
                    Available  = $_.available
                    Features   = $_.features
                } | Add-ObjectDetail -TypeName PSDigitalOcean.Regions.PSObject
            })
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to access DigitalOcean Regions.  Please try again.'
        }
    }
    
    end {
    }
}