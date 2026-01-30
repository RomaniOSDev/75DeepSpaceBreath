//
//  StatisticsView.swift
//  75DeepSpaceBreath
//
//  Cosmic cardiogram: X = time, Y = pulse. Reduction %, trends.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var sessionStore: SessionStore
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let reduction = sessionStore.reductionInMinutes(5), reduction.hasData {
                        HStack {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundStyle(DSBTheme.accent)
                            Text(reduction.percent >= 0 ? "-\(reduction.percent)% in 5 minutes" : "+\(abs(reduction.percent))% in 5 minutes")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DSBTheme.nebula.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Text("Cosmic Cardiogram")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    if sessionStore.pulseOverTime.isEmpty {
                        Text("Complete sessions with pulse before/after to see your pulse over time.")
                            .font(.subheadline)
                            .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(DSBTheme.nebula.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))
                    } else {
                        CosmicCardiogramView(points: sessionStore.pulseOverTime)
                            .frame(height: 200)
                            .padding()
                            .background(DSBTheme.nebula.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    if let trend = sessionStore.bestDayTrend {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundStyle(DSBTheme.accent)
                            Text(trend)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DSBTheme.nebula.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    ShareLink(item: exportStatsText()) {
                        Label("Share stats", systemImage: "square.and.arrow.up")
                            .foregroundStyle(DSBTheme.accent)
                    }
                    .padding()
                }
                .padding()
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
    }
    
    private func exportStatsText() -> String {
        var lines: [String] = ["Deep Space Breath — Stats", ""]
        lines.append("Sessions: \(sessionStore.sessions.count)")
        lines.append("Current streak: \(sessionStore.currentStreakDays) days")
        if let r = sessionStore.reductionInMinutes(5) {
            lines.append("Last session reduction: \(r.percent)% in 5 min")
        }
        if let t = sessionStore.bestDayTrend {
            lines.append("Trend: \(t)")
        }
        return lines.joined(separator: "\n")
    }
}

struct CosmicCardiogramView: View {
    let points: [(Date, Int)]
    
    private var minBPM: Int { (points.map(\.1).min() ?? 60) - 5 }
    private var maxBPM: Int { (points.map(\.1).max() ?? 100) + 5 }
    private var range: Int { max(maxBPM - minBPM, 1) }
    private var timeRange: TimeInterval {
        guard let first = points.first?.0, let last = points.last?.0 else { return 1 }
        return max(1, last.timeIntervalSince(first))
    }
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                guard points.count >= 2 else { return }
                let firstTime = points[0].0.timeIntervalSince1970
                for (i, pt) in points.enumerated() {
                    let t = pt.0.timeIntervalSince1970 - firstTime
                    let x = (t / timeRange) * Double(w)
                    let y = h - (CGFloat(pt.1 - minBPM) / CGFloat(range)) * h
                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(DSBTheme.accent, lineWidth: 2)
        }
    }
}

#Preview {
    NavigationStack {
        StatisticsView(sessionStore: SessionStore())
    }
}
