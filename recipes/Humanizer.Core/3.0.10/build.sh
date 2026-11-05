#!/usr/bin/env bash
set -euo pipefail

recipe_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$recipe_dir/source.env"
project="$SOURCE_DIR/src/Humanizer/Humanizer.csproj"

# Honor upstream's signed-input policy, without reusing cached restore inputs.
export NUGET_PACKAGES="$SOURCE_DIR/.nuget/packages"
properties=(
    -p:Configuration=Release
    -p:PublicRelease=true
    -p:PublicSign=true
    "-p:AssemblyOriginatorKeyFile=$recipe_dir/public-key.snk"
    # Restore signed NuGet packages instead of unsigned SDK-bundled ILLink.
    "-p:_WorkloadLibraryPacksFolder=$SOURCE_DIR/.no-bundled-packs"
)

# The main build includes the default Roslyn 3.8 analyzer; upstream builds two more.
dotnet build "$project" "${properties[@]}"
dotnet msbuild "$project" -target:BuildAnalyzerVariants "${properties[@]}"

# Pack only Core, rather than upstream's full set of localization packages.
export NuspecProperties="version=3.0.10;RepositoryType=git;RepositoryUrl=$SOURCE_URL;RepositoryCommit=$SOURCE_COMMIT"
dotnet pack "$project" --no-build "${properties[@]}" --output "$OUT_DIR" \
    "-p:NuspecFile=$SOURCE_DIR/NuSpecs/Humanizer.Core.nuspec" \
    "-p:NuspecBasePath=$SOURCE_DIR/src" \
    -p:NoWarn=NU5128

test -f "$OUT_DIR/Humanizer.Core.3.0.10.nupkg"
