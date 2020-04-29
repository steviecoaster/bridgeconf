$env:ChangedNuspec

$changes = Get-ChildItem $env:Build_SourcesDirectory -Recurse -Filter '*.nuspec' | Where-Object { $_.BaseName -eq $env:ChangedNuspec }

$changes

$nuspecLocation =  ($changes | ? { $_.Extension -eq '.nuspec' -and $_.Directory}).DirectoryName
$filter =  gci -Path $nuspecLocation -Filter '*.nuspec' | Select-Object FullName, BaseName,Name

$NuspecFullPath = $filter.Fullname
echo "Nuspec path: $NuspecFullPath"

$NuspecFile = $filter.Name
echo $NuspecFile

$NuspecBaseName = $filter.Basename
echo "Package name: $NuspecBaseName"




echo "##vso[task.setvariable variable=NuspecDirectory]$nuspecLocation"
echo "##vso[task.setvariable variable=Nuspec]$NuspecFullPath"
echo "##vso[task.setvariable variable=NuspecFile]$NuspecFile"
echo "##vso[task.setvariable variable=Package]$NuspecBaseName"
