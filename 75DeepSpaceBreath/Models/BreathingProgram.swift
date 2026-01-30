//
//  BreathingProgram.swift
//  75DeepSpaceBreath
//

import SwiftUI

enum BreathingProgram: String, CaseIterable, Identifiable, Codable, Hashable {
    case neutronStar = "neutron_star"
    case orbitalBalance = "orbital_balance"
    case expandingNebula = "expanding_nebula"
    case gravitationalWaves = "gravitational_waves"
    case solarCharge = "solar_charge"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .neutronStar: return "Neutron Star"
        case .orbitalBalance: return "Orbital Balance"
        case .expandingNebula: return "Expanding Nebula"
        case .gravitationalWaves: return "Gravitational Waves"
        case .solarCharge: return "Solar Charge"
        }
    }
    
    var subtitle: String {
        switch self {
        case .neutronStar: return "Intense Recovery"
        case .orbitalBalance: return "Pulse Stabilization"
        case .expandingNebula: return "Deep Relaxation"
        case .gravitationalWaves: return "Stress Relief"
        case .solarCharge: return "Energy Boost"
        }
    }
    
    var description: String {
        switch self {
        case .neutronStar: return "For: After high-intensity workouts (HIIT, sprints). 4-7-8 breathing — inhale 4s, hold 7s, exhale 8s."
        case .orbitalBalance: return "For: After cardio (running, cycling). Square breathing 5-5-5-5 — inhale, hold, exhale, pause, 5 seconds each."
        case .expandingNebula: return "For: After strength training, evening. Progressive breathing 4-6-8-10 — each cycle lengthens the exhale."
        case .gravitationalWaves: return "For: Nervous tension. Wave breathing adapts to your current pulse with irregular rhythms."
        case .solarCharge: return "For: Before workout, morning. Fire breathing — quick short inhales and exhales."
        }
    }
    
    var techniqueSummary: String {
        switch self {
        case .neutronStar: return "4-7-8"
        case .orbitalBalance: return "5-5-5-5"
        case .expandingNebula: return "4-6-8-10"
        case .gravitationalWaves: return "Wave"
        case .solarCharge: return "Fire"
        }
    }
    
    /// Phases in seconds: [inhale, hold, exhale, (optional pause)]
    var defaultPhases: [Int] {
        switch self {
        case .neutronStar: return [4, 7, 8]
        case .orbitalBalance: return [5, 5, 5, 5]
        case .expandingNebula: return [4, 6, 8, 10]
        case .gravitationalWaves: return [4, 4, 6, 2]
        case .solarCharge: return [1, 0, 1, 0]
        }
    }
    
    var phaseLabels: [String] {
        switch self {
        case .neutronStar: return ["Inhale", "Hold", "Exhale"]
        case .orbitalBalance: return ["Inhale", "Hold", "Exhale", "Pause"]
        case .expandingNebula: return ["Inhale", "Hold", "Exhale", "Pause"]
        case .gravitationalWaves: return ["Inhale", "Hold", "Exhale", "Pause"]
        case .solarCharge: return ["Inhale", "Exhale"]
        }
    }
}
