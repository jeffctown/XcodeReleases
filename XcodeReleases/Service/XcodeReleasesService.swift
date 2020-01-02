//
//  XcodeReleasesService.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import XcodeReleasesKit

class XcodeReleasesService: NSObject, ObservableObject {
    
    @Published var releases: [XcodeRelease] = []
    let loader = XcodeReleasesApi().xcodeReleasesLoader
    var cancellable: AnyCancellable? = nil
    
    func refresh() {
        cancellable = loader.releases.sink(receiveCompletion: { _ in
        }) { releases in
            print("Successfully Loaded \(releases.count) Releases.")
            DispatchQueue.main.async { self.releases = releases }
        }
    }
    
}
