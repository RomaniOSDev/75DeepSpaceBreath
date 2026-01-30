//
//  AppSettings.swift
//  75DeepSpaceBreath
//
//  Session duration, voice cues, visual intensity.
//

import SwiftUI
import Combine

enum SessionDuration: Int, CaseIterable {
    case five = 5
    case ten = 10
    case fifteen = 15
    case twenty = 20
    
    var displayName: String { "\(rawValue) min" }
    var seconds: Int { rawValue * 60 }
}

final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    private let keyDuration = "DSB_sessionDuration"
    private let keyVoiceCues = "DSB_voiceCues"
    private let keyVisualIntensity = "DSB_visualIntensity"
    private let keyLastWorkout = "DSB_lastWorkout"
    private let keyRemindersEnabled = "DSB_remindersEnabled"
    private let keyMorningHour = "DSB_morningHour"
    private let keyMorningMinute = "DSB_morningMinute"
    private let keyEveningHour = "DSB_eveningHour"
    private let keyEveningMinute = "DSB_eveningMinute"
    private let keyRemindAfterSessionHours = "DSB_remindAfterSessionHours"
    private let keyTempoMultiplier = "DSB_tempoMultiplier"
    private let keyFavorites = "DSB_favorites"
    
    @Published var sessionDuration: SessionDuration
    @Published var voiceCuesEnabled: Bool
    @Published var visualIntensity: Double
    @Published var lastWorkoutType: WorkoutType
    @Published var remindersEnabled: Bool
    @Published var morningReminderHour: Int
    @Published var morningReminderMinute: Int
    @Published var eveningReminderHour: Int
    @Published var eveningReminderMinute: Int
    @Published var remindAfterSessionHours: Int
    @Published var tempoMultiplier: Double
    @Published var favoriteProgramIds: [String]
    
    init() {
        let rawDuration = defaults.object(forKey: keyDuration) as? Int ?? 10
        self.sessionDuration = SessionDuration(rawValue: rawDuration) ?? .ten
        self.voiceCuesEnabled = defaults.object(forKey: keyVoiceCues) as? Bool ?? true
        self.visualIntensity = defaults.object(forKey: keyVisualIntensity) as? Double ?? 1.0
        let rawWorkout = defaults.string(forKey: keyLastWorkout) ?? WorkoutType.none.rawValue
        self.lastWorkoutType = WorkoutType(rawValue: rawWorkout) ?? .none
        self.remindersEnabled = defaults.object(forKey: keyRemindersEnabled) as? Bool ?? false
        self.morningReminderHour = defaults.object(forKey: keyMorningHour) as? Int ?? 8
        self.morningReminderMinute = defaults.object(forKey: keyMorningMinute) as? Int ?? 0
        self.eveningReminderHour = defaults.object(forKey: keyEveningHour) as? Int ?? 21
        self.eveningReminderMinute = defaults.object(forKey: keyEveningMinute) as? Int ?? 0
        self.remindAfterSessionHours = defaults.object(forKey: keyRemindAfterSessionHours) as? Int ?? 0
        self.tempoMultiplier = defaults.object(forKey: keyTempoMultiplier) as? Double ?? 1.0
        self.favoriteProgramIds = defaults.stringArray(forKey: keyFavorites) ?? []
        
        $sessionDuration.sink { [weak self] in self?.defaults.set($0.rawValue, forKey: self?.keyDuration ?? "") }.store(in: &cancellables)
        $voiceCuesEnabled.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyVoiceCues ?? "") }.store(in: &cancellables)
        $visualIntensity.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyVisualIntensity ?? "") }.store(in: &cancellables)
        $lastWorkoutType.sink { [weak self] in self?.defaults.set($0.rawValue, forKey: self?.keyLastWorkout ?? "") }.store(in: &cancellables)
        $remindersEnabled.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyRemindersEnabled ?? "") }.store(in: &cancellables)
        $morningReminderHour.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyMorningHour ?? "") }.store(in: &cancellables)
        $morningReminderMinute.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyMorningMinute ?? "") }.store(in: &cancellables)
        $eveningReminderHour.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyEveningHour ?? "") }.store(in: &cancellables)
        $eveningReminderMinute.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyEveningMinute ?? "") }.store(in: &cancellables)
        $remindAfterSessionHours.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyRemindAfterSessionHours ?? "") }.store(in: &cancellables)
        $tempoMultiplier.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyTempoMultiplier ?? "") }.store(in: &cancellables)
        $favoriteProgramIds.sink { [weak self] in self?.defaults.set($0, forKey: self?.keyFavorites ?? "") }.store(in: &cancellables)
    }
    
    func toggleFavorite(programId: String) {
        if favoriteProgramIds.contains(programId) {
            favoriteProgramIds.removeAll { $0 == programId }
        } else if favoriteProgramIds.count < 2 {
            favoriteProgramIds.append(programId)
        }
    }
    
    func isFavorite(programId: String) -> Bool { favoriteProgramIds.contains(programId) }
}

enum TempoOption: Double, CaseIterable {
    case slow = 0.8
    case normal = 1.0
    case fast = 1.2
    
    var displayName: String {
        switch self {
        case .slow: return "0.8× (slower)"
        case .normal: return "1×"
        case .fast: return "1.2× (faster)"
        }
    }
}
