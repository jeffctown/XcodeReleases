//
//  PushNotificationSection.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/6/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI
import UserNotifications

struct NotificationSection : View {
    
    var notificationState: NotificationState
    @Binding var isSaving: Bool
    
    var body: some View {
        Section(header: Text("Notifications")) {
            NotificationsEnabledRow(notificationState: notificationState, isSavingToServer: $isSaving)
            NotificationsDeniedRow(notificationState: notificationState, isSavingToServer: $isSaving)
            NotificationsFailedRow(notificationState: notificationState)
            NotificationTokenRow(notificationState: notificationState)
        }
    }
}

#if DEBUG
struct NotificationSection_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                List {
                    NotificationSection(
                        notificationState: .authorized("push token"),
                        isSaving: .constant(true)
                    )
                    NotificationSection(
                        notificationState: .provisional("provisional token"),
                        isSaving: .constant(true)
                    )
                    NotificationSection(
                        notificationState: .notDetermined,
                        isSaving: .constant(true)
                    )
                    NotificationSection(
                        notificationState: .noToken,
                        isSaving: .constant(true)
                    )
                    NotificationSection(
                        notificationState: .denied,
                        isSaving: .constant(true)
                    )
                }.navigationBarTitle("Settings")
            }.environmentObject(AppState())
            NavigationView {
                List {
                    NotificationSection(
                        notificationState: .authorized("push token"),
                        isSaving: .constant(true)
                    )
                    NotificationSection(
                        notificationState: .provisional("provisional token"),
                        isSaving: .constant(true)
                    )
                    NotificationSection(
                        notificationState: .notDetermined,
                        isSaving: .constant(true)
                    )
                    NotificationSection(
                        notificationState: .noToken,
                        isSaving: .constant(true)
                    )
                    NotificationSection(
                        notificationState: .denied,
                        isSaving: .constant(true)
                    )
                }.navigationBarTitle("Settings")
            }.colorScheme(.dark).environmentObject(AppState())
        }
    }
}
#endif








