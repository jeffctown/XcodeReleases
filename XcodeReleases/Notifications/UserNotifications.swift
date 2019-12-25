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
    private let api = XcodeReleasesApi()
    
    @UserDefault("serverPushIdentifier", defaultValue: nil)
    var serverPushIdentifier: Int?
    
    var launchNotification: [AnyHashable: Any]? = nil {
        didSet {
            if let _ = launchNotification {
                print("Notification Received! \(launchNotification.debugDescription)")
            }
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
                self.appState.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func register() {
        print("Registering For Push Notifications.")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("UNUserNotificationCenter Authorized: \(granted)")
            if let error = error {
                print("UNUserNotificationCenter Error: \(error)")
            }
            self.checkAuthorizationStatus()
        }
    }
    
    func registerProvisionally() {
        print("*** Provisionally *** Registering For Push Notifications.")
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
        let type = UIDevice.modelName
        #if DEBUG
        let environment = Device.Environment.debug
        #else
        let environment = Device.Environment.production
        #endif
        let device = Device(type: type, token: token, environment: environment)
        if let pushIdentifier = serverPushIdentifier {
            //Set the Device id that it updates the back end instead of creating a new row.
            //TODO: Consider moving this to the server
            device.id = pushIdentifier
            register()
        } else {
            registerProvisionally()
        }
        api.postDevice(device: device) { result in
            switch(result) {
            case let .success(device):
                print("Posted Device To Server. \(device.debugDescription)")
                self.serverPushIdentifier = device.id
            case let .failure(error):
                print("Failed To Post Device: \(error)")
            }
        }
    }
    
    func failedToRegister(error: Error) {
        print("\(#function) \(error)")
    }
    
    func handle() {
        guard let launchNotification = launchNotification else {
            print("Normal Launch (not from a notification).")
            return
        }
        
        guard let extra = launchNotification["extra"] as? [AnyHashable: Any] else {
            print("Notification found, but missing Extra in UserInfo.")
            return
        }
        guard let releaseNotesUrl = extra["notes"] as? String else {
            print("Notification Extra found, but no release notes URL found in UserInfo.")
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
