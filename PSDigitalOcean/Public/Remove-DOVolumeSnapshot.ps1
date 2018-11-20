<#
.SYNOPSIS
    Remove DigitalOcean Volume Snapshot
.DESCRIPTION
    Remove DigitalOcean volume snapshot based on provided Snapshot Id
.EXAMPLE Remove DigitalOcean Volume snapshot based on Snapshot ID
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    Get-DOVolumeSnapshot -Token $Token -Id 'b0d48cb3-ec38-11e8-b82a-0a58ac1443a9'
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    None.
.FUNCTIONALITY
    Remove DigitalOcean Volume Snapshot
#>
function Remove-DOVolumeSnapshot {
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
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='volume'
                   )]
        [string]
        $Token,

        # Volume Snapshot Id to Remove
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='volume'
                   )]
        [Alias("SnapshotId")]
        [int]
        $Id
    )
    
    begin {
    }
    
    process {
        try{
            Write-Verbose -Message 'Attempting to remove volume Snapshot'

            $props = @{
                Token    = $Token
                Endpoint = "snapshots/$Id"
                Method   = 'DELETE'
            }

            if ($pscmdlet.ShouldProcess("Snapshot $Id", "Removing Volume Snapshot $Id")) {
                $volume = Invoke-DOApi @props
            }
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to remove Volume Snapshot.  Please try again.'
        }
    }
    
    end {
    }
}