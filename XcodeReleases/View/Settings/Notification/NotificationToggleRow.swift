//
//  NotificationToggleRow.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/7/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct NotificationToggleRow: View {
    @Binding var notificationsEnabled: Bool
    
    var body: some View {
        Group {
            Toggle(isOn: $notificationsEnabled) {
                Text("Notifications")
            }
        }
    }
}
