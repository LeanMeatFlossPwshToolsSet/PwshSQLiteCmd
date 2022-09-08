Import-Module Pester
# $configuration=[PesterConfiguration]::Default
# $configuration.CodeCoverage.Enabled = $true
if(-not $env:GITHUB_WORKSPACE){
    $env:GITHUB_WORKSPACE=(Resolve-Path "$PSScriptRoot/../").Path
}
if(-not (Test-Path "$($env:GITHUB_WORKSPACE)/.TestReports/")){
    New-Item  "$($env:GITHUB_WORKSPACE)/.TestReports/" -ItemType Directory
}
Get-ChildItem (Resolve-Path "$($env:GITHUB_WORKSPACE)/").Path -Recurse -Filter "*.Tests.ps1"|ForEach-Object{
    Invoke-Pester -Path $_.FullName -OutputFile "$($env:GITHUB_WORKSPACE)/.TestReports/$($_.Name).xml" -OutputFormat JUnitXml
}