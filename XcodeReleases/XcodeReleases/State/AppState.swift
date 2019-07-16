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
    
    @Published var notificationsEnabled: Bool = false {
        didSet {
            didChange.send(self)
        }
    }
    
    @Published var releases: [XcodeRelease] = [] {
        didSet {
            didChange.send(self)
        }
    }
    
    @Published var pushToken: String? = nil {
        didSet {
            didChange.send(self)
        }
    }
    
    var throttledNotificationSetting: AnyPublisher<Bool, Never> {
        return $notificationsEnabled
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

}
