//
//  ExtensionDelegate.swift
//  Watch Extension
//
//  Created by Jeff Lett on 1/11/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var appState = AppState()

    func applicationDidFinishLaunching() {
        appState.userNotifications.applicationDidFinishLaunching()
        appState.pkPushNotifications.applicationDidFinishLaunching(delegate: appState.userNotifications)
    }

    func applicationDidBecomeActive() {
        ComplicationController.reloadAll()
        appState.userNotifications.applicationDidBecomeActive()
        appState.releasesService.refresh()
        appState.linksService.refresh()
    }

    func applicationWillResignActive() {
        ComplicationController.reloadAll()
    }

    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        appState.userNotifications.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        appState.userNotifications.didFailToRegisterForRemoteNotificationsWithError(error)
    }

    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any],
                                      //swiftlint:disable:next line_length
                                      fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification")
        ComplicationController.reloadAll()
        completionHandler(.newData)
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks.
        // Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            print("Handling Background Task \(task)")
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true,
                                              estimatedSnapshotExpiration: Date.distantFuture,
                                              userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                ComplicationController.reloadAll()
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
