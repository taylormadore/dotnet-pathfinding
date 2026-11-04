#!/usr/bin/env bash
set -euo pipefail

# Allow the supported SDK and include upstream's Windows-only .NET Framework targets.
sed -i 's/"latestFeature"/"latestMajor"/' "$SOURCE_DIR/global.json"
project="$SOURCE_DIR/src/Serilog/Serilog.csproj"
sed -i '/<TargetFrameworks Condition=/s/ Condition="[^"]*"//' "$project"
public_key=$(realpath "$(dirname "${BASH_SOURCE[0]}")/public-key.snk")
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
