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
                    #if os(iOS)
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    #endif
                },
                secondaryButton: .destructive(Text(goNowhereTitle))
            )
        }
    }
}

struct SettingsView : View {
    
    @EnvironmentObject private var appState: AppState
    
    @State private var showingEnableAlert = false
    @State private var notificationState: NotificationState = .notDetermined
    @State private var isSaving: Bool = false
        
    private struct Strings {
        static let title = "Settings"
        static let goToEnableTitle = "Enable In Settings"
        static let goToSettingsMessage = "Would you like to go to Settings to enable your notifications?"
        static let goToSettingsButtonTitle = "Settings"
        static let goNowhereTitle = "Close"
    }
    
    #if os(watchOS)
    var body: some View {
        self.innerBody
    }
    #else
    var body: some View {
        NavigationView {
            self.innerBody
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    #endif
    
    var innerBody: some View {
        Group {
            List {
                NotificationSection(notificationState: notificationState, isSaving: $isSaving)
                    .alertForSettings(isPresented: self.$showingEnableAlert,
                                   title: Strings.goToEnableTitle,
                                   message: Strings.goToSettingsMessage)
                AboutSection(version: InfoPList.version, build: InfoPList.build)
            }.onReceive(appState.notificationState) { setting in
                self.notificationState = setting
            }.onReceive(appState.userNotifications.$isSavingNotificationState) { isSaving in
                self.isSaving = isSaving
            }.onAppear() {
                self.appState.userNotifications.checkAuthorizationStatus()
            }.navigationBarTitle(Strings.title)
        }
    }
}

#if DEBUG
struct SettingsView_Previews : PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppState())
    }
}
#endif

