# NEXUS · 灵枢工作台

> License: GNU General Public License v3.0 only (GPL-3.0-only). See [LICENSE](LICENSE).

**连接 · 智能 · 掌控未来**

NEXUS is evolving from an AOD-focused prototype into a modular iPhone workspace for device diagnostics, sensor insights, system utilities, and future personalization tools.

## Project identity

- Xcode project: `NEXUS.xcodeproj`
- Xcode target and scheme: `NEXUS`
- iOS app display name: `NEXUS`
- Bundle identifier intentionally retained: `com.aodsmart.controller`

## 0.4.0 — Brand refresh

- New product identity: **NEXUS · 灵枢工作台**
- New orbital-core app icon, rendered from the vector source in `Branding/NEXUS-AppIcon.svg`
- iOS home-screen display name updated to `NEXUS`
- Adaptive Liquid Glass interface retained from 0.3.0
- Future module areas reserved for battery details, in-app Dynamic Island-inspired components, and interactive visual experiences

## Current capabilities

- Proximity sensor status monitoring while the app is active
- Device orientation monitoring via CoreMotion
- AOD decision-state prototype
- Adjustable simulated ambient-light input for algorithm testing
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
3. Run the workflow on `feature/nexus-0.4.0-branding` or `main`.
4. After the run succeeds, download the `NEXUS-0.4.0-unsigned-IPA` artifact.
5. Extract the ZIP and sign `NEXUS-unsigned.ipa` with your own Apple ID using iLoader before installing.

The app keeps its existing bundle identifier, `com.aodsmart.controller`, to preserve continuity with earlier development builds. The app's displayed name and icon are now NEXUS.


## License

NEXUS is distributed under the GNU General Public License, version 3 only (SPDX: GPL-3.0-only), unless a file or component explicitly states otherwise. You may redistribute and modify covered source code under the terms of GPL-3.0. When distributing binaries, comply with the license requirements for providing the corresponding source and required notices. The full license text is in [LICENSE](LICENSE).
