<#
.SYNOPSIS
    Create new DigitalOcean Volume Snapshot
.DESCRIPTION
    Create a new DigitalOcean Volume Snapshot based Volume Id
.EXAMPLE Create a new DigitalOcean Volume Snapshot
    $Token = '1545252204D7D28F0C51321A794743C7286C378F71861ED26E3F8066102A3DB0'
    New-DOVolume -Token $Token -Id 'b0d48cb3-ec38-11e8-b82a-0a58ac1443a9' -Name 'My New Volume Snapshot'
.INPUTS
    System.String.  You can pipe your DO Token into this function.
.OUTPUTS
    PSDigitalOcean.Volume.Snapshot.  New-DOVolumeSnapshot returns a custom object.
.FUNCTIONALITY
    Create new DigitalOcean Volume Snapshot
#>
function New-DOVolumeSnapshot {
    [CmdletBinding(PositionalBinding=$false,
                   SupportsShouldProcess=$true,
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
                   ValueFromPipelineByPropertyName=$true
                   )]
        [Alias("VolumeId")]
        [string]
        $Id,

        # Snapshot name
        [Parameter(Mandatory=$true,
                   Position=2,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [string]
        $Name
    )

    begin {
    }
    
    process {
        
        Write-Verbose -Message 'Attempting to create snapshot from a volume'

        $Body = @{}

        Write-Debug -Message "Dynamic Parameter Region has value of $($PSBoundParameters['Region'])"

        switch ($PSBoundParameters.Keys)
        {
            'Name' { $Body.name = $Name }
        }

        $props = @{
            Token    = $Token
            Endpoint = "volumes/$Id/snapshots"
            Method   = 'POST'
            Body     = $Body | ConvertTo-Json
        }

        $Body

        if ($pscmdlet.ShouldProcess("Volume $Id", "Creating Snapshot named $Name")) {
            $snapshot = (Invoke-DOApi @props).snapshot
        }

        Write-Debug -Message 'Parsing DigitalOcean Volume snapshot creation response and creating new object'
        
        try{
            $snapshot.ForEach( {
                [PSCustomObject]@{
                    Id          = $_.id
                    Name        = $_.name
                    CreatedAt   = $_.created_at
                    Region      = $_.regions
                    ResourceId  = $_.resource_id
                    ResourceTyp = $_.resource_type
                    MinDiskSize = $_.min_disk_size
                    'Size (GB)' = $_.size_gigabytes
                } | Add-ObjectDetail -TypeName PSDigitalOcean.Volume.Snapshot
            })
        }
        catch{
            Write-Error -ErrorRecord $Error[0] -RecommendedAction 'Unable to access DigitalOcean to create Volume Snapshot.  Please try again.'
        }
    }
    
    end {
    }
}