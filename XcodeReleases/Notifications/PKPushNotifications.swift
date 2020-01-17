//
//  PKPushNotifications.swift
//  Xcode Releases
//
//  Created by Jeff Lett on 1/14/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

import APNS
import PushKit
import XcodeReleasesKit

protocol PKPushNotificationsDelegate: class {
    func didUpdateWithComplicationToken(token: String)
    func didInvalidateComplicationToken()
}

class PKPushNotifications: NSObject, PKPushRegistryDelegate {
    
    public weak var delegate: PKPushNotificationsDelegate?
    
    func applicationDidFinishLaunching(delegate: PKPushNotificationsDelegate) {
        print("*** Registering for complication notifications ***")
        self.delegate = delegate
        let pushRegistry = PKPushRegistry(queue: .main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.complication]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("registry didUpdate pushCredentials \(pushCredentials.type.rawValue) \(token)")
        delegate?.didUpdateWithComplicationToken(token: token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("registry didInvalidatePushTokenFor")
        delegate?.didInvalidateComplicationToken()
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("registry didReceiveIncomingPushWith \(payload.dictionaryPayload)")
        if case .complication = type {
            print("Complication Push Received: \(payload)")
            let extra = payload.dictionaryPayload["extra"] as? [AnyHashable: String]
            let releaseJson = extra?["release"]
            if let releaseData = releaseJson?.data(using: .utf8) {
                do {
                    let release = try JSONDecoder().decode(XcodeRelease.self, from: releaseData)
                    print("Release: \(release)")
                } catch {
                    print("Error Decoding: \(error)")
                }
            }
            ComplicationController.reloadAll()
        }
        
        completion()
    }
}
