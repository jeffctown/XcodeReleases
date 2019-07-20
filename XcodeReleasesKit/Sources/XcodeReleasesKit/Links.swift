//
//  File.swift
//  
//
//  Created by Jeff Lett on 7/3/19.
//

import Foundation

public struct Url: Codable, Equatable {
    public let url: String
    
    public init(url: String) {
        self.url = url
    }
}

public struct Links: Codable, Equatable {
    public let notes: Url?
    public let download: Url?
    
    public init(notes: Url?, download: Url?) {
        self.notes = notes
        self.download = download
    }
}
