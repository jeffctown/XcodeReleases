//
//  ActivityIndicator.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 12/26/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    @Binding var shouldAnimate: Bool
    var color: UIColor = .black

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.color = color
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        if self.shouldAnimate {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

struct ActivityIndicatorPreviews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(shouldAnimate: .constant(true))
    }
}
