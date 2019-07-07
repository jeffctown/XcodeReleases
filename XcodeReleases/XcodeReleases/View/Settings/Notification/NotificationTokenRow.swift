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
    let pushToken: String
    @Binding var authorizationStatus: UNAuthorizationStatus
    @Binding var showingAlert: Bool
    
    var body: some View {
        Group {
            if authorizationStatus == .authorized {
                SettingsButton(showingAlert: $showingAlert, title: "Notifications Enabled")
                Button(action: {
                    UIPasteboard.general.string = self.pushToken
                    self.showingAlert = true
                }) {
                    Text("Token: \(pushToken)").lineLimit(3)
                }.presentation($showingAlert) {
                    Alert(title: Text("Token Copied!"))
                }
            } else {
                EmptyView()
            }
        }
    }
}
