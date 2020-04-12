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
        case .authorized:
            return AnyView(
                HStack {
                    Text("Enabled ✅")
                    #if os(iOS)
                    ActivityIndicator(shouldAnimate: $isSavingToServer, color: .gray).frame(width: 40, height: 40)
                    #endif
                }
            )
        case .provisional:
            return AnyView(
                HStack {
                    Text("Provisional ✅")
                    #if os(iOS)
                    ActivityIndicator(shouldAnimate: $isSavingToServer, color: .gray).frame(width: 40, height: 40)
                    #endif
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
}

struct NotificationsEnabledRowPreviews: PreviewProvider {
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
