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

class AppState: ObservableObject {
    
    @Published var releases: [XcodeRelease] = []
    @Published var pushToken: String? = nil
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isSavingNotificationSettings: Bool = false
    
    var notificationSetting: AnyPublisher<NotificationState, Never> {
        $authorizationStatus
            .combineLatest($pushToken)
            .map { (status, token) -> NotificationState in
                var notificationState: NotificationState = .notDetermined
                guard let token = token else {
                    self.debugPrint(status: status, token: nil, state: .noToken)
                    return .noToken
                }
                switch status {
                case .authorized:
                    notificationState = .authorized(token)
                case .denied:
                    notificationState = .denied
                case .notDetermined:
                    notificationState = .notDetermined
                case .provisional:
                    notificationState = .provisional(token)
                @unknown default:
                    notificationState = .notDetermined
                }
                self.debugPrint(status: status, token: token, state: notificationState)
                return notificationState
        }.eraseToAnyPublisher()
    }
    
    var isSavingNotificationStateToServer: AnyPublisher<Bool, Never> {
        $isSavingNotificationSettings.eraseToAnyPublisher()
    }
    
    func debugPrint(status: UNAuthorizationStatus, token: String?, state: NotificationState) {
        print("   *** \(state) - Status: \(status.rawValue) Token: \(token ?? "nil")")
    }

}
