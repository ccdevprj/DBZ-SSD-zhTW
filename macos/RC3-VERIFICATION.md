# RC3 Apple Silicon verification

Date: 2026-11-20. Source: `49e35362b27a70c540ee245c241c47604cccc2bc`.
The RC3 revision contains the merged native launcher commit `d42444b`.
This is a bounded smoke-test record, not a release certification or full playthrough.

## Passed

- `bash macos/test.sh`: synthetic migration, original-data preservation, stable-directory precedence, translation/font refresh and backup, and save preservation.
- `bash macos/build.sh` using Rust 1.99.0: native arm64 engine and launcher compilation, architecture checks, ad-hoc signature verification and plist validation.
- Private Japanese Rev 1 ROM plus the user's IPS: accepted and normalised to canonical CRC32 `A8CF4F2A`; a 600-frame headless run exited successfully.
- A separate windowed engine smoke run with Enhanced mode and `--lang zh-hk --hd-scale 4` ran without a reported fatal error. Runtime logs reported approximately 48,000 audio samples per second, no dry audio queue and no window frames exceeding 100 ms during the observed intervals. This verifies logged runtime behaviour, not audible output or visual correctness.
- `cargo test --locked -p ssd-app saves::tests -- --test-threads=1`: both save-store tests passed. These check synthetic persistence and read-only-run behaviour, not an interactive game save/load cycle.

## Limits and warning

The local Rust toolchain reported a nonfatal `rust-objcopy` debug-stripping warning because its LLVM dynamic library was absent. The build and signature validation still succeeded. No toolchain changes were made to suppress it.

The computer-use interface did not expose the standalone game executable as an accessible app. Actual Chinese text appearance, window focus, interactive gameplay, agent-run F5/F9 save-state round trips, audible sound, controller input, and first-run launcher dialogs were therefore not verified. Launcher data behaviour was tested synthetically; the engine was started directly with isolated test data. No existing player saves were used or migrated. No claim is made for Intel Macs or older macOS releases.

## Reproduce

Use Rust 1.99 with the Apple Silicon target, Xcode command-line tools and CMake. Keep test data separate from player data. Supply your own ROM and IPS paths.

```sh
bash macos/test.sh
bash macos/build.sh
cargo test --locked -p ssd-app saves::tests -- --test-threads=1
SSD_DATA_DIR="$TEST_DATA" target/aarch64-apple-darwin/release/ssd-recompiled \
  --rom "$ROM" --ips "$IPS" --mode enhanced --lang zh-hk \
  --headless-frames 600 --screenshot "$TEST_DATA/boot.bmp"
SSD_DATA_DIR="$TEST_DATA" target/aarch64-apple-darwin/release/ssd-recompiled \
  --mode enhanced --lang zh-hk --hd-scale 4
```

For language testing, put the supplied translation TSVs and font in the isolated data directory using the same layout as the launcher. Private ROMs, IPS files, caches, screenshots, saves and raw logs are deliberately excluded from this commit.

## Follow-up: player save/load and HD art

- The player reported a successful manual F5/F9 save/load cycle in the isolated RC3 session. This is player-reported, separate from the automated save tests above.
- The first smoke profile had no installed HD base pack or `art-override` directory. `--hd-scale 4` scales the Enhanced picture; it does not supply new character art. The source-only macOS bundle includes neither the external pack nor release-specific overrides.
- The [official upstream v0.3.9 HD art ZIP](https://github.com/JackRushante/DBZ-Super-Saiya-Densetsu-Rust/releases/download/v0.3.9/hd-pack.zip) was verified at 484,121,119 bytes, SHA-256 `e55cb05d4cb98904d4893b3597a90b7259893c34797f3b8e5b5c1cd0b621d4cc`, manifest revision 2 and digest `0EF46E0B`. Its [publisher-documented mirror](https://github.com/lming888/DBZ-Super-Saiya-Densetsu-Rust/releases/tag/hd-pack-v0.3.9) is equivalent when the hash matches.
- The explicit install into a fresh data profile reported 73 portraits, 8,826 poses, 41 map layers and 77 backgrounds. That first command then rejected the incompatible plain screenshot flags, after installation had succeeded.
- A subsequent 600-frame offscreen Metal run using `--hd-scale 4 --ui-snapshot` exited 0, automatically loaded 73 pictures and 8,819 poses from the installed cache, loaded the Hong Kong translation and produced a 1440×900 PNG. This verifies loader behaviour, not the appearance of every in-game replacement.
- Ming's release-specific art overrides and the transformation voice are separate from the base pack and were not staged or verified. Existing sessions and saves were not changed or copied into the HD test profile.

After placing translations/fonts and a private ROM cache into a separate profile, reproduce the HD snapshot with:

```sh
SSD_DATA_DIR="$TEST_DATA" target/aarch64-apple-darwin/release/ssd-recompiled \
  --mode enhanced --lang zh-hk --hd-scale 4 --install-hd-pack "$PACK" \
  --headless-frames 600 --ui-snapshot "$TEST_DATA/hd-boot.png"
```

Subsequent runs detect the installed cache without the install flag. In a normal Enhanced session ensure Options > Video > HD art is enabled.
