//
//  LinksService.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 1/17/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import XCModel

class LinksService: NSObject, ObservableObject {

    @Published var links: [Link] = []
    @Published var isLoading: Bool = false
    @Published var loadingError: XcodeReleasesApi.ApiError?

    let api: XcodeReleasesApi
    var cancellable: AnyCancellable?

    public init(api: XcodeReleasesApi) {
        self.api = api
    }

    func refresh() {
        guard cancellable == nil else {
            print("Already Loading Links.")
            return
        }
        print("Refreshing Links...")
        DispatchQueue.main.async { self.isLoading = true }
        cancellable = api.getLinks().sink(receiveCompletion: { completion in
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
            }
        }, receiveValue: { links in
            print("Loaded \(links.count) Links.")
            DispatchQueue.main.async { self.links = links }
        })
    }

}
