//
//  SocialSparkApp.swift
//  SocialSpark
//
//  Created by David Serrao on 9/28/24.
//

import SwiftUI
import UserNotifications

@main
struct SocialSparkApp: App {
    // Use UIApplicationDelegateAdaptor to connect AppDelegate-like behavior
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// AppDelegate for handling notifications
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request permission for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permission granted")
                self.scheduleDailyNotification() // Call the notification scheduling function
            } else {
                print("Permission denied")
            }
        }
        return true
    }
    
    // The scheduleDailyNotification function goes here
    func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Spark some conversations today with your new daily suggestions!"
        content.sound = .default

        // Create a date component for 9 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 9 // 9 AM
        dateComponents.minute = 0

        // Create a trigger that fires every day at 9 AM
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create a request
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

    }
}
