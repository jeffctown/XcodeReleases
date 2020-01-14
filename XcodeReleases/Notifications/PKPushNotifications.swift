//
//  PKPushNotifications.swift
//  Xcode Releases
//
//  Created by Jeff Lett on 1/14/20.
//  Copyright © 2020 Jeff Lett. All rights reserved.
//

import PushKit

protocol PKPushNotificationsDelegate {
    func didUpdateWithComplicationToken(token: String)
    func didInvalidateComplicationToken()
}

class PKPushNotifications: NSObject, PKPushRegistryDelegate {
    
    public var delegate: PKPushNotificationsDelegate?
    
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
        completion()
    }
}
