function Get-ObjectMembers {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [PSCustomObject]$obj
    )
    $obj | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        [PSCustomObject]@{Key = $key; Value = $obj."$key"}
    }
}

$pwd = $PSScriptRoot

$depsUrl = "https://servo-deps.s3.amazonaws.com/msvc-deps/"
$depsRoot = "$pwd\.servo\msvc-dependencies"
New-Item $depsRoot -Type Directory -ErrorAction SilentlyContinue | out-null
$packages = Get-Content -Raw -Path msvc-dependencies.json | ConvertFrom-Json
$packages | Get-ObjectMembers | foreach {
    $name=$_.Key
    $version=$_.Value
    if (! (Test-Path "${depsRoot}\${name}-${version}.zip")) {
        Write-Output "Downloading ${depsUrl}${name}-${version}.zip to ${depsRoot}\${name}-${version}.zip"
        (New-Object Net.WebClient).DownloadFile("${depsUrl}${name}-${version}.zip", "${depsRoot}\${name}-${version}.zip")

        Write-Output "Extracting ${depsRoot}\${name}-${version}.zip"
        Expand-Archive "${depsRoot}\${name}-${version}.zip" -DestinationPath "${depsRoot}\${name}"

        Rename-Item "${depsRoot}\${name}\${name}-${version}" "${depsRoot}\${name}\${version}"
    }
}

[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
(New-Object Net.WebClient).DownloadFile("https://win.rustup.rs/", "$pwd\.servo\rustup-init.exe")
