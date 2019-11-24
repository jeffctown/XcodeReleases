//
//  AboutSection.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/6/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct AboutSection : View {
    let version: String
    let build: String
    
    var body: some View {
        Section(header: Text("About"),
                footer: Text("Version: v\(version) (\(build))").font(.caption)) {
            WebViewButton(text: "Suggestions", url: URL(string: "http://google.com")!)
            WebViewButton(text: "Githhub", url: URL(string: "http://google.com")!)
            WebViewButton(text: "Privacy Policy", url: URL(string: "http://google.com")!)
        }
    }
}

#if DEBUG
struct AboutSection_Previews : PreviewProvider {
    static var previews: some View {
        List {
            AboutSection(version: "1.0", build: "1")
            AboutSection(version: "3.5.2", build: "1298")
        }
    }
}
#endif
