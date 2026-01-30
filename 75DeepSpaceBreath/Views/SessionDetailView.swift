//
//  SessionDetailView.swift
//  75DeepSpaceBreath
//
//  Tap a star on the galaxy → date, program, duration, pulse before/after, reduction %.
//

import SwiftUI

struct SessionDetailView: View {
    let session: SessionRecord
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(session.program.title)
                        .font(.title2)
                        .foregroundStyle(DSBTheme.accent)
                    
                    Text(session.startDate, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                    Text(session.startDate, style: .time)
                        .font(.caption)
                        .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                    
                    detailRow("Duration", "\(session.durationSeconds / 60) min")
                    if let before = session.pulseBefore {
                        detailRow("Pulse before", "\(before) BPM")
                    }
                    if let after = session.pulseAfter {
                        detailRow("Pulse after", "\(after) BPM")
                    }
                    if let pct = session.effectivenessPercent {
                        detailRow("Reduction", "-\(pct)%")
                            .foregroundStyle(DSBTheme.accent)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
    }
    
    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(DSBTheme.nebula.opacity(0.9))
            Spacer()
            Text(value)
                .foregroundStyle(.white)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: SessionRecord(
            program: .neutronStar,
            durationSeconds: 600,
            pulseBefore: 88,
            pulseAfter: 72
        ))
    }
}
