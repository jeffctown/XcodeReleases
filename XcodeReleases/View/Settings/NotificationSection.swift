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
    @Binding var notificationsEnabled: Bool
    var notificationState: NotificationState
    
    var body: some View {
        Section(header: Text("Notifications")) {
            NotificationToggleRow(notificationsEnabled: $notificationsEnabled)
            #if DEBUG
            NotificationTokenRow(notificationState: notificationState)
            #endif
        }
    }
}

#if DEBUG
struct NotificationSection_Previews : PreviewProvider {
    static var previews: some View {
        List {
            NotificationSection(
                notificationsEnabled: .constant(true),
                notificationState: .authorized("8176token19827")
            )
        }
    }
}
#endif








