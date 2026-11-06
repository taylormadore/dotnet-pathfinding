# Humanizer.Core 3.0.10

Build four library targets and three analyzer variants (Roslyn 3.8, 4.8, 4.14),
then pack only the upstream Core nuspec. Full Git history and `PublicRelease=true`
let upstream's versioning produce the release version. Its SDK 10 selection works
unchanged with our builder.

Upstream requires signed NuGet inputs. Use an isolated restore cache and redirect
`_WorkloadLibraryPacksFolder` away from the SDK's unsigned bundled ILLink package,
so restore obtains the signed package from NuGet. This is an internal SDK property
that needs checking when the builder changes; upstream's trust policy stays intact.

The public key comes from the pinned official package (`979442b78dfc278e`). Public
signing preserves identity, not a valid private-key signature; see the shared notes.
As in upstream's packaging target, suppress NU5128 because the nuspec lacks an
explicit net10.0 dependency group. Keep its published dependency declarations.

The shared compatibility step checks all seven assemblies, including the analyzer
variants. It does not test analyzer diagnostics or runtime behavior.
