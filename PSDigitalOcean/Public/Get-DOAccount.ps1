<#
.SYNOPSIS
    Get DigitalOcean Account information
.DESCRIPTION
    Based on the provided token, you can retrieve the DigitalOcean Account information
.EXAMPLE Get DigitalOcean Account Information
    Get-DOAccount -Token '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
.EXAMPLE Pipe Token into Get-DOAccount
    '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0' | Get-DOAccount
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Account.PSObject.  Get-DOAccount returns a custom object.
.FUNCTIONALITY
    Get DigitalOcean Account information
#>
function Get-DOAccount {
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
        
        Write-Verbose -Message 'Attempting to get DigitalOcean Account information'

        $account = Invoke-DOApi -Token $Token -Endpoint "account" 

        Write-Debug -Message 'Parsing DigitalOcean Account info and creating new object'

        try{
            $props = [ordered]@{
                DropletLimit    = $account.account.droplet_limit
                FloatingIpLimit = $account.account.floating_ip_limit
                Email           = $account.account.email
                UUID            = $account.account.uuid
                EmailVerified   = $account.account.email_verified
                Status          = $account.account.status
                StatusMessage   = $account.account.status_message
            }
            New-Object -TypeName PSCustomObject -Property $props | Add-ObjectDetail -TypeName PSDigitalOcean.Account.PSObject

        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to access DigitalOcean Account object.  Please try again.'
        }
    }
    
    end {
    }
}