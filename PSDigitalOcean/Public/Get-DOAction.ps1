<#
.SYNOPSIS
    Get DigitalOcean Action(s)
.DESCRIPTION
    Based on the provided token, you can list all or a single DigitalOcean Action
.EXAMPLE Get All DigitalOcean Actions
    Get-DOActions -Token '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
.EXAMPLE Pipe Token into Get-DOActions
    '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0' | Get-DOActions
.EXAMPLE Get a single DigitalOcean action
    Get-DOActions -Token '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0' -Id '115857372'
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Action.PSObject.  Get-DOAction returns a custom object.
.FUNCTIONALITY
    Get DigitalOcean Actions
#>
function Get-DOAction {
    [CmdletBinding(PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Digital Ocean API Token
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [string]
        $Token,

        # A single DigitalOcean Action Id
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='action')]
        [Alias("ActionId")]
        [string]
        $Id
    )
    
    begin {
    }
    
    process {
        
        Write-Verbose -Message 'Attempting to get a single DigitalOcean Action'

        $actionEndpoint = 'actions'
        $actionObj = 'actions'

        if ($Id){
            $actionEndpoint = "actions/$Id"
            $actionObj = 'action'
        }

        $actions = (Invoke-DOApi -Token $Token -Endpoint $actionEndpoint).$actionObj

        Write-Debug -Message 'Parsing DigitalOcean Action and creating new object'
        
        try{
            $actions.ForEach( {
                [PSCustomObject]@{
                    Id            = $_.id
                    Status        = $_.status
                    Type          = $_.type
                    StartedAt     = $_.started_at
                    CompletedAt   = $_.completed_at
                    ResourceId    = $_.resource_id
                    ResourceType  = $_.resource_type
                    Region        = $_.region
                    RegionSlug    = $_.region_slug
                } | Add-ObjectDetail -TypeName PSDigitalOcean.Action.PSObject
            })
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to access DigitalOcean Actions.  Please try again.'
        }
    }
    
    end {
    }
}