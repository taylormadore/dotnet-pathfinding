# Newtonsoft.Json 13.0.3

Build with the supported .NET 10 SDK, allowing major-version roll-forward.
Public signing with the recorded upstream public key preserves assembly identity;
`SIGNED` selects upstream's matching friend-assembly declarations.

Replace upstream cross-framework package validation (whose older suppressions
fail under .NET 10) with the task's strict comparison against official 13.0.3
assemblies for each matching target. No ApiCompat suppressions are applied.
Public signing does not provide a valid upstream signature for legacy consumers
that verify strong-name signatures. Runtime behavior is not tested by ApiCompat.
