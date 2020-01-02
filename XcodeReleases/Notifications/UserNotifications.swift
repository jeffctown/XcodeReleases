//
//  UserNotifications.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import APNS
import Combine
import SwiftUI
import UIKit
import UserNotifications
import XcodeReleasesKit

class UserNotifications: NSObject, ObservableObject {
    
    private let api = XcodeReleasesApi()
    private var cancellables = Set<AnyCancellable>()
    private var notificationRequestCancellable: AnyCancellable?
    
    @Published var pushToken: String? = nil
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isSavingNotificationState: Bool = false
    @UserDefault("serverPushIdentifier", defaultValue: NSNotFound)
    var serverPushIdentifier: Int
    
    var launchNotification: [AnyHashable: Any]? = nil {
        didSet {
            if let _ = launchNotification {
                print("Notification Received! \(launchNotification.debugDescription)")
            }
            self.handle()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Launch Options: \(launchOptions ?? [:])")
        registerForAppLifecycle()
        launchNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any]
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        pushToken = token
        saveDevice()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(#function) \(error)")
    }
    
    func registerForAppLifecycle() {
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { _ in
            print("App foregrounded, checking authorization status")
            self.checkAuthorizationStatus()
        }.store(in: &cancellables)
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Authorization Status: \(settings.authorizationStatus.rawValue)")
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
            
            switch settings.authorizationStatus {
            case .denied:
                self.deleteDeviceIfNeeded()
            case .authorized:
                self.saveDevice()
            case .provisional:
                self.saveDevice()
            default:
                break
            }
        }
    }
    
    func registerProvisionally() {
        print("*** Provisionally *** Registering For Push Notifications.")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { (granted, error) in
            print("UNUserNotificationCenter Authorized: \(granted)")
            if let error = error {
                print("UNUserNotificationCenter Error: \(error)")
            }
            self.checkAuthorizationStatus()
        }
    }
    
    // MARK: - App Delegate Callbacks
    
    func saveDevice() {
        guard let token = self.pushToken else {
            print("No Token To Save Device. Skipping.")
            return
        }

        guard self.serverPushIdentifier == NSNotFound else {
            print("Device already saved.  Skipping.")
            return
        }

        guard !self.isSavingNotificationState else {
            print("Saving notification settings already.  Skipping.")
            return
        }
        print("Not Saving Now.  Continuing to Save.")

        print("\(#function) token: \(token)")
        let type = UIDevice.modelName
        #if DEBUG
        let environment = Device.Environment.debug
        #else
        let environment = Device.Environment.production
        #endif
        let device = Device(type: type, token: token, environment: environment)
        DispatchQueue.main.async {
            print("Setting Save to true inside post.")
            self.isSavingNotificationState = true
        }
        self.registerProvisionally()
        notificationRequestCancellable = api.postDevice(device: device).sink(receiveCompletion: { error in
            print("Failed To Post Device: \(error)")
            DispatchQueue.main.async { self.isSavingNotificationState = false }
        }) { (device) in
            print("Posted Device To Server. \(device.debugDescription)")
            if let id = device.id {
                print("Saving Server Push Identifier")
                self.serverPushIdentifier = id
            }
            DispatchQueue.main.async { self.isSavingNotificationState = false }
        }
    }
    
    func deleteDeviceIfNeeded() {
        guard self.serverPushIdentifier != NSNotFound else {
            print("No Server Push Identifier Found, not deleting device.")
            return
        }
        guard !self.isSavingNotificationState else {
            print("Already Deleting Device.  Skipping.")
            return
        }
        print("Not Deleting Now.  Continuing to Delete.")

        DispatchQueue.main.async {
            print("Setting Save to true inside delete.")
            self.isSavingNotificationState = true
        }
        notificationRequestCancellable = api.deleteDevice(id: "\(self.serverPushIdentifier)").sink(receiveCompletion: { error in
            DispatchQueue.main.async { self.isSavingNotificationState = false }
            print("Failed To Delete Device: \(error)")
        }, receiveValue: { (success) in
            DispatchQueue.main.async { self.isSavingNotificationState = false }
            if success {
                print("Deleted Device From Server.")
                self.serverPushIdentifier = NSNotFound
            } else {
                print("Failed To Delete Device!")
            }
        })
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
