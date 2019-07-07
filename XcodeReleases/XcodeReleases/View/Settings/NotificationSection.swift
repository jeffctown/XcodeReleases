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
//    @Binding var notificationsEnabled: Bool
    @Binding var showingAlert: Bool
    let register: () -> Void
    
    var body: some View {
        Section(header: Text("Notifications")) {
//            NotificationToggleRow(notificationsEnabled: $notificationsEnabled)
            NotificationRegisterRow(authorizationStatus: $authorizationStatus) {
                self.register()
            }
            NotificationDeniedRow(authorizationStatus: $authorizationStatus, showingAlert: $showingAlert)
            NotificationTokenRow(pushToken: pushToken ?? "None", authorizationStatus: $authorizationStatus, showingAlert: $showingAlert)
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
//                notificationsEnabled: .constant(true),
                showingAlert: .constant(true)
            ) {}
        }
    }
}
#endif








