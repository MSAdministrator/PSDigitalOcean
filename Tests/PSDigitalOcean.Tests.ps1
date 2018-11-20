$here = "$(Split-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -Parent)\PSDigitalOcean"


$module = 'PSDigitalOcean'

Describe "$module PowerShell Module Tests" {
    
    Context 'Module Setup' {

        It "has the root module $module.psm1" {
            "$here\$module.psm1" | Should exist
        }

        It "has the manifest file $module.psd1" {
            "$here\$module.psd1" | should exist

            "$here\$module.psd1" | Should contain "$module.psm1"
        }

        It "$module has functions" {
            "$here\Public\*.ps1" | Should exist
        }

        It "$module is valid PowerShell Code" {
            $psFile = Get-Content -Path "$here\$module.psm1" -ErrorAction Stop
            $errors = $null

            $null = [System.Management.Automation.PSParser]::Tokenize($psFile,[ref]$errors)
            $errors.count | Should be 0
        }
    }


    $pubFunctions = ('Get-DOAccount.ps1',
                    'Get-DOAction.ps1',
                    'Get-DORegions.ps1',
                    'Get-DOVolume.ps1',
                    'Get-DOVolumes.ps1',
                    'Get-DOVolumeSnapshot.ps1',
                    'New-DOVolume.ps1',
                    'New-DOVolumeSnapshot.ps1',
                    'Remove-DOVolume.ps1',
                    'Remove-DOVolumeSnapshot.ps1'
                )
    $privFunctions = ('Add-ObjectDetail.ps1',
                        'Invoke-DOApi.ps1')

    foreach ($function in $pubFunctions)
    {
        Context 'Function Tests' {
            
            It "$function.ps1 should exist" {
                "$here\Public\$function.ps1" | Should Exist
            }

            It "$function.ps1 should have help block" {
                "$here\Public\$function.ps1" | Should contain '<#'
                "$here\Public\$function.ps1" | Should contain '#>'
            }
            
            It "$function.ps1 should have a SYNOPSIS section in the help block" {
                "$here\Public\$function.ps1" | Should contain '.SYNOPSIS'
            }

            It "$function.ps1 should have a DESCRIPTION section in the help block" {
                "$here\Public\$function.ps1" | Should contain '.DESCRIPTION'
            }

            It "$function.ps1 should have a EXAMPLE section in the help block" {
                "$here\Public\$function.ps1" | Should contain '.EXAMPLE'
            }

            It "$function.ps1 should be an advanced function" {
                "$here\Public\$function.ps1" | Should contain 'function'
                "$here\Public\$function.ps1" | Should contain 'CmdLetBinding'
                "$here\Public\$function.ps1" | Should contain 'param'
            }

            It "$function.ps1 should contain Write-Verbose blocks" {
                "$here\Public\$function.ps1" | Should contain 'Write-Verbose'
            }

            It "$function.ps1 is valid PowerShell code" {
                $psFile = Get-Content -Path "$here\Public\$function.ps1" -ErrorAction Stop
                $errors = $null

                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.count | Should be 0
            }
        }#Context Function Tests
    }

    foreach ($function in $privFunctions) {
        Context 'Private Functions' {

            It "$function.ps1 should exist" {
                "$here\Private\$function.ps1" | Should Exist
            }

            It "$function.ps1 should have help block" {
                "$here\Private\$function.ps1" | Should -FileContentMatch '<#'
                "$here\Private\$function.ps1" | Should -FileContentMatch '#>'
            }
            
            It "$function.ps1 should have a SYNOPSIS section in the help block" {
                "$here\Private\$function.ps1" | Should -FileContentMatch '.SYNOPSIS'
            }

            It "$function.ps1 should have a DESCRIPTION section in the help block" {
                "$here\Private\$function.ps1" | Should -FileContentMatch '.DESCRIPTION'
            }

            It "$function.ps1 should have a EXAMPLE section in the help block" {
                "$here\Private\$function.ps1" | Should -FileContentMatch '.EXAMPLE'
            }

            It "$function.ps1 should be an advanced function" {
                "$here\Private\$function.ps1" | Should -FileContentMatch 'function'
                "$here\Private\$function.ps1" | Should -FileContentMatch 'CmdLetBinding'
                "$here\Private\$function.ps1" | Should -FileContentMatch 'param'
            }

            It "$function.ps1 should contain Write-Verbose blocks" {
                "$here\Private\$function.ps1" | Should -FileContentMatch 'Write-Verbose'
            }

            It "$function.ps1 is valid PowerShell code" {
                $psFile = Get-Content -Path "$here\Private\$function.ps1" -ErrorAction Stop
                $errors = $null

                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.count | Should be 0
            }
        } # Context Private Function Tests
    } # end of foreach
}