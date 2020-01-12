//
//  UserNotifications+watchOS.swift
//  Xcode Releases
//
//  Created by Jeff Lett on 1/12/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

#if os(watchOS)
import WatchKit

extension UserNotifications {
    var model: String {
        WKInterfaceDevice.current().model
    }
    
    func applicationDidFinishLaunching() {
        WKExtension.shared().registerForRemoteNotifications()
    }
    
    
}
#endif
