# AOD Smart Controller 0.3.0 — Adaptive UI

## Interface updates
- Responsive dashboard layout: compact single-column layout on phone-sized widths and a two-column card grid on wider layouts.
- Content width is capped on larger screens to preserve readable line lengths.
- Reusable `GlassCardStyle` component applies native SwiftUI Liquid Glass on iOS 26+ and a material-based fallback on older supported iOS versions.
- Dashboard sections are modular, making it easier to add future feature cards without rebuilding the overall layout.
- Adds clearly marked roadmap placeholders for battery details, an iPhone 13 Pro Max-oriented in-app Dynamic Island-style component, and interactive wallpaper concepts.

## Scope and limitations
The roadmap items are placeholders, not working features. A third-party app cannot replace the system Dynamic Island or set the system wallpaper through ordinary public APIs; future implementations must be scoped as in-app experiences and use supported APIs. Battery information will be limited to values exposed by public iOS APIs.

## Build
GitHub Actions is configured to create an unsigned IPA artifact. The artifact must be signed separately before installation. A successful build has to be confirmed from the corresponding Actions run.
