//
//  NotificationState.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 12/25/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Foundation

enum NotificationState {
    ///❓
    case notDetermined
    ///provisional (new to 12 i think) notifications don't prompt the user
    case provisional(String)
    ///normal authorized state
    case authorized(String)
    ///denied
    case denied
    ///need to enable in settings
    case noToken
}
