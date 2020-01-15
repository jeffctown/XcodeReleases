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
                    #if os(iOS)
                    WebViewButton(text: "Suggestions", url: URL(string: "https://github.com/jeffctown/XcodeReleases/issues")!)
                    WebViewButton(text: "Github", url: URL(string: "https://github.com/jeffctown/XcodeReleases")!)
                    WebViewButton(text: "Privacy Policy", url: URL(string: "https://xcodereleases.jefflett.com/privacy/")!)
                    #else
                    Text("https://github.com/jeffctown/XcodeReleases").font(.caption).padding()
                    #endif
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
