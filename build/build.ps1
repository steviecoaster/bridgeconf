[cmdletBinding()]
param(
    [parameter()]
    [switch]
    $Build,

    [parameter()]
    [switch]
    $Test,

    [parameter()]
    [switch]
    $Deploy
)

process {

    if($Build.IsPresent){
            #Grep the commit log for the package I'm working on. This requires commits to be made in a specific format. -- E.g. "[packagename] Changed some code in the chocolateyInstall.ps1 file"
            $commit = git log -1 --pretty=%B
            $null = $commit[0] -match '(?<package>(?<=\[).+?(?=\]))'
            
            Write-Host "Commit Message: $($commit[0])"
            Write-Host $matches.package

            #Get the Nuspec based on the regex match
            $NuspecFile = $matches.package

            #isolate the folder containing all of our data based on the match
            $changes = Get-ChildItem $env:Build_SourcesDirectory -Recurse -Filter '*.nuspec' | Where-Object { $_.BaseName -eq $NuspecFile }

            #Save the folder path based on above
            $nuspecLocation = ($changes | Where-Object { $_.Extension -eq '.nuspec' -and $_.Directory }).DirectoryName

            #Emit some pipeline variables now that we have our information gathered
            $filter = Get-ChildItem -Path $nuspecLocation -Filter '*.nuspec' | Select-Object FullName, BaseName, Name

            $NuspecFullPath = $filter.Fullname
            $NuspecFile = $filter.Name
            $NuspecBaseName = $filter.Basename

            # https://docs.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#set-variables-in-scripts
            Write-Output "##vso[task.setvariable variable=NuspecDirectory]$nuspecLocation"
            Write-Output "##vso[task.setvariable variable=Nuspec]$NuspecFullPath"
            Write-Output "##vso[task.setvariable variable=NuspecFile]$NuspecFile"
            Write-Output "##vso[task.setvariable variable=Package]$NuspecBaseName"
        }

        if($Test.IsPresent){
            Install-Module -Name Pester -RequiredVersion 4.3.1 -Scope CurrentUser -Force -SkipPublisherCheck
            Invoke-Pester ./tests -OutputFormat 'NUnitXml' -OutputFile "$($env:Build_ArtifactStagingDirectory)\$($env:package).xml"
         }

         if($Deploy.IsPresent){

            $source  = Get-ChildItem -Path $env:Pipeline_Workspace -Recurse -Filter *.nupkg
            $package = $source.FullName
            $name = $source.Name
            $parent = $source.Directory

            Write-Output $package
            Write-Output $name
            Write-Output $parent

            Write-Output "##vso[task.setvariable variable=Package]$package"
            Write-Output "##vso[task.setvariable variable=Name]$name"
            Write-Output "##vso[task.setvariable variable=Parent]$parent"
         }

    }
