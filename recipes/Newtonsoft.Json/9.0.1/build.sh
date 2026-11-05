#!/usr/bin/env bash
set -euo pipefail

recipe_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
# Reference assemblies only; the compiler and MSBuild still come from SDK 10.
references="$SOURCE_DIR/.portable-references"
git init --quiet "$references"
git -C "$references" remote add origin https://github.com/mono/linux-packaging-referenceassemblies-pcl.git
git -C "$references" fetch --quiet --depth 1 origin 874cf94eeaf35aa267878f9983b280a00e7bed19
git -C "$references" checkout --quiet --detach FETCH_HEAD
mkdir "$SOURCE_DIR/.reference-root"
ln -s ../.portable-references "$SOURCE_DIR/.reference-root/.NETPortable"
# Windows developer packs are absent on Linux; restore their reference DLLs from NuGet.
git -C "$SOURCE_DIR" apply "$recipe_dir/01-framework-references.patch"

# SDK 10 lacks the old portable build targets; use its compiler with the fetched profiles.
git -C "$SOURCE_DIR" apply "$recipe_dir/02-portable-targets.patch"

# SDK 10 cannot build project.json; add an equivalent project for the netstandard1.0 assembly.
git -C "$SOURCE_DIR" apply "$recipe_dir/03-netstandard-project.patch"

# Supply the release versions and package file list normally produced by upstream's script.
git -C "$SOURCE_DIR" apply "$recipe_dir/04-release-package.patch"

cd "$SOURCE_DIR/Src/Newtonsoft.Json"
properties=(
    -p:RestoreSources=https://api.nuget.org/v3/index.json
    -p:LangVersion=6
    -p:RunCodeAnalysis=false
    -p:SignAssembly=true
    -p:PublicSign=true
    "-p:AssemblyOriginatorKeyFile=$recipe_dir/public-key.snk"
)
for target in Net20 Net35 Net40 Net45 Portable Portable40; do
    project="Newtonsoft.Json.$target.csproj"
    constant=${target^^}
    if [[ $target == Net45 ]]; then
        project=Newtonsoft.Json.csproj
        constant=
    fi
    dotnet build "$project" --configuration Release "${properties[@]}" \
        "-p:DefineConstants=TRACE%3BCODE_ANALYSIS%3BSIGNED%3B${constant}"
done

dotnet build Rebuild.NetStandard.csproj --configuration Release "${properties[@]}"
dotnet pack Rebuild.NetStandard.csproj --configuration Release --no-build --output "$OUT_DIR" \
    "-p:NuspecFile=$SOURCE_DIR/Build/Newtonsoft.Json.nuspec" "-p:NuspecBasePath=$SOURCE_DIR"
test -f "$OUT_DIR/Newtonsoft.Json.9.0.1.nupkg"
