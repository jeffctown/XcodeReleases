//
//  SettingsButton.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/7/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct SettingsButton: View {
    @Binding var showingAlert: Bool
    let title: String
    
    var body: some View {
        Button(action: {
            self.showingAlert = true
        }) {
            Text(title)
        }.alert(isPresented: $showingAlert, content: {
            Alert(
                title: Text("Change This?"),
                message: Text("You need to change this in Settings.  Do you want to go to Settings now?"),
                primaryButton: Alert.Button.default(Text("OK"), action: {
                    self.showingAlert = true
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }),
                secondaryButton: Alert.Button.cancel({
                    self.showingAlert = false
                })
            )
        })
    }
}
