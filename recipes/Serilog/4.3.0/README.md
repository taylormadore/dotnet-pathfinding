# Serilog 4.3.0

Allow SDK roll-forward to .NET 10 and enable both .NET Framework targets on Linux
so the package contains all six official assemblies. Reference packs are restored
by the SDK. Public signing preserves the official assembly identity while avoiding
the full strong-name signing operation rejected by this builder's OpenSSL setup.
See the shared recipe notes for signature-verification limitations.

Upstream sets `LangVersion=latest`: SDK 9 selects C# 13, while our SDK 10 selects
C# 14. Target frameworks stay unchanged, but language rules and generated code can
differ; ApiCompat does not verify runtime behavior. Pinning `LangVersion=13.0`
would preserve upstream's language mode, though not its compiler. This pin has
not been applied or tested.
