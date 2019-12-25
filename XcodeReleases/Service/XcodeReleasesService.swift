//
//  XcodeReleasesService.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Foundation
import SwiftUI
import XcodeReleasesKit

struct XcodeReleasesService {
    @Binding var releases: [XcodeRelease]
    let loader = XcodeReleasesApi().xcodeReleasesLoader
    
    func refresh() {
        loader.releases { (result) in
            switch result {
            case .success(let releases):
                print("Successfully Loaded \(releases.count) Releases.")
                DispatchQueue.main.async {
                    self.releases = releases
                }
            case .failure(let error):
                print("Error Loading Releases: \((error as Error).localizedDescription)")
            }
        }
    }
    
}
