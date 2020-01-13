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
import UserNotifications
import XcodeReleasesKit

class UserNotifications: NSObject, ObservableObject {
    
    private let api = XcodeReleasesApi()
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
    
    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Did Register For Remote Notifications With Token: \(token)")
        pushToken = token
        saveDevice()
    }
          
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("\(#function) \(error)")
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
    
    private var environment: APNS.Environment {
        #if DEBUG
        return APNS.Environment.development
        #else
        return APNS.Environment.release
        #endif
    }
    
    private func device(token: String) -> Device {
        let type = self.model
        #if os(watchOS)
        /*InfoPList.bundleIdentifier*/
        //thanks 🍎
        return Device(type: type, token: token, bundleIdentifier: "com.jefflett.XcodeReleases.watchkitapp", environment: environment)
        #else
        return Device(type: type, token: token, bundleIdentifier: InfoPList.bundleIdentifier, environment: environment)
        #endif
    }
    
    // MARK: - App Delegate Callbacks
    
    func saveDevice() {
        guard let token = self.pushToken else {
            return print("No Token To Save Device. Skipping.")
        }

        guard self.serverPushIdentifier == NSNotFound else {
            return print("Device already saved.  Skipping.")
        }

        guard !self.isSavingNotificationState else {
            return print("Saving notification settings already.  Skipping.")
        }
        
        print("Continuing to Save.")
        print("\(#function) token: \(token)")
        DispatchQueue.main.async {
            print("Setting Save to true inside post.")
            self.isSavingNotificationState = true
        }
        notificationRequestCancellable = api.postDevice(device: device(token: token)).sink(receiveCompletion: { error in
            print("Finished Posting Device: \(error)")
            DispatchQueue.main.async { self.isSavingNotificationState = false }
        }) { (device) in
            print("Posted Device To Server. \(device)")
            if let id = device.id {
                print("Saving Server Push Identifier")
                self.serverPushIdentifier = id
            }
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
            print("Finished Deleting Device: \(error)")
        }, receiveValue: { (success) in
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
        
        #if os(iOS)
        self.handle(urlString: releaseNotesUrl)
        #else
        print("NOT HANDLING URL: \(releaseNotesUrl)")
        #endif
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
