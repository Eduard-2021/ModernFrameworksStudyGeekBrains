//
//  LocalNotifications.swift
//  MovementMonitoring
//
//  Created by Eduard on 09.06.2022.
//

import UIKit
import UserNotifications

class LocalNotifications {
    
    func initAndSendNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            guard granted else {
                print("Разрешение не получено")
                return
            }
            self.sendNotificatioRequest(
            content: self.makeNotificationContent(),
            trigger: self.makeIntervalNotificatioTrigger()
            )
        }
    }
    
    func makeNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Пора запустить приложение с навигацией"
        content.subtitle = "Уже прошло 1 минута после его закрытия"
        content.body = "Не теряйте время!"
        return content
    }
    
    func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(
        timeInterval: 60,
        repeats: false
        )
    }
    
    func sendNotificatioRequest(
    content: UNNotificationContent,
    trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(
        identifier: "alaram",
        content: content,
        trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
        if let error = error {
        print(error.localizedDescription)
        }
        }
    }
}
