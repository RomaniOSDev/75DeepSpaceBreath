//
//  StarfieldBackground.swift
//  75DeepSpaceBreath
//
//  Subtle star field for the main screen.
//

import SwiftUI

struct StarfieldBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Canvas { context, size in
                for i in 0..<80 {
                    let x = CGFloat((i * 73 + 11) % 100) / 100 * (size.width - 20) + 10
                    let y = CGFloat((i * 41 + 19) % 100) / 100 * (size.height - 20) + 10
                    let opacity = Double((i % 3) + 1) * 0.15
                    let radius: CGFloat = i % 3 == 0 ? 1.5 : 1
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                        with: .color(DSBTheme.accent.opacity(opacity))
                    )
                }
            }
            .frame(width: w, height: h)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        DSBTheme.spaceBackground.ignoresSafeArea()
        StarfieldBackground()
    }
}
