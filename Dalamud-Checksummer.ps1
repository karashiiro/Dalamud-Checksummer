if ($Args.Count -lt 2) {
    Write-Output "Please provide a plugin zip as the first argument of this command, and a metadata file as the second."
    return
}

$pluginZip = $Args[0]
$metaFile = $Args[1]
$meta = Get-Content -Path $metaFile | ConvertFrom-JSON

$genericReassurance = "This is not an issue in and of itself, but the PR process may take longer than usual."

# Unzip archive and get the DLL hash from it
Expand-Archive -Path $pluginZip -DestinationPath unpack/ -Force
Set-Location unpack
$hash1 = Get-FileHash "$($meta.InternalName).dll" -Algorithm SHA512
Set-Location ..

# Checkout linked repository
if (-not(Get-Member -InputObject $meta -Name "RepoUrl" -MemberType Properties)) {
    Write-Error "No public repository is provided in the plugin JSON. $($genericReassurance)"
    return
}

$repoUrl = $meta.RepoUrl
git clone $repoUrl

# Build inside repository and get latest DLL hash
Set-Location $repoUrl.Substring($repoUrl.LastIndexOf("/") + 1)
dotnet build -c Release
Set-Location "$($meta.InternalName)/bin/Release/net472"
$hash2 = Get-FileHash "$($meta.InternalName).dll" -Algorithm SHA512

# Compare DLL hashes and provide result
if ($hash2 -eq "") {
    Write-Error "The linked repository is set up differently than expected. $($genericReassurance)"
    return
}

if ($hash1 -ne $hash2) {
    Write-Error "DLL checksum does not match build from linked repository. $($genericReassurance)"
    return
}

Write-Output "DLL checksum matches build from linked repository. The latest GitHub commit can be used instead of ILSpy."
