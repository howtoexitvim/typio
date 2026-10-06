# Build Typio from source

Use macOS with Xcode and its command-line tools. Both Apple Silicon and Intel
builds are supported. The app uses Xcode's recommended macOS deployment target
(resolved to 11.0 during validation with Xcode 26.3). The vendored library
explicitly targets 11.0; runtime operation on older macOS versions has not
been tested in this audit. No API key,
account, CocoaPods download, or network service is required to build the app;
the empty CocoaPods support project is checked in.

From the repository root:

```bash
bash scripts/build-marisa.sh
bash resources/dictionary/build-binary-trie.sh
bash scripts/build.sh
```

The first step rebuilds the universal static marisa library and native
dictionary tools from the supplied 0.2.6 implementation. The second rebuilds
the trie from its supplied text source. The third builds Typio.app at
`~/.typio/build/release/Typio.app`.

To build both architectures without signing or installing:

```bash
xcodebuild -workspace typio.xcworkspace -scheme typio \
  -configuration Release -destination 'generic/platform=macOS' \
  ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO build
```

For the existing icon regression tests, install Pillow in a Python virtual
environment, then run `python -m unittest discover -s tests -v`.
The removed upstream XCTest suite is not part of Typio; use the Python tests.

`bash scripts/build-and-install.sh` installs the input method in
`/Library/Input Methods` and requests sudo for installation.
`bash scripts/package-pkg.sh` creates `dist/Typio-<version>.pkg`.
Set `INSTALLER_SIGN_IDENTITY` to sign an installer with your own identity.

The package includes LICENSE and THIRD_PARTY_NOTICES.md in the application
Resources folder. The upstream dependency license is also bundled there.

Validation host: macOS 15.7.9, Xcode 26.3. Both architectures compile;
interactive input-method behavior on Intel hardware was not tested.
