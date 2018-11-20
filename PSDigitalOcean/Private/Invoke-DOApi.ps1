<#
.SYNOPSIS
    Invoke the DigitalOcean API
.DESCRIPTION
    Main function to invoke the DigitalOcean API
.EXAMPLE DigitalOcean API GET Request
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    Invoke-DOApi -Token $Token -Endpoint 'account'
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Private.API.  Invoke-DOApi returns response from DigitalOcean API
.FUNCTIONALITY
    Calls the DigitalOcean API
#>
function Invoke-DOApi {
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
                   ValueFromPipelineByPropertyName=$true
                   )]
        [string]
        $Token,
        
        # Digital Ocean API Endpoint
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [string]
        $Endpoint,
        
        # Digital Ocean API BaseUri
        [Parameter(Mandatory=$false,
                   Position=2,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [string]
        $BaseUri = "https://api.digitalocean.com/v2/",

        # Digital Ocean Request Method
        [Parameter(Mandatory=$false,
                   Position=3,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [ValidateSet('GET','POST', 'DELETE')]
        [string]
        $Method = 'GET',


        # Digital Ocean Request Body
        [Parameter(Mandatory=$false,
                   Position=4,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [string]
        $Body
    )
    
    begin {
    }
    
    process {

        Write-Verbose -Message 'Creating header for API call'

        try {
            $headers = @{ 
                "Authorization" =  "Bearer $Token"
                "Content-Type" = "application/json"
            }
    
            Write-Debug -Message "Calling DigitalOcean API Endpoint $Endpoint"

            $props = @{
                Headers = $headers
                Uri     = $BaseUri + $Endpoint
                Method  = $Method
            }

            if ($Body){
                $props.Add( 'Body', $Body)
            }
        
            Invoke-RestMethod @props
        }
        catch {
            Write-Error -ErrorRecord $Error[0]
        }
    }
    
    end {
    }
}