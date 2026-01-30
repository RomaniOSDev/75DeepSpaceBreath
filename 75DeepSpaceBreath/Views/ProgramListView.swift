//
//  ProgramListView.swift
//  75DeepSpaceBreath
//

import SwiftUI
import Combine

struct ProgramListView: View {
    @ObservedObject var sessionStore: SessionStore
    @ObservedObject var pulseStore: PulseStore
    @ObservedObject var achievementStore: AchievementStore
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(BreathingProgram.allCases) { program in
                        NavigationLink {
                            ProgramDetailView(
                                program: program,
                                sessionStore: sessionStore,
                                pulseStore: pulseStore,
                                achievementStore: achievementStore,
                                settings: settings
                            )
                        } label: {
                            ProgramRowView(program: program, settings: settings)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Programs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
    }
}

struct ProgramRowView: View {
    let program: BreathingProgram
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(DSBTheme.accent.opacity(0.8))
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(program.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(program.subtitle)
                    .font(.caption)
                    .foregroundStyle(DSBTheme.nebula.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                settings.toggleFavorite(programId: program.id)
            } label: {
                Image(systemName: settings.isFavorite(programId: program.id) ? "star.fill" : "star")
                    .foregroundStyle(settings.isFavorite(programId: program.id) ? DSBTheme.accent : DSBTheme.nebula.opacity(0.8))
            }
            .buttonStyle(.plain)
            
            Image(systemName: "chevron.right")
                .foregroundStyle(DSBTheme.accent)
        }
        .padding()
        .background(DSBTheme.nebula.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        ProgramListView(
            sessionStore: SessionStore(),
            pulseStore: PulseStore(),
            achievementStore: AchievementStore(sessionStore: SessionStore()),
            settings: AppSettings()
        )
    }
}

