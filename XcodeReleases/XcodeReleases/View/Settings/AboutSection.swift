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
            NavigationLink("Suggestions", destination: SafariView(url: URL(string: "http://http://freesuggestionbox.com")!))
            NavigationLink("Github", destination: SafariView(url: URL(string: "http://github.com/jeffctown")!))
            NavigationLink("Privacy Policy", destination: SafariView(url: URL(string: "http://secrets.com")!)
            )
            NavigationLink("Terms of Service", destination: SafariView(url: URL(string: "http://terms.com")!))
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
