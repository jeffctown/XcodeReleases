//
//  NotificationDeniedRow.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/7/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

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
