//
//  PulseEntry.swift
//  75DeepSpaceBreath
//
//  Manual pulse input — no HealthKit.
//

import Foundation
import Combine

struct PulseEntry: Identifiable, Codable {
    var id: UUID
    var bpm: Int
    var date: Date
    var note: String?
    
    init(id: UUID = UUID(), bpm: Int, date: Date = Date(), note: String? = nil) {
        self.id = id
        self.bpm = bpm
        self.date = date
        self.note = note
    }
}

final class PulseStore: ObservableObject {
    @Published var entries: [PulseEntry] = []
    
    private let key = "DeepSpaceBreath_PulseEntries"
    
    init() {
        load()
    }
    
    func add(bpm: Int, note: String? = nil) {
        let entry = PulseEntry(bpm: bpm, note: note)
        entries.insert(entry, at: 0)
        save()
    }
    
    func remove(_ entry: PulseEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PulseEntry].self, from: data) else { return }
        entries = decoded
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    var latestBPM: Int? {
        entries.first?.bpm
    }
}
