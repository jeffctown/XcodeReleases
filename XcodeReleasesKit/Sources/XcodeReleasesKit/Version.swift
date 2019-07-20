//
//  Version.swift
//  
//
//  Created by Jeff Lett on 7/3/19.
//

import Foundation

public struct Version: Codable, Equatable {
    
    public let number: String?
    public let build: String
    public let release: ReleaseType
    
    public init(number: String?, build: String, release: ReleaseType) {
        self.number = number
        self.build = build
        self.release = release
    }
}
