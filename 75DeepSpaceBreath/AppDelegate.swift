//
//  AppDelegate.swift
//  75DeepSpaceBreath
//
//  Created by Роман Главацкий on 30.01.2026.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationManager.shared.requestAuthorization { _ in }
        scheduleRemindersFromSettings()
        return true
    }
    
    private func scheduleRemindersFromSettings() {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: "DSB_remindersEnabled") else {
            NotificationManager.shared.cancelAllReminders()
            return
        }
        let morningH = defaults.object(forKey: "DSB_morningHour") as? Int ?? 8
        let morningM = defaults.object(forKey: "DSB_morningMinute") as? Int ?? 0
        let eveningH = defaults.object(forKey: "DSB_eveningHour") as? Int ?? 21
        let eveningM = defaults.object(forKey: "DSB_eveningMinute") as? Int ?? 0
        NotificationManager.shared.scheduleMorningReminder(hour: morningH, minute: morningM)
        NotificationManager.shared.scheduleEveningReminder(hour: eveningH, minute: eveningM)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

