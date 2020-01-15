//
//  DeviceTokenRow.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/7/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Foundation
import SwiftUI

struct NotificationTokenRow: View {
    
    var notificationState: NotificationState
    @State private var showingAlert: Bool = false
    
    var body: some View {
        #if DEBUG
        switch notificationState {
        case .authorized(let token), .provisional(let token):
            return AnyView(Button(action: {
                #if os(iOS)
                    UIPasteboard.general.string = token
                #endif
                    self.showingAlert = true
                }) {
                    Text("Token: \(token)").lineLimit(3)
                }.alert(isPresented: self.$showingAlert) {
                    Alert(title: Text("Token Copied!"))
                }
            )
        default:
            return AnyView(EmptyView())
        }
        #else
        return AnyView(EmptyView())
        #endif
    }
    
}
