//
//  Achievement.swift
//  75DeepSpaceBreath
//
//  Stable Orbit, Supernova, Black Hole of Calm, Solar Wind.
//

import Foundation
import Combine

enum AchievementKind: String, CaseIterable, Codable {
    case stableOrbit = "stable_orbit"
    case supernova = "supernova"
    case blackHoleOfCalm = "black_hole"
    case solarWind = "solar_wind"
    
    var title: String {
        switch self {
        case .stableOrbit: return "Stable Orbit"
        case .supernova: return "Supernova"
        case .blackHoleOfCalm: return "Black Hole of Calm"
        case .solarWind: return "Solar Wind"
        }
    }
    
    var description: String {
        switch self {
        case .stableOrbit: return "7 days in a row"
        case .supernova: return "Reduce pulse by 25% in one session"
        case .blackHoleOfCalm: return "30 minutes of continuous meditation"
        case .solarWind: return "5 morning sessions in a week"
        }
    }
    
    var icon: String {
        switch self {
        case .stableOrbit: return "🪐"
        case .supernova: return "🌟"
        case .blackHoleOfCalm: return "🌀"
        case .solarWind: return "☀️"
        }
    }
}

struct AchievementProgress: Identifiable {
    let kind: AchievementKind
    var unlockedAt: Date?
    var id: String { kind.rawValue }
    var isUnlocked: Bool { unlockedAt != nil }
}

final class AchievementStore: ObservableObject {
    @Published var progress: [AchievementKind: Date?] = [:]
    
    private let key = "DeepSpaceBreath_Achievements"
    private let sessionStore: SessionStore
    
    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
        load()
    }
    
    func evaluate(sessionStore: SessionStore) {
        var updated = false
        
        // Stable Orbit — 7 days in a row
        if progress[.stableOrbit] ?? nil == nil, checkStableOrbit() {
            progress[.stableOrbit] = Date()
            updated = true
        }
        
        // Supernova — 25% reduction in one session
        if progress[.supernova] ?? nil == nil, sessionStore.sessions.contains(where: { ($0.effectivenessPercent ?? 0) >= 25 }) {
            progress[.supernova] = Date()
            updated = true
        }
        
        // Black Hole of Calm — 30 min continuous
        if progress[.blackHoleOfCalm] ?? nil == nil, sessionStore.sessions.contains(where: { $0.durationSeconds >= 30 * 60 }) {
            progress[.blackHoleOfCalm] = Date()
            updated = true
        }
        
        // Solar Wind — 5 morning sessions in a week
        if progress[.solarWind] ?? nil == nil, checkSolarWind() {
            progress[.solarWind] = Date()
            updated = true
        }
        
        if updated {
            save()
            objectWillChange.send()
        }
    }
    
    private func checkStableOrbit() -> Bool {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        for _ in 0..<14 {
            let hasSession = sessionStore.sessions.contains { calendar.isDate($0.startDate, inSameDayAs: checkDate) }
            if hasSession { streak += 1 } else { break }
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        return streak >= 7
    }
    
    private func checkSolarWind() -> Bool {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let morningSessions = sessionStore.sessions.filter { s in
            s.startDate >= weekAgo && calendar.component(.hour, from: s.startDate) < 12
        }
        return morningSessions.count >= 5
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        if let raw = try? JSONDecoder().decode([String: Double].self, from: data) {
            for (k, v) in raw {
                if let kind = AchievementKind(rawValue: k) {
                    progress[kind] = v > 0 ? Date(timeIntervalSince1970: v) : nil
                }
            }
        }
    }
    
    private func save() {
        var raw: [String: Double] = [:]
        for (kind, date) in progress {
            raw[kind.rawValue] = date?.timeIntervalSince1970 ?? 0
        }
        guard let data = try? JSONEncoder().encode(raw) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    var allProgress: [AchievementProgress] {
        AchievementKind.allCases.map { AchievementProgress(kind: $0, unlockedAt: progress[$0] ?? nil) }
    }
}
