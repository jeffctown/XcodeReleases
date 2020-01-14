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
    
    let loader: XcodeReleasesLoader
    var cancellable: AnyCancellable? = nil
    
    public init(loader: XcodeReleasesLoader) {
        self.loader = loader
    }
    
    func refresh() {
        guard cancellable == nil else {
            print("Already Laoding Releases.")
            return
        }
        cancellable = loader.releases.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Error Loading Releases: \(error)")
            case .finished:
                self.cancellable = nil
            }
        }) { releases in
            print("Successfully Loaded \(releases.count) Releases.")
            DispatchQueue.main.async { self.releases = releases }
        }
    }
    
}
