//
//  AfterWorkoutView.swift
//  75DeepSpaceBreath
//
//  Just finished a workout? Pick type → recommended program → start session.
//

import SwiftUI

struct AfterWorkoutView: View {
    @ObservedObject var sessionStore: SessionStore
    @ObservedObject var pulseStore: PulseStore
    @ObservedObject var achievementStore: AchievementStore
    @ObservedObject var settings: AppSettings
    
    @State private var selectedWorkout: WorkoutType = .none
    @State private var programToStart: BreathingProgram?
    @State private var showPulseSheet = false
    @State private var pulseBeforeEntered: Int?
    @State private var pendingProgram: BreathingProgram?
    
    private var recommendedProgram: BreathingProgram? {
        switch selectedWorkout {
        case .hiit: return .neutronStar
        case .cardio: return .orbitalBalance
        case .strength: return .expandingNebula
        case .none: return nil
        }
    }
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Just finished a workout?")
                        .font(.title2)
                        .foregroundStyle(.white)
                    
                    Text("Choose your workout type for a recommended breathing session.")
                        .font(.subheadline)
                        .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                    
                    ForEach([WorkoutType.hiit, .cardio, .strength], id: \.rawValue) { w in
                        Button {
                            selectedWorkout = w
                            settings.lastWorkoutType = w
                        } label: {
                            HStack {
                                Text(w.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                if selectedWorkout == w {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(DSBTheme.accent)
                                }
                            }
                            .padding()
                            .background(selectedWorkout == w ? DSBTheme.nebula : DSBTheme.nebula.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if let program = recommendedProgram {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommended: \(program.title)")
                                .font(.headline)
                                .foregroundStyle(DSBTheme.accent)
                            Text(program.subtitle)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                            Button {
                                pendingProgram = program
                                showPulseSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Start Session")
                                }
                                .font(.headline)
                                .foregroundStyle(DSBTheme.spaceBackground)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(DSBTheme.accent, in: RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .background(DSBTheme.nebula.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("After Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
        .sheet(isPresented: $showPulseSheet) {
            PulseBeforeSheet(
                onSave: { bpm in
                    pulseStore.add(bpm: bpm)
                    pulseBeforeEntered = bpm
                    showPulseSheet = false
                    if let p = pendingProgram { programToStart = p; pendingProgram = nil }
                },
                onSkip: {
                    pulseBeforeEntered = nil
                    showPulseSheet = false
                    if let p = pendingProgram { programToStart = p; pendingProgram = nil }
                }
            )
        }
        .navigationDestination(item: $programToStart) { prog in
            BreathingSessionView(
                program: prog,
                pulseBefore: pulseBeforeEntered ?? pulseStore.latestBPM,
                sessionStore: sessionStore,
                achievementStore: achievementStore,
                settings: settings
            )
        }
    }
}

#Preview {
    NavigationStack {
        AfterWorkoutView(
            sessionStore: SessionStore(),
            pulseStore: PulseStore(),
            achievementStore: AchievementStore(sessionStore: SessionStore()),
            settings: AppSettings()
        )
    }
}
