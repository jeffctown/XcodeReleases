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
    @Published var isLoading: Bool = false
    @Published var loadingError: XcodeReleasesKit.XcodeReleasesLoader.Error? = nil
    
    let loader: XcodeReleasesLoader
    var persistence: Persistence
    var cancellable: AnyCancellable? = nil
    
    public init(loader: XcodeReleasesLoader, persistence: Persistence = Persistence()) {
        self.loader = loader
        self.persistence = persistence
    }
    
    func refresh() {
        guard cancellable == nil else {
            print("Already Loading Releases.")
            return
        }
        print("Refreshing Releases...")
        DispatchQueue.main.async { self.isLoading = true }
        cancellable = loader.releases.sink(receiveCompletion: { completion in
            self.cancellable = nil
            switch completion {
            case .failure(let error):
                print("Error Loading Releases: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingError = error
                    self.isLoading = false
                }
            case .finished:
                DispatchQueue.main.async {
                    self.loadingError = nil
                    self.isLoading = false
                }
                break
            }
        }) { releases in
            print("Loaded \(releases.count) Releases.")
            DispatchQueue.main.async {
                self.releases = releases
                self.persistence.latestRelease = releases.first
            }
        }
    }
    
}
