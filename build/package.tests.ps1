$testPath =  $(Split-Path -Parent $MyInvocation.MyCommand.Definition)
$functionpath = "$(Split-Path -Parent $testPath)\build\Get-ChocolateyPackageMetaData.ps1"


. $functionpath

$package = Get-ChocolateyPackageMetaData -NuspecFile "$env:Nuspec"
Describe "Packages should contain certain information" {

    It "Has a proper semver version" {
       
        $package.Version | Should -Not -BeNullOrEmpty
        $package.Version | Should -Match '^([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$'

    }

    It "Has a description" {
        $package.Description | Should -Not -BeNullOrEmpty

    }

    It "Has an author" {
        $package.Authors | Should -Not -BeNullOrEmpty

    }

    It "Has a Project URL" {
        $package.ProjectUrl | Should -Not -BeNullOrEmpty
    }

    It "Project URL should resolve" {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $result = Invoke-WebRequest "$($package.ProjectUrl)/tree/master/$($package.id)" -UseBasicParsing
        $result.StatusCode | Should -Be '200'
    }
}
