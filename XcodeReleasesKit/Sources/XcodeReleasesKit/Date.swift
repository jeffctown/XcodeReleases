//
//  File.swift
//  
//
//  Created by Jeff Lett on 7/3/19.
//

import Foundation

public struct Date: Codable, CustomStringConvertible, Equatable {
    public let year: Int
    public let month: Int
    public let day: Int
    
    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    public var description: String {
        let dateComponents = self.dateComponents
        let calendar = Calendar(identifier: .gregorian)
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM dd,yyyy")
        guard let date = calendar.date(from: dateComponents) else {
            return "Invalid Date"
        }
        return formatter.string(from: date)
    }
    
    public var dateComponents: DateComponents {
        var dateComponents = DateComponents()
        dateComponents.year = self.year
        dateComponents.month = self.month
        dateComponents.day = self.day
        dateComponents.calendar = NSCalendar.current
        return dateComponents
    }
    
}
