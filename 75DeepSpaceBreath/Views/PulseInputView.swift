//
//  PulseInputView.swift
//  75DeepSpaceBreath
//
//  Manual pulse input — no HealthKit.
//

import SwiftUI

struct PulseInputView: View {
    @ObservedObject var pulseStore: PulseStore
    @State private var bpmText = ""
    @State private var noteText = ""
    @State private var showSaved = false
    
    private var bpm: Int? {
        guard !bpmText.isEmpty, let v = Int(bpmText), v >= 30, v <= 250 else { return nil }
        return v
    }
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Enter your pulse (BPM)")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    TextField("BPM (30–250)", text: $bpmText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(DSBTheme.nebula, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                    
                    TextField("Note (optional)", text: $noteText)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(DSBTheme.nebula, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Button {
                        guard let bpm = bpm else { return }
                        pulseStore.add(bpm: bpm, note: noteText.isEmpty ? nil : noteText)
                        bpmText = ""
                        noteText = ""
                        showSaved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showSaved = false }
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundStyle(DSBTheme.spaceBackground)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(bpm != nil ? DSBTheme.accent : DSBTheme.nebula, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(bpm == nil)
                    .buttonStyle(.plain)
                    
                    if showSaved {
                        Text("Saved")
                            .font(.subheadline)
                            .foregroundStyle(DSBTheme.accent)
                    }
                    
                    if let latest = pulseStore.latestBPM {
                        Text("Last: \(latest) BPM")
                            .font(.caption)
                            .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                    }
                    
                    Divider()
                        .background(DSBTheme.nebula)
                    
                    Text("History")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    ForEach(pulseStore.entries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(entry.bpm) BPM")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(entry.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                                if let n = entry.note, !n.isEmpty {
                                    Text(n)
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                            Spacer()
                            Button {
                                pulseStore.remove(entry)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(DSBTheme.accent)
                            }
                        }
                        .padding()
                        .background(DSBTheme.nebula.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Pulse")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        PulseInputView(pulseStore: PulseStore())
    }
}
