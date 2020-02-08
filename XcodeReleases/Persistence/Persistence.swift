//
//  Persistence.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 1/17/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

import Foundation
import XCModel

struct Persistence {
    @UserDefault("serverUserPushIdentifier", defaultValue: nil)
    var serverUserPushIdentifier: String?
    @UserDefault("serverPKPushIdentifier", defaultValue: nil)
    var serverPKPushIdentifier: String?
    @UserDefault("latestReleaseJson", defaultValue: nil)
    var latestReleaseJson: String?
    var latestRelease: Xcode? {
        get {   
            guard let latestReleaseJson = self.latestReleaseJson else {
                print("No Latest Release Json Found.")
                return nil
            }
            return latestReleaseJson.toRelease()
        }
        set {
            guard let json = newValue?.toJsonString() else {
                print("No JSON String created from \(String(describing: newValue) )")
                return
            }
            self.latestReleaseJson = json
        }
        
    }
}

extension String {
    func toRelease() -> Xcode? {
        do {
            guard let releaseData = self.data(using: .utf8) else {
                print("Error Converting Release JSON To Data.")
                return nil
            }
            return try JSONDecoder().decode(Xcode.self, from: releaseData)
        } catch {
            print("Error Decoding into Release.")
            return nil
        }
    }
}

extension Xcode {
    func toJsonString() -> String? {
        do {
            let data = try JSONEncoder().encode(self)
            return String(bytes: data, encoding: .utf8)
        } catch {
            print("Error Encoding \(String(describing: self))")
            return nil
        }
    }
}
