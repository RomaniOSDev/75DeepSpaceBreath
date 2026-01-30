//
//  GalaxyProgressView.swift
//  75DeepSpaceBreath
//
//  Each session = one star. Tap star → session detail.
//

import SwiftUI

struct GalaxyProgressView: View {
    @ObservedObject var sessionStore: SessionStore
    @State private var selectedSession: SessionRecord?
    
    private let maxDuration: Int = 20 * 60
    private let maxEffectiveness: Int = 50
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Each session is a star on your map. Tap a star for details.")
                        .font(.subheadline)
                        .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                    
                    galaxyMap
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        legendItem(color: DSBTheme.accent, label: "Neutron Star")
                        legendItem(color: Color(hex: "6B8DD6"), label: "Orbital")
                        legendItem(color: Color(hex: "9B59B6"), label: "Nebula")
                        legendItem(color: Color(hex: "1ABC9C"), label: "Waves")
                        legendItem(color: Color(hex: "F1C40F"), label: "Solar")
                    }
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding()
                    
                    Text("Brightness = session length · Size = pulse reduction")
                        .font(.caption)
                        .foregroundStyle(DSBTheme.nebula.opacity(0.8))
                }
                .padding()
            }
        }
        .navigationTitle("Galaxy Progress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
        .navigationDestination(item: $selectedSession) { session in
            SessionDetailView(session: session)
        }
    }
    
    private var galaxyMap: some View {
        GeometryReader { geo in
            let w = geo.size.width - 16
            let h: CGFloat = 320
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(DSBTheme.nebula.opacity(0.4))
                    .frame(width: w, height: h)
                Canvas { context, size in
                    let sw = size.width
                    let sh = size.height
                    for (index, session) in sessionStore.sessions.enumerated() {
                        let x = CGFloat((index * 47 + 13) % 100) / 100 * (sw - 40) + 20
                        let y = CGFloat((index * 31 + 7) % 100) / 100 * (sh - 40) + 20
                        let color = programColor(session.program)
                        let brightness = min(1.0, CGFloat(session.durationSeconds) / CGFloat(maxDuration)) * 0.6 + 0.4
                        let radius = sizeForEffectiveness(session.effectivenessPercent)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                            with: .color(color.opacity(brightness))
                        )
                    }
                }
                .frame(width: w, height: h)
                .padding(8)
                ForEach(Array(sessionStore.sessions.enumerated()), id: \.element.id) { index, session in
                    starTapTarget(index: index, session: session, w: w, h: h)
                }
            }
        }
        .frame(height: 336)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
    
    private func programColor(_ program: BreathingProgram) -> Color {
        switch program {
        case .neutronStar: return DSBTheme.accent
        case .orbitalBalance: return Color(hex: "6B8DD6")
        case .expandingNebula: return Color(hex: "9B59B6")
        case .gravitationalWaves: return Color(hex: "1ABC9C")
        case .solarCharge: return Color(hex: "F1C40F")
        }
    }
    
    private func sizeForEffectiveness(_ percent: Int?) -> CGFloat {
        guard let p = percent, p > 0 else { return 6 }
        return 6 + CGFloat(min(p, maxEffectiveness)) / CGFloat(maxEffectiveness) * 14
    }
    
    private func starTapTarget(index: Int, session: SessionRecord, w: CGFloat, h: CGFloat) -> some View {
        let x = CGFloat((index * 47 + 13) % 100) / 100 * (w - 56) + 28
        let y = CGFloat((index * 31 + 7) % 100) / 100 * (h - 56) + 28
        return Circle()
            .fill(Color.clear)
            .contentShape(Circle())
            .frame(width: 44, height: 44)
            .position(x: x, y: y)
            .onTapGesture { selectedSession = session }
    }
}

#Preview {
    NavigationStack {
        GalaxyProgressView(sessionStore: SessionStore())
    }
}
