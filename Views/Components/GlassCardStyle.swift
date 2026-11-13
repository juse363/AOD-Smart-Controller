import SwiftUI

/// Shared visual surface for feature cards.
/// Uses native Liquid Glass on supported systems and a material fallback on older iOS.
struct GlassCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        Group {
            if #available(iOS 26.0, *) {
                content
                    .background(.ultraThinMaterial.opacity(0.42), in: shape)
                    .overlay {
                        shape.strokeBorder(.white.opacity(0.14), lineWidth: 1)
                    }
                    .glassEffect(.regular, in: shape)
            } else {
                content
                    .background(.ultraThinMaterial, in: shape)
                    .overlay {
                        shape.strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    }
            }
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassCardStyle(cornerRadius: cornerRadius))
    }
}
