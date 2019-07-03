//
//  File.swift
//  
//
//  Created by Jeff Lett on 7/3/19.
//

import Foundation

public struct XcodeRelease: Codable {
    public let name: String
    public let date: Date
    public let version: Version
    public let requires: String
    public let sdks: SDKs?
    public let links: Links?
    
    public init(name: String, date: Date, version: Version, requires: String, sdks: SDKs?, links: Links? = nil) {
        self.name = name
        self.date = date
        self.version = version
        self.requires = requires
        self.sdks = sdks
        self.links = links
    }
}
