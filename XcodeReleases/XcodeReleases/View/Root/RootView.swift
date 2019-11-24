//
//  RootView.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 11/23/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct RootView: View {
   @EnvironmentObject private var appState: AppState

   var body: some View {
       TabView {
           XcodeReleaseList().tabItem {
               Image(systemName: "list.dash")
               Text("Releases")
           }.environmentObject(appState)
           SettingsView().tabItem {
               Image(systemName: "square.and.pencil")
               Text("Settings")
           }.environmentObject(appState)
       }
   }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
