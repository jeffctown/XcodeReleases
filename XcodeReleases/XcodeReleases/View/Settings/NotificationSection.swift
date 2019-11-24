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
    @Binding var pushToken: String?
    @Binding var authorizationStatus: UNAuthorizationStatus
    @Binding var showingAlert: Bool
    @Binding var notificationsEnabled: Bool
    
    var body: some View {
        Section(header: Text("Notifications")) {
            NotificationToggleRow(notificationsEnabled: $notificationsEnabled)
            #if DEBUG
            NotificationTokenRow(pushToken: pushToken, authorizationStatus: $authorizationStatus, showingAlert: $showingAlert)
            #endif
        }
    }
}

#if DEBUG
struct NotificationSection_Previews : PreviewProvider {
    static var previews: some View {
        List {
            NotificationSection(
                pushToken: .constant("1234"),
                authorizationStatus: .constant(.notDetermined),
                showingAlert: .constant(true),
                notificationsEnabled: .constant(true)
            )
        }
    }
}
#endif








