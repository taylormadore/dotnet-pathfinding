# Newtonsoft.Json 9.0.1

Retained as a working legacy-build example for later review. Seven projects build
seven target-specific assemblies with SDK 10 and C# 6, then produce **one**
`Newtonsoft.Json.9.0.1.nupkg`. All seven assemblies passed strict ApiCompat against
the official package without suppressions.

## Required adaptations

`build.sh` applies four patches; each includes its purpose and rationale.

| Patch | Why it is needed |
| --- | --- |
| `01-framework-references.patch` | The four .NET Framework projects are old-style `.csproj` files, not SDK-style. They expect installed targeting packs. This patch enables NuGet restore of Microsoft's reference assemblies for net20, net35, net40, and net45. |
| `02-portable-targets.patch` | SDK 10 lacks the old portable build targets and profile references. Use current C# build targets with Profile259/Profile328 references fetched from a pinned commit of Mono's `linux-packaging-referenceassemblies-pcl` repository. |
| `03-netstandard-project.patch` | Replace the unsupported `project.json` build entry point with an SDK-style project for **netstandard1.0 only**. Preserve its dependency versions and compilation symbols; disable implicit framework references to avoid introducing conflicting dependencies. |
| `04-release-package.patch` | Supply the assembly/file/package versions and package layout normally set by upstream's release script. Collect all seven assemblies and XML documentation while retaining upstream dependency groups. |

Restore uses NuGet.org instead of upstream's unavailable MyGet feed. Legacy code
analysis is disabled. Source code is unchanged except for release-version fields.

## Limitations and follow-up

- A temporary builder with centrally installed Microsoft reference packs built the four original Framework projects unchanged. Patch 01 can be removed if we adopt that builder configuration; the recipe still uses it today.
- Central portable-profile support remains unresolved. The current recipe owns the portable build adaptation; the archive's provenance and suitability as a maintained shared dependency need review. Merely installing reference DLLs does not replace the missing MSBuild targets.
- SDK 2.1's `dotnet migrate` was tested as an onboarding aid. It preserved dependency versions but dropped the .NET Standard target's `PORTABLE` symbol and still needed explicit-reference configuration for SDK 10. Its output is not a drop-in replacement for patch 03.
- Public signing preserves assembly identity but does not produce a valid private-key signature. See the [shared recipe notes](../../README.md). ApiCompat does not establish runtime behavior or dependency-resolution equivalence; upstream tests have not been run for this rebuild.
- Modern NuGet warns about upstream portable dependency-group spelling and legacy package metadata. These are retained. The shared checker must decode URI-escaped paths: the official package uses `%2B` where current NuGet writes `+`.
