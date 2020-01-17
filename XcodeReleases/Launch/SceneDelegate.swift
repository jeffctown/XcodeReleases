//
//  SceneDelegate.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/3/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import SwiftUI
import UIKit
import XcodeReleasesKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appState: AppState { (UIApplication.shared.delegate as! AppDelegate).appState }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let rootView = TabbedRootView().environmentObject(appState)
            window.rootViewController = UIHostingController(rootView: rootView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        appState.userNotifications.checkAuthorizationStatus()
        appState.releasesService.refresh()
        appState.linksService.refresh()
    }

    func deeplink(urlString: String) {
        let url = URL(string: urlString)!
        let view = SafariView(url: url)
        let hostingController = UIHostingController(rootView: view)
        self.window?.rootViewController?.present(hostingController, animated: true, completion: nil)
    }
    
}

