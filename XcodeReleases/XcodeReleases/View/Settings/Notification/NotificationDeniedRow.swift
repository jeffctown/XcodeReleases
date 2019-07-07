//
//  NotificationDeniedRow.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/7/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct SettingsButton: View {
    @Binding var showingAlert: Bool
    let title: String
    
    var body: some View {
        Button(action: {
            self.showingAlert = true
        }) {
            Text(title)
        }.presentation($showingAlert) {
            Alert(
                title: Text("Change This?"),
                message: Text("You need to change this in Settings.  Do you want to go to Settings now?"),
                primaryButton: Alert.Button.default(Text("OK"), onTrigger: {
                    self.showingAlert = true
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }),
                secondaryButton: Alert.Button.cancel({
                    self.showingAlert = false
                })
            )
        }
    }
}

struct NotificationDeniedRow: View {
    @Binding var authorizationStatus: UNAuthorizationStatus
    @Binding var showingAlert: Bool
    
    var body: some View {
        Group {
            if authorizationStatus == .denied {
                SettingsButton(showingAlert: $showingAlert, title: "Notifications Denied")
            } else {
                EmptyView()
            }
        }
    }
}
