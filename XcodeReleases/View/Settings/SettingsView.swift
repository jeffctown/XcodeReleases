//
//  SettingsView.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Combine
import SwiftUI

extension View {
    
    public func alertForSettings(isPresented: Binding<Bool>, title: String, message :String) -> some View {
        let goToSettingsButtonTitle = "Settings"
        let goNowhereTitle = "Close"
        
        return alert(isPresented: isPresented) { () -> Alert in
            Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .default(Text(goToSettingsButtonTitle)) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                },
                secondaryButton: .destructive(Text(goNowhereTitle))
            )
        }
    }
}

struct SettingsView : View {
    
    @EnvironmentObject private var appState: AppState
    
    @State private var showingDisableAlert = false
    @State private var showingEnableAlert = false
    @State private var notificationState: NotificationState = .notDetermined
        
    private struct Strings {
        static let title = "Settings"
        static let goToEnableTitle = "Enable In Settings"
        static let goToDisableTitle = "Disable In Settings"
        static let goToSettingsMessage = "Would you like to go to Settings to change your notifications?"
        static let goToSettingsButtonTitle = "Settings"
        static let goNowhereTitle = "Close"
    }
    
    private func updated(setting: NotificationState) {
        print("New Notification State: \(setting)")
        self.notificationState = setting
        switch setting {
        case .authorizedButDisabled:
            self.showingDisableAlert = true
        case .deniedButEnabled:
            self.showingEnableAlert = true
        case .authorizing:
            self.appDelegate.userNotifications.register()
        default:
            break
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                NotificationSection(notificationsEnabled: $appState.notificationsEnabled,
                                    notificationState: notificationState)
                    .alertForSettings(isPresented: self.$showingEnableAlert,
                        title: Strings.goToEnableTitle,
                        message: Strings.goToSettingsMessage)
                AboutSection(version: InfoPList.version, build: InfoPList.build)
            }.onReceive(appState.notificationSetting, perform: updated(setting:))
                .onAppear() {
                self.appDelegate.userNotifications.checkAuthorizationStatus()
            }.alertForSettings(isPresented: self.$showingDisableAlert, title: Strings.goToDisableTitle, message: Strings.goToSettingsMessage
            ).navigationBarTitle(Strings.title)
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

