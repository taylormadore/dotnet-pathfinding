#!/usr/bin/env bash
set -euo pipefail

# Use the supported builder SDK; see README.md for the compatibility policy.
sed -i 's/"latestFeature"/"latestMajor"/' "$SOURCE_DIR/Src/global.json"
public_key=$(realpath "$(dirname "${BASH_SOURCE[0]}")/public-key.snk")
cd "$SOURCE_DIR/Src"
project=Newtonsoft.Json/Newtonsoft.Json.csproj
# Upstream's release script supplies these instead of the project defaults.
properties=(
    -p:Version=13.0.3
    -p:AssemblyVersion=13.0.0.0
    -p:FileVersion=13.0.3.0
    -p:IncludeSymbols=false
    -p:SignAssembly=true
    -p:PublicSign=true
    "-p:AssemblyOriginatorKeyFile=$public_key"
    -p:AdditionalConstants=SIGNED
    # The following task step compares against the official same-version package.
    -p:EnablePackageValidation=false
)
dotnet restore "$project" "${properties[@]}"
dotnet build "$project" --configuration Release --no-restore "${properties[@]}"
dotnet pack "$project" --configuration Release --no-build "${properties[@]}" --output "$OUT_DIR"

test -f "$OUT_DIR/Newtonsoft.Json.13.0.3.nupkg"
