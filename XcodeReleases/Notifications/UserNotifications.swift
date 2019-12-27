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
    private var cancellables = Set<AnyCancellable>()
    
    @UserDefault("serverPushIdentifier", defaultValue: NSNotFound)
    static var serverPushIdentifier: Int
    
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
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { _ in
            print("App foregrounded, checking authorization status")
            self.checkAuthorizationStatus()
        }.store(in: &cancellables)
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Authorization Status: \(settings.authorizationStatus.rawValue)")
            DispatchQueue.main.async {
                self.appState.authorizationStatus = settings.authorizationStatus
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
            self.checkAuthorizationStatus()
        }
    }
    
    // MARK: - App Delegate Callbacks
    
    func saveDevice() {
        guard let token = self.appState.pushToken else {
            print("No Token To Save Device. Skipping.")
            return
        }
        
        guard Self.serverPushIdentifier == NSNotFound else {
            print("Device already saved.  Skipping.")
            return
        }
        
        guard !self.appState.isSavingNotificationSettings else {
            print("Saving notification settings already.  Skipping.")
            return
        }
        
        print("\(#function) token: \(token)")
        let type = UIDevice.modelName
        #if DEBUG
        let environment = Device.Environment.debug
        #else
        let environment = Device.Environment.production
        #endif
        let device = Device(type: type, token: token, environment: environment)
        if Self.serverPushIdentifier != NSNotFound {
            //Set the Device id that it updates the back end instead of creating a new row.
            //TODO: Consider moving this to the server
            device.id = Self.serverPushIdentifier
            register()
        } else {
            registerProvisionally()
        }
        
        DispatchQueue.main.async {
            self.appState.isSavingNotificationSettings = true
        }
        api.postDevice(device: device) { result in
            DispatchQueue.main.async {
                self.appState.isSavingNotificationSettings = false
            }
            switch(result) {
            case let .success(device):
                print("Posted Device To Server. \(device.debugDescription)")
                if let id = device.id {
                    print("Saving Server Push Identifier")
                    Self.serverPushIdentifier = id
                }
            case let .failure(error):
                print("Failed To Post Device: \(error)")
            }
        }
    }
    
    
    func deleteDeviceIfNeeded() {
        guard Self.serverPushIdentifier != NSNotFound else {
            print("No Server Push Identifier Found, not deleting device.")
            return
        }
        DispatchQueue.main.async {
            self.appState.isSavingNotificationSettings = false
        }
        api.deleteDevice(id: "\(Self.serverPushIdentifier)") { result in
            DispatchQueue.main.async {
                self.appState.isSavingNotificationSettings = false
            }
            switch result {
            case .success(_):
                print("Deleted Device From Server.")
                Self.serverPushIdentifier = NSNotFound
            case .failure(let error):
                print("Failed To Delete Device: \(error)")
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
