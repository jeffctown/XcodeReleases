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
    
    @State var showingDisableAlert = false
    @State var showingEnableAlert = false
    @State var showingAlert = false
    @State var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private static let title = "Settings"
    private static let goToEnableTitle = "Enable In Settings"
    private static let goToDisableTitle = "Disable In Settings"
    private static let goToSettingsMessage = "Would you like to go to the Settings app now to change your notification settings?"
    private static let goToSettingsButtonTitle = "Take Me To Settings!"
    private static let goNowhereTitle = "Dismiss"
    
    var body: some View {
        NavigationView {
            List {
                NotificationSection(
                    pushToken: $appState.pushToken,
                    authorizationStatus: $authorizationStatus,
                    showingAlert: $showingAlert,
                    notificationsEnabled: $appState.notificationsEnabled
                ).onReceive(appState.throttledNotificationSetting) { enabled in
                    print("Notifications - enabled: \(enabled) auth: \(self.authorizationStatus.rawValue)")
                    if enabled && (self.authorizationStatus == .notDetermined || self.authorizationStatus == .provisional) {
                        self.appDelegate.userNotifications.register()
                    } else if !enabled && self.authorizationStatus == .authorized {
                        self.showingDisableAlert = true
                    } else if enabled && self.authorizationStatus == .denied {
                        self.showingEnableAlert = true
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
            }.navigationBarTitle(SettingsView.title)
                .alert(isPresented: self.$showingEnableAlert) {
                    Alert(title: Text(SettingsView.goToDisableTitle), message: Text(SettingsView.goToSettingsMessage), primaryButton: .default(Text(SettingsView.goToSettingsButtonTitle)) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }, secondaryButton: .destructive(Text(SettingsView.goNowhereTitle)))
                }
                .alert(isPresented: self.$showingDisableAlert) {
                    Alert(title: Text(SettingsView.goToEnableTitle), message: Text(SettingsView.goToSettingsMessage), primaryButton: .default(Text(SettingsView.goToSettingsButtonTitle)) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }, secondaryButton: .destructive(Text(SettingsView.goNowhereTitle)))
                }
        }
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

