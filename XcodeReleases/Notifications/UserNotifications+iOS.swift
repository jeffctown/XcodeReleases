//
//  UserNotifications+iOS.swift
//  Xcode Releases
//
//  Created by Jeff Lett on 1/12/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

#if os(iOS)
import UIKit

extension UserNotifications {
    
    var model: String {
        UIDevice.modelName
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Launch Options: \(launchOptions ?? [:])")
        registerForAppLifecycle()
        launchNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any]
        application.registerForRemoteNotifications()
        return true
    }

    func registerForAppLifecycle() {
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { _ in
            print("App foregrounded, checking authorization status")
            self.checkAuthorizationStatus()
        }.store(in: &cancellables)
    }
    
    func handle(urlString: String) {
        print(urlString)
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            print("Error: No Scene Delegate Found.")
            return
        }
       
        sceneDelegate.deeplink(urlString: urlString)
        self.launchNotification = nil
    }
}
#endif
