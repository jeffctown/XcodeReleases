//
//  File.swift
//  
//
//  Created by Jeff Lett on 7/3/19.
//

import Foundation

public struct XcodeRelease: Codable, Equatable {
    public var id: Int?
    public let name: String
    public let date: Date
    public let version: Version
    public let requires: String
    public let sdks: SDKs?
    public let links: Links?

    public init(name: String, date: Date, version: Version, requires: String, sdks: SDKs?, links: Links? = nil) {
        self.name = name
        self.id = "\(version.build):\(date.year)-\(date.month)-\(date.day)".hashValue
        self.date = date
        self.version = version
        self.requires = requires
        self.sdks = sdks
        self.links = links
    }
    
    //overridden to ignore id
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name &&
            lhs.date == rhs.date &&
            lhs.version == rhs.version &&
            lhs.requires == rhs.requires &&
            lhs.sdks == rhs.sdks &&
            lhs.links == rhs.links
    }
}
