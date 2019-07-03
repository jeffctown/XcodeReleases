//
//  ReleaseType.swift
//  
//
//  Created by Jeff Lett on 7/3/19.
//

import Foundation

public enum ReleaseType: Codable, CustomStringConvertible {
    case gm
    case gmSeed(Int)
    case beta(Int)
    
    enum CodingKeys: String, CodingKey { case gm, gmSeed, beta }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let beta = try container.decodeIfPresent(Int.self, forKey: .beta) {
            self = .beta(beta)
            return
        } else if let gmSeed = try container.decodeIfPresent(Int.self, forKey: .gmSeed) {
            self = .gmSeed(gmSeed)
            return
        } else {
            self = .gm
            return
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .gmSeed(seedNumber):
            try container.encode(seedNumber, forKey: .gmSeed)
        case let .beta(betaNumber):
            try container.encode(betaNumber, forKey: .beta)
        case .gm:
            return
        }
    }
    
    public var description: String {
        switch self {
        case .gm:
            return "GM"
        case let .beta(version):
            return "Beta \(version)"
        case let .gmSeed(seedNumber):
            return "GM Seed \(seedNumber)"
        }
    }
}
