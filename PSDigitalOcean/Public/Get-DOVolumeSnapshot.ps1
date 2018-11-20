<#
.SYNOPSIS
    Get DigitalOcean Volume Snapshot
.DESCRIPTION
    Get DigitalOcean volume snapshot based on provided Volume Id
.EXAMPLE Get DigitalOcean Volume snapshot based on Volume ID
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    Get-DOVolumeSnapshot -Token $Token -Id 'b0d48cb3-ec38-11e8-b82a-0a58ac1443a9'
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Volume.Snapshot.  Get-DOVolumeSnapshot returns a custom object.
.FUNCTIONALITY
    Get DigitalOcean Volume Snapshot
#>
function Get-DOVolumeSnapshot {
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
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='volume'
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
        $Id

    )

    begin {
    }
    
    process {
        
        Write-Verbose -Message 'Attempting to get DigitalOcean Volume snapshots by Id'

        $props = @{
            Token    = $Token
            Endpoint = "volumes/$Id/snapshots"
            Method   = 'GET'
        }

        $snapshots = (Invoke-DOApi @props).snapshots

        Write-Debug -Message 'Parsing DigitalOcean Volume snapshot information and creating new object'
        
        try{
            $snapshots.ForEach( {
                [PSCustomObject]@{
                    Id           = $_.id
                    Name         = $_.name
                    CreatedAt    = $_.created_at
                    ResourceId   = $_.resource_id
                    ResourceType = $_.resource_type
                    MinDiskSize  = $_.min_disk_size
                    'Size (GB)'  = $_.size_gigabytes
                } | Add-ObjectDetail -TypeName PSDigitalOcean.Volume.Snapshot
            })
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to access DigitalOcean Regions.  Please try again.'
        }
    }
    
    end {
    }
}