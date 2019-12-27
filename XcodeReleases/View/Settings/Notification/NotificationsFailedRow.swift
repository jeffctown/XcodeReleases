//
//  NotificationFailedRow.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 12/25/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct NotificationsFailedRow: View {
    
    var notificationState: NotificationState
    
    var body: some View {
        switch self.notificationState {
        case .noToken:
            return AnyView(Text("Notification Registration Failed.  If you're on a simulator, this is expected. ").font(.footnote))
        case .notDetermined:
            return  AnyView(Text("Notification Status Not Determined.").font(.footnote))
        default:
            return AnyView(EmptyView())
        }
    }
}
