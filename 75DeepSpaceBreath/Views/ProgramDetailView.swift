//
//  ProgramDetailView.swift
//  75DeepSpaceBreath
//

import SwiftUI

struct ProgramDetailView: View {
    let program: BreathingProgram
    @ObservedObject var sessionStore: SessionStore
    @ObservedObject var pulseStore: PulseStore
    @ObservedObject var achievementStore: AchievementStore
    @ObservedObject var settings: AppSettings
    
    @State private var showPulseBeforeSheet = false
    @State private var programToStart: BreathingProgram?
    @State private var pulseBeforeEntered: Int?
    @State private var pendingStartProgram: BreathingProgram?
    
    private var recommendationEngine: RecommendationEngine { RecommendationEngine(sessionStore: sessionStore) }
    private var hasRecentPulse: Bool {
        guard let last = pulseStore.entries.first else { return false }
        return Date().timeIntervalSince(last.date) < 30 * 60
    }
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let message = recommendationEngine.recommendationForProgram(program) {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(DSBTheme.accent)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DSBTheme.nebula.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Text(program.description)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text("Technique: \(program.techniqueSummary)")
                        .font(.subheadline)
                        .foregroundStyle(DSBTheme.accent)
                    
                    Text("Duration: \(settings.sessionDuration.displayName)")
                        .font(.caption)
                        .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                    
                    Button {
                        if hasRecentPulse {
                            pulseBeforeEntered = pulseStore.latestBPM
                            programToStart = program
                        } else {
                            pendingStartProgram = program
                            showPulseBeforeSheet = true
                        }
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
            }
        }
        .navigationTitle(program.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
        .sheet(isPresented: $showPulseBeforeSheet) {
            PulseBeforeSheet(
                onSave: { bpm in
                    pulseStore.add(bpm: bpm)
                    pulseBeforeEntered = bpm
                    showPulseBeforeSheet = false
                    if let p = pendingStartProgram { programToStart = p; pendingStartProgram = nil }
                },
                onSkip: {
                    pulseBeforeEntered = nil
                    showPulseBeforeSheet = false
                    if let p = pendingStartProgram { programToStart = p; pendingStartProgram = nil }
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

struct PulseBeforeSheet: View {
    @State private var bpmText = ""
    let onSave: (Int) -> Void
    let onSkip: () -> Void
    
    private var bpm: Int? {
        guard !bpmText.isEmpty, let v = Int(bpmText), v >= 30, v <= 250 else { return nil }
        return v
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DSBTheme.spaceBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("Enter current pulse (optional)")
                        .font(.headline)
                        .foregroundStyle(.white)
                    TextField("BPM (30–250)", text: $bpmText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 16) {
                        Button("Skip") { onSkip() }
                            .foregroundStyle(DSBTheme.accent)
                        Button("Save & Start") {
                            if let b = bpm { onSave(b) }
                            else { onSkip() }
                        }
                        .font(.headline)
                        .foregroundStyle(DSBTheme.spaceBackground)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(bpm != nil ? DSBTheme.accent : DSBTheme.nebula, in: Capsule())
                        .disabled(bpm == nil)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        ProgramDetailView(
            program: .neutronStar,
            sessionStore: SessionStore(),
            pulseStore: PulseStore(),
            achievementStore: AchievementStore(sessionStore: SessionStore()),
            settings: AppSettings()
        )
    }
}
