//
//  AchievementsView.swift
//  75DeepSpaceBreath
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var achievementStore: AchievementStore
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(achievementStore.allProgress) { progress in
                        HStack(spacing: 16) {
                            Text(progress.kind.icon)
                                .font(.system(size: 40))
                                .opacity(progress.isUnlocked ? 1 : 0.4)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(progress.kind.title)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(progress.kind.description)
                                    .font(.caption)
                                    .foregroundStyle(DSBTheme.nebula.opacity(0.9))
                                if let date = progress.unlockedAt {
                                    Text("Unlocked \(date, style: .date)")
                                        .font(.caption2)
                                        .foregroundStyle(DSBTheme.accent)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if progress.isUnlocked {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(DSBTheme.accent)
                            }
                        }
                        .padding()
                        .background(DSBTheme.nebula.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(DSBTheme.spaceBackground, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        AchievementsView(achievementStore: AchievementStore(sessionStore: SessionStore()))
    }
}
