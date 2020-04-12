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

extension WKHostingController {
    var appState: AppState {
        //swiftlint:disable:next force_cast
        (WKExtension.shared().delegate as! ExtensionDelegate).appState }
}

class ReleasesHostingController: WKHostingController<AnyView> {

    override var body: AnyView {
        return AnyView(XcodeReleaseList().environmentObject(appState))
    }
}
