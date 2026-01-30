//
//  OnboardingView.swift
//  75DeepSpaceBreath
//
//  Onboarding — 3 screens. Skip / Next, then Get Started.
//

import SwiftUI

private let onboardingCompletedKey = "DSB_onboardingCompleted"

enum Onboarding {
    static var isCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingCompletedKey) }
    }
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages: [(icon: String, title: String, text: String)] = [
        ("wind", "Breathe", "Choose from 5 breathing programs. Each one is a star system — Neutron Star, Orbital Balance, Expanding Nebula, and more."),
        ("heart.fill", "Track", "Enter your pulse before and after sessions. See your galaxy grow with every session and watch your stats improve."),
        ("sparkles", "Transcend", "Breathe. Recover. Transcend. Set reminders, follow recommendations, and unlock achievements.")
    ]
    
    var body: some View {
        ZStack {
            DSBTheme.spaceBackground
                .ignoresSafeArea()
            DSBTheme.mainScreenGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DSBTheme.accent)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                }
                
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(icon: page.icon, title: page.title, text: page.text)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage ? DSBTheme.accent : DSBTheme.nebula.opacity(0.6))
                            .frame(width: i == currentPage ? 10 : 8, height: i == currentPage ? 10 : 8)
                    }
                }
                .padding(.bottom, 24)
                
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(DSBTheme.spaceBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DSBTheme.accent, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func onboardingPage(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(DSBTheme.nebula.opacity(0.5))
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(DSBTheme.accent.opacity(0.4), lineWidth: 2)
                    .frame(width: 120, height: 120)
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSBTheme.accent, DSBTheme.accent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: DSBTheme.accent.opacity(0.2), radius: 16)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(text)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }
    
    private func completeOnboarding() {
        Onboarding.isCompleted = true
        isPresented = false
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
