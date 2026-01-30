//
//  BreathingSessionView.swift
//  75DeepSpaceBreath
//
//  Unified breathing session with program-specific visualizations.
//

import SwiftUI

struct BreathingSessionView: View {
    let program: BreathingProgram
    var pulseBefore: Int?
    @ObservedObject var sessionStore: SessionStore
    @ObservedObject var achievementStore: AchievementStore
    @ObservedObject var settings: AppSettings
    
    @Environment(\.dismiss) private var dismiss
    @State private var phaseIndex = 0
    @State private var phaseProgress: CGFloat = 0
    @State private var isRunning = false
    @State private var cycleCount = 0
    @State private var timer: Timer?
    @State private var elapsedTimer: Timer?
    @State private var sessionStartDate: Date?
    @State private var elapsedSeconds = 0
    @State private var showCompletion = false
    @State private var pulseAfterText = ""
    @State private var hasSavedSession = false
    
    private var phases: [Int] { program.defaultPhases }
    private var phaseLabels: [String] { program.phaseLabels }
    private var currentPhaseSeconds: Int {
        let base = phases[safe: phaseIndex] ?? phases[0]
        let scaled = Double(base) / settings.tempoMultiplier
        return max(1, Int(round(scaled)))
    }
    private var targetSeconds: Int { settings.sessionDuration.seconds }
    private var isTargetReached: Bool { elapsedSeconds >= targetSeconds }
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            visualizationView
            
            VStack {
                HStack {
                    Spacer()
                    if isRunning {
                        Text("\(elapsedSeconds / 60):\(String(format: "%02d", elapsedSeconds % 60)) / \(targetSeconds / 60) min")
                            .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                    }
                }
                .padding()
                
                Spacer()
                
                if !showCompletion {
                    Text(phaseLabels[safe: phaseIndex] ?? "—")
                        .font(.title2)
                        .foregroundStyle(.white)
                    
                    Text("\(Int((1 - phaseProgress) * CGFloat(currentPhaseSeconds)) + 1)s")
                        .font(.largeTitle)
                        .foregroundStyle(DSBTheme.accent)
                        .monospacedDigit()
                    
                    Button(isRunning ? "Pause" : "Start") {
                        if isRunning { stopTimer() } else {
                            if sessionStartDate == nil { sessionStartDate = Date() }
                            startTimer()
                        }
                        isRunning.toggle()
                    }
                    .font(.headline)
                    .foregroundStyle(DSBTheme.spaceBackground)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(DSBTheme.accent, in: Capsule())
                    .padding(.bottom, 48)
                }
            }
            .overlay {
                if showCompletion {
                    completionOverlay
                }
            }
        }
        .onDisappear {
            stopTimer()
            if sessionStartDate != nil && !hasSavedSession {
                saveSessionAndDismiss(duration: elapsedSeconds)
            }
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Session Complete")
                    .font(.title2)
                    .foregroundStyle(.white)
                Text("\(elapsedSeconds / 60) min")
                    .font(.headline)
                    .foregroundStyle(DSBTheme.accent)
                Text("Pulse after (optional)")
                    .font(.caption)
                    .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                TextField("BPM", text: $pulseAfterText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
                HStack(spacing: 16) {
                    Button("Save & Close") {
                        saveWithPulseAfter()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(DSBTheme.spaceBackground)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(DSBTheme.accent, in: Capsule())
                    Button("Skip") {
                        saveSessionAndDismiss(duration: elapsedSeconds)
                        dismiss()
                    }
                    .foregroundStyle(DSBTheme.accent)
                }
            }
            .padding(32)
            .background(DSBTheme.nebula, in: RoundedRectangle(cornerRadius: 20))
            .padding(40)
        }
    }
    
    private func saveWithPulseAfter() {
        let after = Int(pulseAfterText.trimmingCharacters(in: .whitespaces))
        saveSessionAndDismiss(duration: elapsedSeconds, pulseAfter: after)
    }
    
    private func saveSessionAndDismiss(duration: Int, pulseAfter: Int? = nil) {
        guard !hasSavedSession, let start = sessionStartDate else { dismiss(); return }
        let record = SessionRecord(
            program: program,
            startDate: start,
            durationSeconds: duration,
            pulseBefore: pulseBefore,
            pulseAfter: pulseAfter
        )
        sessionStore.add(record)
        achievementStore.evaluate(sessionStore: sessionStore)
        if settings.remindAfterSessionHours > 0 {
            NotificationManager.shared.scheduleAfterSessionReminder(hoursFromNow: settings.remindAfterSessionHours)
        }
        hasSavedSession = true
    }
    
    @ViewBuilder
    private var visualizationView: some View {
        switch program {
        case .neutronStar:
            NeutronStarVisualization(phaseProgress: phaseProgress, phaseIndex: phaseIndex)
        case .orbitalBalance:
            OrbitalBalanceVisualization(phaseProgress: phaseProgress, phaseIndex: phaseIndex)
        case .expandingNebula:
            ExpandingNebulaVisualization(phaseProgress: phaseProgress, cycleCount: cycleCount)
        case .gravitationalWaves:
            GravitationalWavesVisualization(phaseProgress: phaseProgress, phaseIndex: phaseIndex)
        case .solarCharge:
            SolarChargeVisualization(phaseProgress: phaseProgress, isActive: isRunning)
        }
    }
    
    private func startTimer() {
        if elapsedTimer == nil {
            elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsedSeconds += 1
                if elapsedSeconds >= targetSeconds {
                    stopTimer()
                    isRunning = false
                    showCompletion = true
                }
            }
            RunLoop.main.add(elapsedTimer!, forMode: .common)
        }
        let total = Double(currentPhaseSeconds)
        let step = 1.0 / (total * 10)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            phaseProgress += step
            if phaseProgress >= 1 {
                phaseProgress = 0
                phaseIndex = (phaseIndex + 1) % phases.count
                if phaseIndex == 0 { cycleCount += 1 }
                timer?.invalidate()
                if isRunning && elapsedSeconds < targetSeconds { startTimer() }
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }
}

// MARK: - Neutron Star (4-7-8): compress on inhale, expand on exhale
struct NeutronStarVisualization: View {
    let phaseProgress: CGFloat
    let phaseIndex: Int
    private var scale: CGFloat {
        if phaseIndex == 0 { return 0.5 + phaseProgress * 0.5 }
        if phaseIndex == 1 { return 1.0 }
        return 1.0 - phaseProgress * 0.6
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                let x = CGFloat((i * 37 + 11) % 360) - 180
                let y = CGFloat((i * 23 + 7) % 700) - 350
                Circle()
                    .fill(DSBTheme.accent.opacity(0.3))
                    .frame(width: 4, height: 4)
                    .offset(x: x, y: y)
            }
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DSBTheme.accent, DSBTheme.accent.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(scale)
        }
    }
}

// MARK: - Orbital Balance (5-5-5-5): planet on orbit, each phase = quarter
struct OrbitalBalanceVisualization: View {
    let phaseProgress: CGFloat
    let phaseIndex: Int
    private var angle: Double {
        let quarter = (Double(phaseIndex) + Double(phaseProgress)) * .pi / 2
        return quarter
    }
    
    var body: some View {
        ZStack {
            Ellipse()
                .stroke(DSBTheme.nebula, lineWidth: 2)
                .frame(width: 200, height: 280)
            Circle()
                .fill(DSBTheme.nebula.opacity(0.6))
                .frame(width: 24, height: 24)
                .offset(y: -140)
            Circle()
                .fill(DSBTheme.accent)
                .frame(width: 32, height: 32)
                .shadow(color: DSBTheme.accent.opacity(0.8), radius: 8)
                .offset(x: 100 * cos(angle), y: 140 * sin(angle))
        }
    }
}

// MARK: - Expanding Nebula (4-6-8-10): nebula expands, new stars on exhale
struct ExpandingNebulaVisualization: View {
    let phaseProgress: CGFloat
    let cycleCount: Int
    private var radius: CGFloat { 60 + CGFloat(cycleCount) * 15 + phaseProgress * 40 }
    
    var body: some View {
        ZStack {
            nebulaCircle
            nebulaStars
        }
    }
    
    private var nebulaCircle: some View {
        let r = radius
        return Circle()
            .fill(
                RadialGradient(
                    colors: [DSBTheme.accent.opacity(0.6), DSBTheme.nebula.opacity(0.5), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: r
                )
            )
            .frame(width: r * 2, height: r * 2)
    }
    
    private var nebulaStars: some View {
        ForEach(0..<(5 + cycleCount), id: \.self) { i in
            starView(index: i, radius: radius * 0.8)
        }
    }
    
    private func starView(index: Int, radius: CGFloat) -> some View {
        let angle = Double(index) * 1.2 + Double(phaseProgress) * .pi * 2
        return Circle()
            .fill(DSBTheme.accent.opacity(0.8))
            .frame(width: 6, height: 6)
            .offset(x: cos(angle) * Double(radius), y: sin(angle) * Double(radius))
    }
}

// MARK: - Gravitational Waves: concentric circles
struct GravitationalWavesVisualization: View {
    let phaseProgress: CGFloat
    let phaseIndex: Int
    
    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                let delay = CGFloat(i) * 0.2 + phaseProgress
                Circle()
                    .stroke(DSBTheme.accent.opacity(0.6 - Double(i) * 0.1), lineWidth: 2)
                    .frame(width: 80 + delay * 120, height: 80 + delay * 120)
            }
        }
    }
}

// MARK: - Solar Charge: sun brightness, flares
struct SolarChargeVisualization: View {
    let phaseProgress: CGFloat
    let isActive: Bool
    private var brightness: CGFloat { isActive ? 0.6 + phaseProgress * 0.4 : 0.5 }
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .opacity(1 - brightness * 0.3)
                .ignoresSafeArea()
            sunCircleWithFlares
        }
    }
    
    private var sunCircleWithFlares: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        DSBTheme.accent,
                        DSBTheme.accent.opacity(0.8),
                        DSBTheme.nebula.opacity(0.5)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                )
            )
            .frame(width: 200, height: 200)
            .scaleEffect(0.8 + brightness * 0.4)
            .overlay { solarFlares }
    }
    
    private var solarFlares: some View {
        ForEach(0..<8, id: \.self) { i in
            Rectangle()
                .fill(DSBTheme.accent.opacity(0.6))
                .frame(width: 4, height: 60)
                .offset(y: -30)
                .rotationEffect(.degrees(Double(i) * 45 + Double(phaseProgress) * 360))
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        BreathingSessionView(
            program: .neutronStar,
            pulseBefore: nil,
            sessionStore: SessionStore(),
            achievementStore: AchievementStore(sessionStore: SessionStore()),
            settings: AppSettings()
        )
    }
}
