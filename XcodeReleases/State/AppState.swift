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

class AppState: NSObject, ObservableObject {

    init(userNotifications: UserNotifications = UserNotifications(), releasesService: XcodeReleasesService? = nil) {
        self.userNotifications = userNotifications
        self.releasesService = releasesService ?? XcodeReleasesService(api: userNotifications.api)
        self.linksService = LinksService(api: userNotifications.api)
    }

    // MARK: - UI Data

    ///Xcode Releases
    var releasesService: XcodeReleasesService

    // MARK: - Links

    var linksService: LinksService

    // MARK: - Notifications

    var userNotifications: UserNotifications

    #if os(watchOS)
    var pkPushNotifications: PKPushNotifications = PKPushNotifications()
    #endif

    var notificationState: AnyPublisher<NotificationState, Never> {
        userNotifications.$authorizationStatus.combineLatest(userNotifications.$pushToken)
            .map { (status, token) -> NotificationState in
                var notificationState: NotificationState = .notDetermined
                guard let token = token else {
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
                return notificationState
        }.removeDuplicates().eraseToAnyPublisher()
    }
}
