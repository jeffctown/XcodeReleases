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
    
    let appState: AppState
    var authorizationStatus = CurrentValueSubject<UNAuthorizationStatus, Never>(.notDetermined)
    private let api = XcodeReleasesApi()
    
    @UserDefault("pushIdentifier", defaultValue: nil)
    var pushIdentifier: Int?
    
    var launchNotification: [AnyHashable: Any]? = nil {
        didSet {
            print("Notification Received! \(launchNotification.debugDescription)")
            self.handle()
        }
    }
    
    init(appState: AppState) {
        self.appState = appState
        super.init()
    }
    
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
    
    func register() {
        print("NON Provisionally Registering For Push Notifications.")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("UNUserNotificationCenter Authorized: \(granted)")
            if let error = error {
                print("UNUserNotificationCenter Error: \(error)")
            }
            self.checkAuthorizationStatus()
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
        #if DEBUG
        let type = "Jeff's \(UIDevice.modelName))"
        let environment = Device.Environment.debug
        #else
        let type = UIDevice.modelName
        let environment = Device.Environment.production
        #endif
        let device = Device(type: type, token: token, environment: environment)
        if let pushIdentifier = pushIdentifier {
            device.id = pushIdentifier
            register()
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
    
    func handle() {
        guard let extra = launchNotification?["extra"] as? [AnyHashable: Any] else {
            print("No Extra Found In Push UserInfo.")
            return
        }
        guard let releaseNotesUrl = extra["notes"] as? String else {
            print("No Release Notes URL Found In Push Notification.")
            return
        }

        self.handle(urlString: releaseNotesUrl)
    }
    
    private func handle(urlString: String) {
        print(urlString)
        UIApplication.shared.connectedScenes.forEach { (scene) in
            (scene.delegate as? SceneDelegate)?.deeplink(urlString: urlString)
        }
        self.launchNotification = nil
    }
    
}

extension UserNotifications: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        launchNotification = response.notification.request.content.userInfo
        print(response.notification.request.content.userInfo)
        completionHandler()
    }
}
