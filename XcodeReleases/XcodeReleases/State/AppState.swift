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
    
    var releases: [XcodeRelease] = [] {
        didSet {
            didChange.send(self)
        }
    }
    
}
