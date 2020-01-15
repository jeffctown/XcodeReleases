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
            return AnyView(
                Group {
                    HStack {
                        Text("Disabled ❗️")
                    }
                    #if targetEnvironment(simulator)
                    Text(
                        "Notification Registration Failed.  You're on a simulator, so this is expected. "
                    ).font(.footnote)
                    #endif
                }
            )
        case .notDetermined:
            return  AnyView(
                HStack {
                    Text("Not Determined ❓")
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
}
