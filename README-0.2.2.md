# AOD Smart Controller 0.2.2

This diagnostic update improves the App Group check feedback.

## What changed
- Shows a visible checking state after the button is tapped.
- Separates container authorization from temporary-file read/write verification.
- Displays the last check time and a specific result for each stage.
- Keeps the test confined to the app's own App Group container.
- Does not modify MobileGestalt, SpringBoard, system files, or device capability flags.

## Important
The candidate App Group identifier is `group.com.aodsmart.controller`. The string in the app is not a permission grant. The signed IPA must contain an entitlement for exactly this identifier, and the signing process must preserve it. If iOS returns no container URL, this diagnostic reports that authorization/container access is unavailable; it cannot independently tell whether the cause is a missing entitlement, a mismatched group ID, or signing configuration.

This app does not provide a public API for toggling native SpringBoard AOD. App Group access does not grant that capability.

## Build
GitHub Actions produces an unsigned IPA artifact. It must be signed separately with a compatible signing workflow before installation.
