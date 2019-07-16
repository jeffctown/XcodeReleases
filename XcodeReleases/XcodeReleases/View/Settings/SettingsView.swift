//
//  SettingsView.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI

struct SettingsView : View {
    @EnvironmentObject private var appState: AppState
    @State var showingAlert = false
    @State var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        List {
            NotificationSection(
                pushToken: $appState.pushToken,
                authorizationStatus: $authorizationStatus,
                showingAlert: $showingAlert,
                notificationsEnabled: $appState.notificationsEnabled
            ).onReceive(appState.throttledNotificationSetting) { enabled in
                print("Notifications - enabled: \(enabled) auth: \(self.authorizationStatus.rawValue)")
                if enabled && (self.authorizationStatus == .notDetermined || self.authorizationStatus == .provisional) {
                    print("Register")
                    self.appDelegate.userNotifications.register()
                } else if !enabled && self.authorizationStatus == .authorized {
                    print("Go To Settings to Disable")
//                    Alert(title: Text("Disable In Settings"), message: Text("Would you like to go to the Settings app now to change your notification settings?"), primaryButton: Alert.Button.default(Text("Go To Settings"), onTrigger: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//                    }), secondaryButton: Alert.Button.cancel())
                } else if enabled && self.authorizationStatus == .denied {
                    print("Go To Settings To Enable")
//                    Alert(title: Text("Enable In Settings"), message: Text("Would you like to go to the Settings app now to change your notification settings?"), primaryButton: Alert.Button.default(Text("Go To Settings"), onTrigger: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//                    }), secondaryButton: Alert.Button.cancel())
                }
            }
            AboutSection(version: InfoPList.version, build: InfoPList.build)
        }.onReceive(appDelegate.userNotifications.authorizationStatus, perform: { status in
            self.authorizationStatus = status
            if status == .denied || status == .provisional || status == .notDetermined {
                self.appState.notificationsEnabled = false
            } else {
                self.appState.notificationsEnabled = true
            }
        }).onAppear() {
            self.appDelegate.userNotifications.checkAuthorizationStatus()
        }.navigationBarTitle("Settings")
    }
}

#if DEBUG
struct SettingsView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView().environmentObject(AppState())
        }
    }
}
#endif
