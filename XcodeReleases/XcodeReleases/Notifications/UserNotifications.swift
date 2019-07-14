//
//  UserNotifications.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI
import UIKit
import UserNotifications
import XcodeReleasesKit

class UserNotifications: NSObject {
    
    var authorizationStatus = CurrentValueSubject<UNAuthorizationStatus, Never>(.notDetermined)
    private let api = XcodeReleasesApi()
    
    @UserDefault("pushIdentifier", defaultValue: nil)
    var pushIdentifier: Int?
    
    func registerForAppLifecycle() {
        UNUserNotificationCenter.current().delegate = self
        _ = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { _ in
            self.checkAuthorizationStatus()
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Authorization Status: \(settings.authorizationStatus.rawValue)")
            DispatchQueue.main.async {
                self.authorizationStatus.send(settings.authorizationStatus)
            }
        }
    }
    
    func register(completion: @escaping () -> Void) {
        print("NON Provisionally Registering For Push Notifications.")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("UNUserNotificationCenter Authorized: \(granted)")
            if let error = error {
                print("UNUserNotificationCenter Error: \(error)")
            }
            self.checkAuthorizationStatus()
            completion()
        }
    }
    
    func registerProvisionally() {
        print("Provisionally Registering For Push Notifications.")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { (granted, error) in
            print("UNUserNotificationCenter Authorized: \(granted)")
            if let error = error {
                print("UNUserNotificationCenter Error: \(error)")
            }
        }
    }
    
    // MARK: - App Delegate Callbacks
    
    func registeredWithToken(token: String) {
        print("\(#function) token: \(token)")
        let device = Device(type: UIDevice.current.name, token: token)
        if let pushIdentifier = pushIdentifier {
            device.id = pushIdentifier
            register() {}
        } else {
            registerProvisionally()
        }
        api.postDevice(device: device) { result in
            switch(result) {
            case let .success(device):
                print("Posted Device To Server. \(device.debugDescription)")
                self.pushIdentifier = device.id
            case let .failure(error):
                print("Failed To Post Device: \(error)")
            }
        }
    }
    
    func failedToRegister(error: Error) {
        print("\(#function) \(error)")
    }
    
}

extension UserNotifications: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        deepLinkHandler.launchNotification = response.notification.request.content.userInfo
//        deepLinkHandler.handle(/*userInfo: response.notification.request.content.userInfo*/)
        completionHandler()
    }
}
