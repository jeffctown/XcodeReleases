//
//  HostingController.swift
//  Watch Extension
//
//  Created by Jeff Lett on 1/11/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    
    var appState: AppState { (WKExtension.shared().delegate as! ExtensionDelegate).appState }
    
    override var body: AnyView {
        return AnyView(XcodeReleaseList().environmentObject(appState))
    }
}
