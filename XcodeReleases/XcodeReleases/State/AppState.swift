//
//  AppState.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import XcodeReleasesKit

class AppState: BindableObject {
    let didChange = PassthroughSubject<AppState, Never>()
    
    @Published var notificationsEnabled: Bool = false
    
    @Published var releases: [XcodeRelease] = [] {
        didSet {
            didChange.send(self)
        }
    }
    
    var pushToken: String? = nil {
        didSet {
            didChange.send(self)
        }
    }
    
    var launchNotification: [AnyHashable: Any]? = nil {
        didSet {
            didChange.send(self)
        }
    }
    
    func handle(/*userInfo: [AnyHashable: Any]*/) {
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
    }
    
    var userNotifications = UserNotifications()
    
    var throttledNotificationSetting: AnyPublisher<Bool, Never> {
        return $notificationsEnabled
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

}
