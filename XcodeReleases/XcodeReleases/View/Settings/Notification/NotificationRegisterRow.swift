
//
//  NotificationRegisterRow.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/7/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct NotificationRegisterRow: View {
    @Binding var authorizationStatus: UNAuthorizationStatus
    let register: () -> Void
    
    var body: some View {
        Group {
            if authorizationStatus == .notDetermined || authorizationStatus == .provisional {
                Button("Register") {
                   self.register()
                }
            } else {
                EmptyView()
            }
        }
    }
}
