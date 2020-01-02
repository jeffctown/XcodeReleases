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
                    Text("Provisional ✅")
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
}

struct NotificationsEnabledRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            List {
                NotificationsEnabledRow(notificationState: .authorized("tokentokentokenabcd"), isSavingToServer: .constant(true))
                NotificationsEnabledRow(notificationState: .authorized("tokentokentokenabcd"), isSavingToServer: .constant(false))
                NotificationsEnabledRow(notificationState: .provisional("tokentokentokenabcd"), isSavingToServer: .constant(true))
                NotificationsEnabledRow(notificationState: .provisional("tokentokentokenabcd"), isSavingToServer: .constant(false))
            }
            List {
                NotificationsEnabledRow(notificationState: .authorized("tokentokentokenabcd"), isSavingToServer: .constant(true))
                NotificationsEnabledRow(notificationState: .authorized("tokentokentokenabcd"), isSavingToServer: .constant(false))
                NotificationsEnabledRow(notificationState: .provisional("tokentokentokenabcd"), isSavingToServer: .constant(true))
                NotificationsEnabledRow(notificationState: .provisional("tokentokentokenabcd"), isSavingToServer: .constant(false))
            }.colorScheme(.dark)
        }
    }
}
