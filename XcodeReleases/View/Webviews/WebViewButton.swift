//
//  WebViewButton.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 11/24/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct WebViewButton: View {

    @State private var showModal = false
    let text: String
    let url: URL

    var body: some View {
        Button(self.text) {
            self.showModal.toggle()
        }.sheet(isPresented: $showModal) {
            SafariView(url: self.url)
        }
    }
}

struct WebViewButtonPreviews: PreviewProvider {
    static var previews: some View {
        WebViewButton(text: "Google", url: URL(string: "https://google.com")!)
    }
}
