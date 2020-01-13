//
//  InfoPList.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/6/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Foundation

struct InfoPList {
    
    static var version: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static var build: String {
        Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }
    
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier!
    }
}
