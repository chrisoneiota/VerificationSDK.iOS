//
//  ConfigurationSettings.swift
//  UnidaysSDK
//
//  Created by Adam Mitchell on 28/11/2017.
//  Copyright © 2017 UNiDAYS. All rights reserved.
//

import Foundation
//MARK: -
/// Represents the settings for you UnidaysSDK integration
@objc public class UnidaysConfig: NSObject {
    
    /// The custom scheme for your app. This allows Unidays to link back from their native app back to the one specified.
    var scheme: String
    
    /// The subdomain of the partner this integration is for. This allows Unidays to request codes for this partner.
    var customerSubdomain: String
    
    /// The behaviour this integration should use. Defaults to `.nativeAppOnly`. You can modify this to meet your own requirements.
    public var behaviourMode = BehaviourMode.defaultValue
    
    /// If debug mode is enabled and the behaviour is set to native app. You will see a debug screen which enables you to test a variety of intergrations at development time.
    public var isDebugEnabled = false
    
    @objc public init(scheme: String, customerSubdomain: String) {
        self.scheme = scheme
        self.customerSubdomain = customerSubdomain
    }
}

//MARK: -
/// This represents the behaviour the UnidaysSDK should use. The only support behaviour at time of writing is `.nativeAppOnly`
@objc public enum BehaviourMode: Int {
    
    /// The defaultValue which is used if the BehaviourMode is not changed on the `UnidaysConfig` object when setup
    static let defaultValue = BehaviourMode.nativeAppOnly
    
    /// This behaviour means the UnidaysSDK will only use the Unidays native app to deliver your requests. If the native app is not available the SDK will present the user with a product page to download the unidays native app.
    case nativeAppOnly
}
