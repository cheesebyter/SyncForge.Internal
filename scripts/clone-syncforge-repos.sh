#!/usr/bin/env bash
set -euo pipefail

ROOT_PATH="${1:-$PWD}"
NO_BUILD="${2:-}"

repos=(
  "git@github.com:cheesebyter/SyncForge.git"
  "git@github.com:cheesebyter/SyncForge.Plugin.MsSql.git"
  "git@github.com:cheesebyter/SyncForge.Configurator.git"
  "git@github.com:cheesebyter/SyncForge.Workspace.Internal.git"
)

if [[ ! -d "$ROOT_PATH" ]]; then
  echo "Root path '$ROOT_PATH' does not exist."
  exit 1
fi

cd "$ROOT_PATH"

for repo in "${repos[@]}"; do
  name="$(basename "$repo" .git)"

  if [[ -d "$name" ]]; then
    echo "Skip: $name already exists at $ROOT_PATH/$name"
    continue
  fi

  echo "Cloning $repo ..."
  git clone "$repo"
done

if [[ "$NO_BUILD" != "--no-build" ]]; then
  workspace_repo_path="$ROOT_PATH/SyncForge.Workspace.Internal"
  solution_path="$workspace_repo_path/SyncForge.Workspace.Internal.slnx"

  if [[ -f "$solution_path" ]]; then
    echo "Building internal workspace solution ..."
    (
      cd "$workspace_repo_path"
      dotnet build ./SyncForge.Workspace.Internal.slnx -c Release
    )
  else
    echo "Info: Workspace solution not found at $solution_path. Skipping build."
  fi
fi
