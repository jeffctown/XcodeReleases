//
//  SDKs.swift
//  
//
//  Created by Jeff Lett on 7/3/19.
//

import Foundation

public struct SDKs: Codable, Equatable {
    public let macOS: [Version]?
    public let tvOS: [Version]?
    public let iOS: [Version]?
    public let watchOS: [Version]?
    
    public init(macOS: [Version], tvOS: [Version], iOS: [Version], watchOS: [Version]) {
        self.macOS = macOS
        self.tvOS = tvOS
        self.iOS = iOS
        self.watchOS = watchOS
    }
    
    public var count: Int {
        let macOSSDKs = self.macOS?.count ?? 0
        let iOSSDKs = self.iOS?.count ?? 0
        let tvOSSDKs = self.tvOS?.count ?? 0
        let watchOSSDKs = self.watchOS?.count ?? 0
        return macOSSDKs + iOSSDKs + tvOSSDKs + watchOSSDKs
    }
    
}
