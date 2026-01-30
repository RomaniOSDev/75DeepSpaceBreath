//
//  Recommendation.swift
//  75DeepSpaceBreath
//
//  By time of day, last workout type, history (e.g. "Neutron Star reduced pulse by 22%").
//

import Foundation

struct Recommendation: Identifiable {
    let id = UUID()
    let program: BreathingProgram?
    let message: String
    let isGeneric: Bool
}

struct RecommendationEngine {
    let sessionStore: SessionStore
    
    func recommendation(workoutType: WorkoutType? = nil) -> Recommendation? {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if let workout = workoutType, workout != .none {
            switch workout {
            case .hiit: return Recommendation(program: .neutronStar, message: "After HIIT, try Neutron Star for intense recovery.", isGeneric: false)
            case .cardio: return Recommendation(program: .orbitalBalance, message: "After cardio, Orbital Balance stabilizes your pulse.", isGeneric: false)
            case .strength: return Recommendation(program: .expandingNebula, message: "After strength training, Expanding Nebula for deep relaxation.", isGeneric: false)
            case .none: break
            }
        }
        
        if hour < 12 {
            return Recommendation(program: .solarCharge, message: "Morning: Solar Charge for an energy boost.", isGeneric: false)
        }
        if hour >= 18 {
            return Recommendation(program: .expandingNebula, message: "Evening: Expanding Nebula for deep relaxation.", isGeneric: false)
        }
        
        if let best = bestProgramByHistory() {
            return best
        }
        
        return Recommendation(program: .orbitalBalance, message: "Orbital Balance helps stabilize your pulse anytime.", isGeneric: true)
    }
    
    private func bestProgramByHistory() -> Recommendation? {
        var byProgram: [BreathingProgram: (count: Int, totalReduction: Int)] = [:]
        for s in sessionStore.sessions {
            guard let eff = s.effectivenessPercent, eff > 0 else { continue }
            let cur = byProgram[s.program] ?? (0, 0)
            byProgram[s.program] = (cur.count + 1, cur.totalReduction + eff)
        }
        guard let best = byProgram.max(by: { ($0.value.totalReduction / max(1, $0.value.count)) < ($1.value.totalReduction / max(1, $1.value.count)) }),
              best.value.count > 0 else { return nil }
        let avg = best.value.totalReduction / best.value.count
        return Recommendation(
            program: best.key,
            message: "Last time \(best.key.title) reduced your pulse by \(avg)% on average.",
            isGeneric: false
        )
    }
    
    func recommendationForProgram(_ program: BreathingProgram) -> String? {
        let sessionsForProgram = sessionStore.sessions.filter { $0.program == program }
        guard let last = sessionsForProgram.first, let eff = last.effectivenessPercent else { return nil }
        return "Last time \(program.title) reduced your pulse by \(eff)%."
    }
}
