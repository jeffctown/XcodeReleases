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

class UserNotifications: NSObject, ObservableObject {

    let api = XcodeReleasesApi()
    private var userNotificationRequestCancellable: AnyCancellable?
    private var pkPushNotificationRequestCancellable: AnyCancellable?

    @Published var pushToken: String?
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isSavingNotificationState: Bool = false
    @UserDefault("serverUserPushIdentifier", defaultValue: nil)
    var serverUserPushIdentifier: String?
    @UserDefault("serverPKPushIdentifier", defaultValue: nil)
    var serverPKPushIdentifier: String?

    var launchNotification: [AnyHashable: Any]? = nil {
        didSet {
            if launchNotification != nil {
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

    func registerForUserNotifications() {
        print("*** Registering For Push Notifications.")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
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
        let watchAppBundleIdentifier = "com.jefflett.XcodeReleases.watchkitapp"
        switch pushType {
        case .alert:
            #if os(watchOS)
            return Device(id: token, type: type, bundleIdentifier: watchAppBundleIdentifier, environment: environment, pushType: .alert)
            #endif
        case .complication:
            return Device(id: token, type: type, bundleIdentifier: watchAppBundleIdentifier + ".complication", environment: environment, pushType: .complication)
        default:
            assertionFailure("WTF")
        }
        return Device(id: token, type: type, bundleIdentifier: InfoPList.bundleIdentifier, environment: environment, pushType: .alert)
    }

    // MARK: - Saving Devices

    func savePushRegistryToken(token: String) {
        let device = self.device(token: token, pushType: .complication)
        pkPushNotificationRequestCancellable = saveDevice(device: device) {
            print("Finished Posting PkPush Device.")
        }
    }

    func saveDeviceIfNeeded() {
           guard let token = self.pushToken else {
               return print("No Token To Save Device. Skipping.")
           }

           guard self.serverUserPushIdentifier == nil || self.serverUserPushIdentifier != token else {
               return print("Device push token has already been saved and it hasn't changed.  Before: \(serverUserPushIdentifier ?? "nil") Now: \(token) Skipping.")
           }

           let device = self.device(token: token, pushType: .alert)
           DispatchQueue.main.async { self.isSavingNotificationState = true }
           userNotificationRequestCancellable = saveDevice(device: device) {
               DispatchQueue.main.async { self.isSavingNotificationState = false }

           }
       }

    func saveDevice(device: Device, completionHandler: @escaping () -> Void) -> AnyCancellable {
        print("Saving Device: \(device.debugDescription)")
        return api.postDevice(device: device).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Finished Posting Device.")
            case .failure(let error):
                print("Error Posting Device: \(error)")
            }
            completionHandler()
        }) { (device) in
            print("Posted Device To Server. \(device.debugDescription)")
            switch device.pushType {
            case .alert:
                self.serverUserPushIdentifier = device.id
            case .complication:
                self.serverPKPushIdentifier = device.id
            default:
                print("Error: Unsupported Push Type Found!")
                break
            }
        }
    }

    // MARK: - Deleting Devices

    func deleteDeviceIfNeeded() {
        guard let token = self.serverUserPushIdentifier else {
            print("No Server Push Identifier Found, not deleting device.")
            return
        }

        deleteDevice(identifier: token, pushType: .alert)
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
                    self.serverUserPushIdentifier = nil
                    print("Deleted UN Device From Server.")
                case .complication:
                    self.serverPKPushIdentifier = nil
                    print("Deleted PK Device From Server.")
                default:
                    print("Unhandled Push Type.")
                    break
                }

            } else {
                print("Failed To Delete Device!")
            }
        })
    }

    // MARK: - Deep Linking

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
