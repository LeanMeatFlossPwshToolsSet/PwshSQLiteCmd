BeforeAll{
    $currentTestModuleName=([System.IO.FileInfo]$PSCommandPath).Name.Replace(".Tests.ps1","")
    $env:PSModulePath=(Resolve-Path "$PSScriptRoot/..").Path+[IO.Path]::PathSeparator+$env:PSModulePath
    # add psmodules for all items in workspaces
    $moduleManifestFile=Import-PowerShellDataFile  "$PSScriptRoot/$currentTestModuleName.psd1"
    # install dependency modules
    (Resolve-Path "$PSScriptRoot/../../../")|Get-ChildItem -Directory|Foreach-Object{
        $ParentNamePath=$_.Name
        $_|Get-ChildItem -Directory|Where-Object{
            $_.Name -eq $ParentNamePath
        }
    }|ForEach-Object{
        $env:PSModulePath=$_.FullName+[IO.Path]::PathSeparator+$env:PSModulePath
    }
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    $moduleManifestFile.RequiredModules|Foreach-Object{
        Import-Module $_ -ErrorVariable importError -Force
        if($importError -and $importError.Count -gt 0){
        Install-Module $_ -Force
        Update-Module $_
        }
    }
    Import-Module $currentTestModuleName -Force
}
Describe "Resolve-SQLiteDataBase"{
    It "Create Empty Data Base if no Data Base"{
        (Get-PSDrive TestDrive).Root|Join-PathImproved "Workspace"|Use-Workspace{
            "hello.sqlite"|Resolve-SQLiteDataBase
            "hello.sqlite"|Test-RelativePath|Should -Be $True
        }
    }
}
Describe "SQLiteDataBase Connection"{
    It "Connect To Database"{
        (Get-PSDrive TestDrive).Root|Join-PathImproved "Workspace"|Use-Workspace{
            "hello.sqlite"|Connect-ToSQLiteDataBase
            Get-CurrentSQLiteConnection|Should -Not -BeNullOrEmpty
            Disconnect-SQLiteDataBase
            Get-CurrentSQLiteConnection|Should -BeNullOrEmpty
        }
    }
}