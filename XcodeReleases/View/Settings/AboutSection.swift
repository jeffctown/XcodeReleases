//
//  AboutSection.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/6/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import XcodeReleasesKit

struct AboutSection : View {
    let version: String
    let build: String
    let links: [Link]
    
    var body: some View {
        Section(header: Text("About"),
                footer: Text("Version: v\(version) (\(build))").font(.caption)) {
                    #if os(iOS)
                    ForEach(links, id: \.url) {
                        WebViewButton(text: $0.name, url: URL(string: $0.url)!)
                    }
                    #else
                    ForEach(links, id: \.url) {
                        Text($0.url).font(.footnote).padding()
                    }
                    #endif
        }
    }
}

#if DEBUG
struct AboutSection_Previews : PreviewProvider {
    static var previews: some View {
        List {
            AboutSection(version: "1.0", build: "1", links: [])
            AboutSection(version: "3.5.2", build: "1298", links: [])
        }
    }
}
#endif
