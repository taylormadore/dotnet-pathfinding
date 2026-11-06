#!/usr/bin/env bash
set -euo pipefail

recipe_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
# Allow the supported builder SDK.
git -C "$SOURCE_DIR" apply "$recipe_dir/01-sdk-roll-forward.patch"
# Include upstream's Windows-only .NET Framework targets on Linux.
git -C "$SOURCE_DIR" apply "$recipe_dir/02-framework-targets.patch"
project="$SOURCE_DIR/src/Serilog/Serilog.csproj"
public_key="$recipe_dir/public-key.snk"
properties=(
    -p:ContinuousIntegrationBuild=true
    -p:IncludeSymbols=false
    -p:SignAssembly=true
    -p:PublicSign=true
    "-p:AssemblyOriginatorKeyFile=$public_key"
)
dotnet restore "$project" "${properties[@]}"
dotnet build "$project" --configuration Release --no-restore "${properties[@]}"
dotnet pack "$project" --configuration Release --no-build "${properties[@]}" --output "$OUT_DIR"

test -f "$OUT_DIR/Serilog.4.3.0.nupkg"
