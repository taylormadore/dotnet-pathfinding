#!/usr/bin/env bash
set -euo pipefail

project="$SOURCE_DIR/Dapper/Dapper.csproj"
dotnet restore "$project"
# The pinned checkout is detached; tell upstream versioning this is a release.
dotnet build "$project" --configuration Release --no-restore -p:PublicRelease=true
dotnet pack "$project" --configuration Release --no-build -p:PublicRelease=true --output "$OUT_DIR"

test -f "$OUT_DIR/Dapper.2.1.66.nupkg"
