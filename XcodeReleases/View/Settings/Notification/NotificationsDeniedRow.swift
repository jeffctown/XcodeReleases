//
//  NotificationsDeniedRow.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 12/26/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct NotificationsDeniedRow: View {
    
    var notificationState: NotificationState
    @Binding var isSavingToServer: Bool
    
    var body: some View {
        switch notificationState {
        case .denied:
            return AnyView(
                Button(action: {
                    print("Changing Settings.")
                }) {
                    HStack {
                        Text("Disabled 🚫")
                        #if os(iOS)
                        ActivityIndicator(shouldAnimate: $isSavingToServer, color: .gray).frame(width: 40, height: 40)
                        #endif
                    }
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
}
