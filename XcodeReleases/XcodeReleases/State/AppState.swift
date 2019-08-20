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
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var notificationsEnabled: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var releases: [XcodeRelease] = [] {
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var pushToken: String? = nil {
        didSet {
            objectWillChange.send()
        }
    }
    
    var throttledNotificationSetting: AnyPublisher<Bool, Never> {
        return $notificationsEnabled
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

}
