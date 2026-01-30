//
//  ActivityCalendarView.swift
//  75DeepSpaceBreath
//
//  Calendar by days: sessions/minutes per day, streak.
//

import SwiftUI

struct ActivityCalendarView: View {
    @ObservedObject var sessionStore: SessionStore
    
    private let weeks = 12
    private let daysPerWeek = 7
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(sessionStore.currentStreakDays)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(DSBTheme.accent)
                            Text("day streak")
                                .font(.subheadline)
                                .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(DSBTheme.nebula.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
                    
                    Text("Last \(weeks * daysPerWeek) days")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    let data = sessionStore.sessionsAndMinutes(byDayInPastDays: weeks * daysPerWeek)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: daysPerWeek), spacing: 4) {
                        ForEach(Array(data.enumerated()), id: \.offset) { _, day in
                            dayCell(count: day.count, minutes: day.minutes)
                        }
                    }
                    .padding(4)
                    .background(DSBTheme.nebula.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
                    
                    HStack(spacing: 16) {
                        legendDot(opacity: 0.2); Text("No session")
                        legendDot(opacity: 0.6); Text("1+ sessions")
                        legendDot(opacity: 1.0); Text("\(minutesLabel(data))")
                    }
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
                    
                    if sessionStore.currentStreakDays > 0 {
                        ShareLink(item: "I've been breathing for \(sessionStore.currentStreakDays) days in a row with Deep Space Breath! Breathe. Recover. Transcend.")
                        {
                            Label("Share streak", systemImage: "square.and.arrow.up")
                                .foregroundStyle(DSBTheme.accent)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
    }
    
    private func dayCell(count: Int, minutes: Int) -> some View {
        let opacity = count == 0 ? 0.2 : min(0.6 + Double(minutes) / 30.0 * 0.4, 1.0)
        return RoundedRectangle(cornerRadius: 4)
            .fill(DSBTheme.accent.opacity(opacity))
            .aspectRatio(1, contentMode: .fit)
    }
    
    private func legendDot(opacity: Double) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(DSBTheme.accent.opacity(opacity))
            .frame(width: 12, height: 12)
    }
    
    private func minutesLabel(_ data: [(date: Date, count: Int, minutes: Int)]) -> String {
        let maxM = data.map(\.minutes).max() ?? 0
        return maxM > 0 ? "Up to \(maxM) min" : "Minutes"
    }
}

#Preview {
    NavigationStack {
        ActivityCalendarView(sessionStore: SessionStore())
    }
}
