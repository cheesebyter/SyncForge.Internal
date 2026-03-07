param(
    [string]$RootPath = "J:\",
    [switch]$NoBuild
)

$ErrorActionPreference = "Stop"

$repos = @(
    "https://github.com/cheesebyter/SyncForge.git",
    "https://github.com/cheesebyter/SyncForge.Plugin.MsSql.git",
    "https://github.com/cheesebyter/SyncForge.Configurator.git",
    "https://github.com/cheesebyter/SyncForge.Internal.git",
    "https://github.com/cheesebyter/SyncForge.Workspace.Internal.git"
)

if (-not (Test-Path $RootPath)) {
    throw "RootPath '$RootPath' does not exist."
}

Set-Location $RootPath

foreach ($repo in $repos) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($repo)
    $targetPath = Join-Path $RootPath $name

    if (Test-Path $targetPath) {
        Write-Host "Skip: $name already exists at $targetPath"
        continue
    }

    Write-Host "Cloning $repo ..."
    git clone $repo
}

if (-not $NoBuild) {
    $workspaceRepoPath = Join-Path $RootPath "SyncForge.Workspace.Internal"
    $solutionPath = Join-Path $workspaceRepoPath "SyncForge.Workspace.Internal.slnx"

    if (Test-Path $solutionPath) {
        Write-Host "Building internal workspace solution ..."
        Push-Location $workspaceRepoPath
        dotnet build .\SyncForge.Workspace.Internal.slnx -c Release
        Pop-Location
    }
    else {
        Write-Host "Info: Workspace solution not found at $solutionPath. Skipping build."
    }
}
