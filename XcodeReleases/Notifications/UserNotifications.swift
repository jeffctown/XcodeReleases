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
    
    let api = XcodeReleasesApi()
    private var userNotificationRequestCancellable: AnyCancellable?
    private var pkPushNotificationRequestCancellable: AnyCancellable?
    
    @Published var pushToken: String? = nil
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isSavingNotificationState: Bool = false
    @UserDefault("serverUserPushIdentifier", defaultValue: NSNotFound)
    var serverUserPushIdentifier: Int
    @UserDefault("serverPKPushIdentifier", defaultValue: NSNotFound)
    var serverPKPushIdentifier: Int
    
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
        saveDeviceIfNeeded()
    }
          
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("\(#function) \(error)")
    }
              
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Authorization Status: \(settings.authorizationStatus.rawValue)")
            DispatchQueue.main.async { self.authorizationStatus = settings.authorizationStatus }
            
            switch settings.authorizationStatus {
            case .denied:
                self.deleteDeviceIfNeeded()
            case .authorized:
                self.saveDeviceIfNeeded()
            case .provisional:
                self.saveDeviceIfNeeded()
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
    
    private func device(token: String, pushType: APNS.PushType) -> Device {
        let type = self.model
        switch pushType {
        case .alert:
            return Device(type: type, token: token, bundleIdentifier: InfoPList.bundleIdentifier, environment: environment, pushType: .alert)
        case .complication:
            return Device(type: type, token: token, bundleIdentifier: InfoPList.bundleIdentifier + ".complication", environment: environment, pushType: .complication)
        default:
            assertionFailure("WTF")
        }
        if pushType == .alert {
                
        }
        #if os(watchOS)
        /*InfoPList.bundleIdentifier*/
        //thanks 🍎
        return Device(type: type, token: token, bundleIdentifier: "com.jefflett.XcodeReleases.watchkitapp", environment: environment)
        #else
        return Device(type: type, token: token, bundleIdentifier: InfoPList.bundleIdentifier, environment: environment)
        #endif
    }
    
    // MARK: - App Delegate Callbacks
    
    func savePushRegistryToken(token: String) {
        let device = Device(type: self.model, token: token, bundleIdentifier: "com.jefflett.XcodeReleases.watchkitapp.complication", environment: environment, pushType: .background)
        pkPushNotificationRequestCancellable = saveDevice(device: device) {
            print("Finished Posting PkPush Device.")
        }
    }
    
    func saveDevice(device: Device, completionHandler: @escaping () -> Void) -> AnyCancellable {
        print("Saving Device: \(device)")
        return api.postDevice(device: device).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                completionHandler()
            case .failure(let error):
                print("Error Posting Device: \(error)")
            }
        }) { (device) in
            print("Posted Device To Server. \(device)")
            let id = device.id ?? NSNotFound
            switch device.pushType {
            case .alert:
                self.serverUserPushIdentifier = id
            case .complication:
                self.serverPKPushIdentifier = id
            default:
                assertionFailure("Error: Unsupported Push Type Found!")
            }
        }
    }
    
    func saveDeviceIfNeeded() {
        guard let token = self.pushToken else {
            return print("No Token To Save Device. Skipping.")
        }

        guard self.serverUserPushIdentifier == NSNotFound else {
            return print("Device already saved.  Skipping.")
        }

        guard !self.isSavingNotificationState else {
            return print("Saving notification settings already.  Skipping.")
        }
        
        let device = self.device(token: token, pushType: .alert)
        DispatchQueue.main.async { self.isSavingNotificationState = true }
        userNotificationRequestCancellable = saveDevice(device: device) {
            DispatchQueue.main.async { self.isSavingNotificationState = false }
        }
    }
    
    func deleteDevice(identifier: String, pushType: APNS.PushType) {
        DispatchQueue.main.async { self.isSavingNotificationState = true }
        userNotificationRequestCancellable = api.deleteDevice(id: identifier).sink(receiveCompletion: { completion in
            DispatchQueue.main.async { self.isSavingNotificationState = false }
            switch completion {
            case .finished:
                print("Finished Deleting Device.")
            case .failure(let error):
                print("Error Deleting Device: \(error)")
            }
        }, receiveValue: { (success) in
            if success {
                switch pushType {
                case .alert:
                    self.serverUserPushIdentifier = NSNotFound
                    print("Deleted UN Device From Server.")
                case .complication:
                    self.serverPKPushIdentifier = NSNotFound
                    print("Deleted PK Device From Server.")
                default:
                    assertionFailure("Unhandled Push Type.")
                }
                
            } else {
                print("Failed To Delete Device!")
            }
        })
    }
    
    func deleteDeviceIfNeeded() {
        guard self.serverUserPushIdentifier != NSNotFound else {
            print("No Server Push Identifier Found, not deleting device.")
            return
        }
        guard !self.isSavingNotificationState else {
            print("Already Deleting Device.  Skipping.")
            return
        }
        print("Not Deleting Now.  Continuing to Delete.")

        deleteDevice(identifier: "\(self.serverUserPushIdentifier)", pushType: .alert)
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
