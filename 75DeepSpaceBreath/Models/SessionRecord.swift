//
//  SessionRecord.swift
//  75DeepSpaceBreath
//
//  Each session = one star on the galaxy map.
//  Color = program type, brightness = duration, size = effectiveness (pulse reduction).
//

import Foundation
import Combine

struct SessionRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var program: BreathingProgram
    var startDate: Date
    var durationSeconds: Int
    var pulseBefore: Int?
    var pulseAfter: Int?
    var workoutType: WorkoutType?
    
    init(id: UUID = UUID(), program: BreathingProgram, startDate: Date = Date(), durationSeconds: Int, pulseBefore: Int? = nil, pulseAfter: Int? = nil, workoutType: WorkoutType? = nil) {
        self.id = id
        self.program = program
        self.startDate = startDate
        self.durationSeconds = durationSeconds
        self.pulseBefore = pulseBefore
        self.pulseAfter = pulseAfter
        self.workoutType = workoutType
    }
    
    var effectivenessPercent: Int? {
        guard let before = pulseBefore, let after = pulseAfter, before > 0 else { return nil }
        let delta = before - after
        return Int((Double(delta) / Double(before)) * 100)
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case hiit = "hiit"
    case cardio = "cardio"
    case strength = "strength"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .hiit: return "HIIT / Sprints"
        case .cardio: return "Cardio"
        case .strength: return "Strength"
        case .none: return "None"
        }
    }
}

final class SessionStore: ObservableObject {
    @Published var sessions: [SessionRecord] = []
    
    private let key = "DeepSpaceBreath_Sessions"
    
    init() { load() }
    
    func add(_ session: SessionRecord) {
        sessions.insert(session, at: 0)
        save()
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([SessionRecord].self, from: data) {
            sessions = decoded
        }
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    // Pulse over time for cosmic cardiogram: [(date, bpm)]
    var pulseOverTime: [(Date, Int)] {
        var points: [(Date, Int)] = []
        for s in sessions.sorted(by: { $0.startDate < $1.startDate }) {
            if let before = s.pulseBefore { points.append((s.startDate, before)) }
            if let after = s.pulseAfter { points.append((s.startDate.addingTimeInterval(TimeInterval(s.durationSeconds)), after)) }
        }
        return points.sorted { $0.0 < $1.0 }
    }
    
    // Reduction in last N minutes (e.g. "-18% in 5 minutes")
    func reductionInMinutes(_ minutes: Int) -> (percent: Int, hasData: Bool)? {
        let cutoff = Date().addingTimeInterval(-Double(minutes * 60))
        let recent = sessions.filter { $0.startDate.addingTimeInterval(TimeInterval($0.durationSeconds)) >= cutoff }
        guard let session = recent.first, let before = session.pulseBefore, let after = session.pulseAfter, before > 0 else { return nil }
        let pct = Int((Double(before - after) / Double(before)) * 100)
        return (pct, true)
    }
    
    // Best day of week by relaxation (most sessions or best avg reduction)
    var bestDayTrend: String? {
        let calendar = Calendar.current
        var byWeekday: [Int: (count: Int, totalReduction: Int, countWithReduction: Int)] = [:]
        for s in sessions {
            let wd = calendar.component(.weekday, from: s.startDate)
            byWeekday[wd, default: (0, 0, 0)].count += 1
            if let eff = s.effectivenessPercent {
                byWeekday[wd]?.totalReduction += eff
                byWeekday[wd]?.countWithReduction += 1
            }
        }
        guard let best = byWeekday.max(by: { ($0.value.countWithReduction, $0.value.totalReduction) < ($1.value.countWithReduction, $1.value.totalReduction) }) else { return nil }
        let names = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let name = names[best.key]
        return "On \(name)s you relax best"
    }
    
    var currentStreakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var check = calendar.startOfDay(for: Date())
        for _ in 0..<90 {
            let hasSession = sessions.contains { calendar.isDate($0.startDate, inSameDayAs: check) }
            if hasSession { streak += 1 } else { break }
            guard let next = calendar.date(byAdding: .day, value: -1, to: check) else { break }
            check = next
        }
        return streak
    }
    
    func sessionsAndMinutes(byDayInPastDays days: Int) -> [(date: Date, count: Int, minutes: Int)] {
        let calendar = Calendar.current
        var result: [(date: Date, count: Int, minutes: Int)] = []
        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let dayStart = calendar.startOfDay(for: day)
            let daySessions = sessions.filter { calendar.isDate($0.startDate, inSameDayAs: dayStart) }
            let minutes = daySessions.reduce(0) { $0 + $1.durationSeconds / 60 }
            result.append((dayStart, daySessions.count, minutes))
        }
        return result.reversed()
    }
}
