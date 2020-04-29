Function Get-ChocolateyPackageMetaData {
    <#
    .SYNOPSIS
    Return package metadata from a given Chocolatey Package(s)

    .DESCRIPTION
    Reads the contents of the nupkg and extracts metadata from the nuspec contained within it

    .PARAMETER ChocolateyPackage
    The chocolatey package(s) you wish to extract data from

    .PARAMETER AdditonalInformation
    Return more information about the package than the default ID and Version

    .EXAMPLE
    Get-ChocoPackageMetaData -ChocolateyPackage C:\Packages\googlechrome.nupkg

    .EXAMPLE
    Get-ChocoPackageMetaData -ChocolateyPackage C:\Packages\googlechrome.nupkg -AdditionalInformation Owners,Description,ProjectUrl,Dependencies
    
    .NOTES
    Written by Stephen Valdinger of Chocolatey Software for Dan Franciscus

    #>

    [cmdletBinding(DefaultParameterSetName='Default')]
    Param(
        [Parameter(Mandatory,ParameterSetName='Default')]
        [ValidateScript({Test-Path $_})]
        [String[]]
        $NuspecFile

                
    )

    begin { }

    process {
        
        Foreach($package in $NuspecFile){
            $obj = [ordered]@{}
                   
                    [xml]$xml = Get-Content $package
                    $obj.Add("Id","$($xml.package.metadata.id)")
                    $obj.Add("Version","$($xml.package.metadata.version)")
                    $obj.Add("Authors","$($xml.package.metadata.authors)")
                    $obj.Add("Owners","$($xml.package.metadata.owners)")
                    $obj.Add("ProjectUrl","$($xml.package.metadata.projecturl)")
                    $obj.Add("Description","$($xml.package.metadata.description)")
                   
            [pscustomobject]$obj

        }
    
    }

}