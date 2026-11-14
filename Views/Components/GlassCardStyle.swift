import SwiftUI

/// GitHub-inspired neutral surface: compact radius, subtle border and no decorative glow.
struct GlassCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(Color(red: 0.075, green: 0.09, blue: 0.12), in: shape)
            .overlay { shape.strokeBorder(Color.white.opacity(0.10), lineWidth: 1) }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 12) -> some View {
        modifier(GlassCardStyle(cornerRadius: cornerRadius))
    }
}
