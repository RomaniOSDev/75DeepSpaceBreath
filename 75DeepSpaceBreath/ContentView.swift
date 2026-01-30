//
//  ContentView.swift
//  75DeepSpaceBreath
//
//  Start screen — main menu. Cosmic, clean layout.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var pulseStore = PulseStore()
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var achievementStore: AchievementStore
    @StateObject private var settings: AppSettings
    @State private var showOnboarding = !Onboarding.isCompleted
    
    init() {
        let store = SessionStore()
        _sessionStore = StateObject(wrappedValue: store)
        _achievementStore = StateObject(wrappedValue: AchievementStore(sessionStore: store))
        _settings = StateObject(wrappedValue: AppSettings())
    }
    
    private var recommendation: Recommendation? {
        RecommendationEngine(sessionStore: sessionStore).recommendation(workoutType: settings.lastWorkoutType)
    }
    
    private var quickStartPrograms: [BreathingProgram] {
        settings.favoriteProgramIds.compactMap { id in
            BreathingProgram.allCases.first { $0.id == id }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DSBTheme.spaceBackground
                    .ignoresSafeArea()
                DSBTheme.mainScreenGradient
                    .ignoresSafeArea()
                StarfieldBackground()
                    .opacity(0.8)
                Rectangle()
                    .fill(DSBTheme.vignetteGradient)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection
                        recommendationSection
                        quickStartSection
                        menuSections
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .onAppear {
            achievementStore.evaluate(sessionStore: sessionStore)
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 14) {
            Text("Deep Space Breath")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.98),
                            DSBTheme.accent,
                            DSBTheme.accent.opacity(0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: DSBTheme.accent.opacity(0.5), radius: 20)
                .shadow(color: DSBTheme.accent.opacity(0.25), radius: 40)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [DSBTheme.accent, DSBTheme.accent.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 70, height: 3)
            
            Text("Breathe. Recover. Transcend.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.85), .white.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .padding(.top, 32)
        .padding(.bottom, 28)
    }
    
    @ViewBuilder
    private var recommendationSection: some View {
        if let rec = recommendation {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(DSBTheme.accent)
                    Text("Recommendation")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DSBTheme.nebula.opacity(0.95))
                }
                Text(rec.message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineSpacing(4)
                if let program = rec.program {
                    NavigationLink {
                        ProgramDetailView(
                            program: program,
                            sessionStore: sessionStore,
                            pulseStore: pulseStore,
                            achievementStore: achievementStore,
                            settings: settings
                        )
                    } label: {
                        HStack(spacing: 6) {
                            Text("Try \(program.title)")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(DSBTheme.accent)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(DSBTheme.cardGradient)
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(DSBTheme.cardBorderGradient, lineWidth: 1.5)
                }
            )
            .shadow(color: DSBTheme.cardShadow().color, radius: DSBTheme.cardShadow().radius, x: DSBTheme.cardShadow().x * 0.5, y: DSBTheme.cardShadow().y)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    private var quickStartSection: some View {
        if !settings.favoriteProgramIds.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(DSBTheme.accent)
                    Text("Quick start")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DSBTheme.nebula.opacity(0.95))
                }
                HStack(spacing: 10) {
                    ForEach(quickStartPrograms, id: \.id) { program in
                        NavigationLink {
                            ProgramDetailView(
                                program: program,
                                sessionStore: sessionStore,
                                pulseStore: pulseStore,
                                achievementStore: achievementStore,
                                settings: settings
                            )
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12))
                                Text(program.title)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [DSBTheme.nebula, DSBTheme.nebula.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .stroke(DSBTheme.accent.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DSBTheme.nebula.opacity(0.5),
                                    DSBTheme.nebula.opacity(0.3),
                                    DSBTheme.nebula.opacity(0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(DSBTheme.accent.opacity(0.2), lineWidth: 1)
                }
            )
            .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
    
    private var menuSections: some View {
        VStack(alignment: .leading, spacing: 20) {
            menuSection(title: "Start", icon: "wind") {
                mainMenuLink(icon: "figure.run", title: "After Workout", destination: AfterWorkoutView(sessionStore: sessionStore, pulseStore: pulseStore, achievementStore: achievementStore, settings: settings))
                mainMenuLink(icon: "star.circle.fill", title: "Breathing Programs", destination: ProgramListView(sessionStore: sessionStore, pulseStore: pulseStore, achievementStore: achievementStore, settings: settings))
                mainMenuLink(icon: "heart.fill", title: "Pulse", destination: PulseInputView(pulseStore: pulseStore))
            }
            
            menuSection(title: "Progress", icon: "chart.line.uptrend.xyaxis") {
                mainMenuLink(icon: "map.fill", title: "Galaxy Progress", destination: GalaxyProgressView(sessionStore: sessionStore))
                mainMenuLink(icon: "waveform.path.ecg", title: "Statistics", destination: StatisticsView(sessionStore: sessionStore))
                mainMenuLink(icon: "calendar", title: "Activity Calendar", destination: ActivityCalendarView(sessionStore: sessionStore))
                mainMenuLink(icon: "trophy.fill", title: "Achievements", destination: AchievementsView(achievementStore: achievementStore))
            }
            
            menuSection(title: "More", icon: "ellipsis.circle") {
                mainMenuLink(icon: "gearshape.fill", title: "Settings", destination: SettingsView(settings: settings))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func menuSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(DSBTheme.accent.opacity(0.9))
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.leading, 4)
            
            VStack(spacing: 8) {
                content()
            }
        }
    }
    
    private func mainMenuLink<Destination: View>(icon: String, title: String, destination: Destination) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(DSBTheme.iconCircleGradient)
                        .frame(width: 44, height: 44)
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [DSBTheme.accent.opacity(0.5), DSBTheme.accent.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DSBTheme.accent, DSBTheme.accent.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: DSBTheme.accent.opacity(0.2), radius: 8)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DSBTheme.cardGradient)
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DSBTheme.accent.opacity(0.2),
                                    DSBTheme.nebula.opacity(0.6),
                                    Color.black.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
