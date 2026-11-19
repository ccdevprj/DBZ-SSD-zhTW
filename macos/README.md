# Apple Silicon 原生啟動器 / Native macOS launcher
繁體中文化：Ming Liu。支援台灣及香港譯名。需自備遊戲 ROM；不附 ROM、IPS 或 HD 美術包。

On an Apple Silicon Mac, install the Apple Command Line Tools, CMake and Rust 1.99 with the native host target. From the checkout run:

    RUSTUP_TOOLCHAIN=stable bash macos/build.sh

Use stable only if it is Rust 1.99; otherwise specify your installed 1.99 toolchain. The script prints a new Finder app path under target. It builds locally and signs ad hoc, not with Developer ID or notarisation.

Open the app. Choose your own Klepto v1.02 patched English ROM (.sfc/.smc), or Japanese Rev 1 ROM plus dbz102.ips. The engine checks and caches a normalised copy locally. Originals stay unchanged. Enhanced mode offers the Hong Kong and Taiwan translations; Classic mode does not. The launcher does not download game data, HD art, or updates.

Saves, cached ROM and Last Run.log are under ~/Library/Application Support/DBZ SSD RC2. If the cached ROM is damaged, move only cache/rom/canonical.sfc aside before relaunching. Existing translation files are preserved, including local edits. To refresh on upgrade, move the four translation tables and the fonts subdirectory aside. Leave saves and states in place.

Translation tables © Ming, CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/); shared LXGW WenKai TC font: SIL OFL 1.1. See the root README, LICENSE and NOTICE.md for acknowledgements and third-party notices. This launcher contributes no game assets.
