//
//  DSBTheme.swift
//  75DeepSpaceBreath
//
//  Deep Space Breath — color scheme and shared styles.
//

import SwiftUI

enum DSBTheme {
    /// Deep space background #090F1E
    static let spaceBackground = Color(hex: "090F1E")
    /// Nebula / interface #1A2339
    static let nebula = Color(hex: "1A2339")
    /// Accent / energy #01A2FF
    static let accent = Color(hex: "01A2FF")
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [spaceBackground, nebula.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accent.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var mainScreenGradient: LinearGradient {
        LinearGradient(
            colors: [
                spaceBackground,
                Color(hex: "0D1428"),
                nebula.opacity(0.6),
                spaceBackground
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Card: top lighter, bottom darker — volume
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                nebula.opacity(0.7),
                nebula.opacity(0.45),
                nebula.opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Card border glow
    static var cardBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                accent.opacity(0.5),
                accent.opacity(0.15),
                accent.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Icon circle: inner glow
    static var iconCircleGradient: LinearGradient {
        LinearGradient(
            colors: [
                nebula,
                nebula.opacity(0.8),
                Color(hex: "0F1625")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Soft shadow for cards (offset down = volume)
    static func cardShadow(opacity: Double = 0.4) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        (Color.black.opacity(opacity), 16, 0, 8)
    }
    
    /// Glow shadow for accent elements
    static func accentGlow(radius: CGFloat = 20) -> (color: Color, radius: CGFloat) {
        (accent.opacity(0.35), radius)
    }
    
    /// Vignette / radial darkening at edges
    static var vignetteGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.clear,
                Color.clear,
                spaceBackground.opacity(0.4),
                spaceBackground.opacity(0.7)
            ],
            center: .center,
            startRadius: 80,
            endRadius: 400
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
