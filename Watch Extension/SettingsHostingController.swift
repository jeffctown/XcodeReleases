//
//  SettingsHostingController.swift
//  Watch Extension
//
//  Created by Jeff Lett on 1/15/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

import Foundation
import SwiftUI
import WatchKit

class SettingsHostingController: WKHostingController<AnyView> {
    
    override var body: AnyView {
        return AnyView(SettingsView().environmentObject(appState))
    }
}
