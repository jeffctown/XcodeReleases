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

enum NotificationState {
    case notDetermined
    case provisional(String)
    case authorizing
    case authorized(String)
    case authorizedButDisabled(String)
    case denied
    case deniedButEnabled
}

class AppState: ObservableObject {
    
    @Published var releases: [XcodeRelease] = []
    @Published var pushToken: String? = nil
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var notificationsEnabled: Bool = false
    
    var notificationSetting: AnyPublisher<NotificationState, Never> {
        $notificationsEnabled
            .combineLatest($authorizationStatus, $pushToken)
            .map { (enabled, status, token) -> NotificationState in
                switch status {
                case .authorized:
                    if enabled {
                        return .authorized(token ?? "-1")
                    } else {
                        return .authorizedButDisabled(token ?? "-1")
                    }
                case .denied:
                    if enabled {
                        return .deniedButEnabled
                    } else {
                        return .denied
                    }
                case .notDetermined:
                    if enabled {
                        return .authorizing
                    } else {
                        return .notDetermined
                    }
                case .provisional:
                    return .provisional(token ?? "-1")
                @unknown default:
                    return .notDetermined
                }
        }.eraseToAnyPublisher()
    }

}
