//
//  SettingsView.swift
//  75DeepSpaceBreath
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            Form {
                Section {
                    Picker("Session duration", selection: $settings.sessionDuration) {
                        ForEach(SessionDuration.allCases, id: \.rawValue) { d in
                            Text(d.displayName).tag(d)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(DSBTheme.accent)
                    
                    Picker("Tempo", selection: $settings.tempoMultiplier) {
                        ForEach(TempoOption.allCases, id: \.rawValue) { t in
                            Text(t.displayName).tag(t.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(DSBTheme.accent)
                    
                    Toggle("Voice cues", isOn: $settings.voiceCuesEnabled)
                        .tint(DSBTheme.accent)
                    
                    Picker("Last workout (for recommendations)", selection: $settings.lastWorkoutType) {
                        ForEach(WorkoutType.allCases, id: \.rawValue) { w in
                            Text(w.displayName).tag(w)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(DSBTheme.accent)
                } header: {
                    Text("Session")
                        .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                }
                
                Section {
                    Toggle("Reminders", isOn: $settings.remindersEnabled)
                        .tint(DSBTheme.accent)
                        .onChange(of: settings.remindersEnabled) { _, enabled in
                            if enabled { scheduleReminders() }
                            else { NotificationManager.shared.cancelAllReminders() }
                        }
                    if settings.remindersEnabled {
                        DatePicker("Morning", selection: morningBinding, displayedComponents: .hourAndMinute)
                        DatePicker("Evening", selection: eveningBinding, displayedComponents: .hourAndMinute)
                        Picker("Remind after session (hours)", selection: $settings.remindAfterSessionHours) {
                            Text("Off").tag(0)
                            ForEach([2, 4, 6, 8], id: \.self) { h in
                                Text("\(h) h").tag(h)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(DSBTheme.accent)
                    }
                } header: {
                    Text("Reminders")
                        .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                }
                
                Section {
                    HStack {
                        Text("Visual intensity")
                        Slider(value: $settings.visualIntensity, in: 0.5...1.5, step: 0.1)
                            .tint(DSBTheme.accent)
                    }
                } header: {
                    Text("Visuals")
                        .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                }
                
                Section {
                    Button {
                        rateApp()
                    } label: {
                        HStack {
                            Text("Rate us")
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(DSBTheme.accent)
                        }
                    }
                    Button {
                        openURL("https://www.termsfeed.com/live/d312f0bd-cf4e-4db8-9995-bec3a49fcd06")
                    } label: {
                        HStack {
                            Text("Privacy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(DSBTheme.accent)
                        }
                    }
                    Button {
                        openURL("https://www.termsfeed.com/live/191ffaad-7669-41a0-9d29-38cdcca33d96")
                    } label: {
                        HStack {
                            Text("Terms")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(DSBTheme.accent)
                        }
                    }
                } header: {
                    Text("About")
                        .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                }
            }
            .scrollContentBackground(.hidden)
            .foregroundStyle(.white)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
        .onDisappear { scheduleReminders() }
    }
    
    private var morningBinding: Binding<Date> {
        Binding(
            get: {
                var c = Calendar.current
                c.timeZone = TimeZone.current
                return c.date(bySettingHour: settings.morningReminderHour, minute: settings.morningReminderMinute, second: 0, of: Date()) ?? Date()
            },
            set: {
                let h = Calendar.current.component(.hour, from: $0)
                let m = Calendar.current.component(.minute, from: $0)
                settings.morningReminderHour = h
                settings.morningReminderMinute = m
            }
        )
    }
    
    private var eveningBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: settings.eveningReminderHour, minute: settings.eveningReminderMinute, second: 0, of: Date()) ?? Date()
            },
            set: {
                let h = Calendar.current.component(.hour, from: $0)
                let m = Calendar.current.component(.minute, from: $0)
                settings.eveningReminderHour = h
                settings.eveningReminderMinute = m
            }
        )
    }
    
    private func scheduleReminders() {
        guard settings.remindersEnabled else { return }
        NotificationManager.shared.scheduleMorningReminder(hour: settings.morningReminderHour, minute: settings.morningReminderMinute)
        NotificationManager.shared.scheduleEveningReminder(hour: settings.eveningReminderHour, minute: settings.eveningReminderMinute)
    }
    
    private func openURL(_ string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(settings: AppSettings())
    }
}
