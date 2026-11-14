# NEXUS · 灵枢工作台

> License: GNU General Public License v3.0 only (GPL-3.0-only). See [LICENSE](LICENSE).

**连接 · 智能 · 掌控未来**

NEXUS is an iOS 27.2-focused research workspace centered on AOD capability research and a Dynamic Island-inspired in-app experience. Supporting device tools remain separate from these two core tracks.

## Project identity

- Xcode project: `NEXUS.xcodeproj`
- Xcode target and scheme: `NEXUS`
- iOS app display name: `NEXUS`
- Bundle identifier intentionally retained: `com.aodsmart.controller`

## 0.5.2 — AOD sensor integration research

- Added a read-only AOD capability catalog adapted from GestaltX's GPL-3.0-only capability mappings.
- Connected the existing proximity and motion sensor decisions to an AOD safety-policy layer.
- The policy suppresses the in-app AOD preview recommendation when the proximity sensor reports coverage or the device is face-down.
- Sensor readiness is required before the policy reports an active preview state.
- Removed a stale `ambientMotion` reference that prevented the previous build from compiling.
- This release does **not** write MobileGestalt, modify SpringBoard, or enable native system AOD.

## Current capabilities

- Proximity sensor status monitoring while the app is active
- Device orientation monitoring via CoreMotion
- Sensor-driven AOD decision-state prototype
- Adjustable simulated ambient-light input for algorithm testing (not a hardware lux reading)
- Read-only GestaltX AOD capability-key catalog
- Read-only device capability and App Group diagnostics

## Important platform boundaries

- A normal third-party IPA has no public API to enable or control SpringBoard's native Always-On Display.
- iPhone 13 Pro Max does not have the 1 Hz LTPO display hardware used by iPhone 14 Pro AOD.
- iOS does not provide a general public API for reading ambient-light lux values.
- Sensor monitoring is not guaranteed to continue while the app is backgrounded or the device is locked.
- Battery level and charging state can be explored through public APIs; battery health and cycle-count access are restricted.
- A Dynamic Island-inspired interface can be built inside NEXUS, but an app cannot replace the system Dynamic Island. iPhone 13 Pro Max has no Dynamic Island hardware.
- Dynamic visual scenes can be shown inside the app; a normal IPA cannot replace the iOS Lock Screen wallpaper engine.

## Build on GitHub

The GitHub Actions workflow runs on a macOS runner and creates an **unsigned IPA**:

1. Open the repository's **Actions** tab.
2. Select **Build NEXUS Workspace IPA**.
3. Run the workflow on `feature/nexus-0.5.2-aod-sensor-integration` or `main`.
4. After the run succeeds, download the `NEXUS-0.5.2-unsigned-IPA` artifact.
5. Extract the ZIP and sign `NEXUS-0.5.2-unsigned.ipa` with your own Apple ID using iLoader before installing.

The app keeps its existing bundle identifier, `com.aodsmart.controller`, to preserve continuity with earlier development builds. The app's displayed name and icon are now NEXUS.


## License

NEXUS is distributed under the GNU General Public License, version 3 only (SPDX: GPL-3.0-only), unless a file or component explicitly states otherwise. You may redistribute and modify covered source code under the terms of GPL-3.0. When distributing binaries, comply with the license requirements for providing the corresponding source and required notices. The full license text is in [LICENSE](LICENSE).
