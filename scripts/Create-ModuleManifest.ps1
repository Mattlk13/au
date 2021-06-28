[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [String] $ModulePath,

    [Parameter(Mandatory = $true)]
    [Version] $Version
)

$module_name = Split-Path -Leaf $ModulePath

Write-Verbose "Getting public module functions"
$functions = Get-ChildItem $ModulePath\Public\*.ps1 | ForEach-Object { $_.Name -replace '\.ps1$' }
if ($functions.Count -eq 0) { throw 'No public functions to export' }

Write-Verbose "Getting public module aliases"
try { import-module $ModulePath -force } catch { throw $_ }
$aliases = Get-Alias | Where-Object { $_.Source -eq $module_name -and ($functions -contains $_.Definition) }

Write-Verbose "Generating module manifest"
$params = @{
    Guid              = 'b2cb6770-ecc4-4a51-a57a-3a34654a0938'
    Author            = 'Miodrag Milic'
    PowerShellVersion = '5.0'
    Description       = 'Chocolatey Automatic Package Updater Module'
    HelpInfoURI       = 'https://github.com/majkinetor/au/blob/master/README.md'
    Tags              = 'chocolatey', 'update'
    LicenseUri        = 'https://www.gnu.org/licenses/gpl-2.0.txt'
    ProjectUri        = 'https://github.com/majkinetor/au'
    ReleaseNotes      = 'https://github.com/majkinetor/au/blob/master/CHANGELOG.md'

    ModuleVersion     = $Version
    FunctionsToExport = $functions
    AliasesToExport   = $aliases        #better then * as each alias is shown in PowerShell Galery
    Path              = "$ModulePath\$module_name.psd1"
    RootModule        = "$module_name.psm1"

}
New-ModuleManifest @params
