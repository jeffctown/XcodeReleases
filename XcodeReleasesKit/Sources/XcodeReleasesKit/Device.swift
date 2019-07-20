import Foundation

public final class Device: Codable, Equatable {
    public static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type && lhs.token == rhs.token
    }
    
    public var id: Int?
    public var type: String
    public var token: String
    
    public init(type: String, token: String) {
        self.type = type
        self.token = token
    }
}
