//
//  NotificationToggleRow.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/7/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct NotificationsEnabledRow: View {
    
    var notificationState: NotificationState
    @Binding var isSavingToServer: Bool
    
    var body: some View {
        switch notificationState {
        case .authorized(_):
            return AnyView(
                HStack {
                    Text("Push Notifications:")
                    Spacer()
                    ActivityIndicator(shouldAnimate: $isSavingToServer, color: .gray).frame(width: 40, height: 40)
                    Text("Enabled ✅")
                }
            )
        case .provisional(_):
            return AnyView(
                HStack {
                    Text("Push Notifications:")
                    Spacer()
                    ActivityIndicator(shouldAnimate: $isSavingToServer, color: .gray).frame(width: 40, height: 40)
                    Text("Provisionally Enabled ✅")
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
}
