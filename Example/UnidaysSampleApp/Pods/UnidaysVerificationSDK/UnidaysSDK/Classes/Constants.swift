//
//  Constants.swift
//
//  Created by Adam Gask on 06/01/2016.
//
//

import UIKit

class Constants: NSObject {
    
    // MARK: -
    // MARK: Request Url parameter keys
    /// The success callback key for the request url
    static let successCallbackParameterKey = "x-success"
    
    /// The error callback key for the request url
    static let errorCallbackParameterKey = "x-error"
    
    /// The source key for the request url
    static let sourceCallbackParameterKey = "x-source"
    
    /// The debug key for the request url
    static let debugCallbackParameterKey = "debug"
    
    /// The sdk version key for the request url
    static let sdkVersionCallbackParameterKey = "sdk-version"
    
    // MARK: -
    // MARK: Response paths
    /// The path for the success callback url
    static let successPath = "unidays-get-code-success"
    
    /// The path for the error callback url
    static let failurePath = "unidays-get-code-error"
    
    // MARK: -
    // MARK: Request paths
    /// The Code request path
    static let getCodePath = "get-code"
    
    // MARK: -
    // MARK: Request values
    
    /// The scheme the Unidays native app is registered to listen to in order to support the SDK
    static let unidaysScheme = "unidays-sdk"
    
    /// The integrating apps bundle identifier
    static var callbackSource: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    /// The sdk version or empty if not able to retrieve
    static var sdkVersion: String {
        let bundle = Bundle(for: UrlBuilder.self)
        guard let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return ""
        }
        return version
    }
    
    // MARK: -
    // MARK: Error callback parameters
    static let errorCodeQueryParameterKey = "error_code"
    static let errorMessageQueryParameterKey = "error_message"
    
    // MARK: -
    // MARK: Get code callback parameters
    static let codeQueryParameterKey = "code"
    static let imageQueryParameterKey = "image"
    static let urlQueryParameterKey = "url"
    static let expiresQueryParameterKey = "expires"
    
    // MARK: -
    // MARK: Error values
    static let unidaysErrorDomain = "com.myunidays.UnidaysSDK"
}

// MARK: -
/// An error recognisable by the SDK these do NOT contain user friendly messages.
public enum UnidaysError: Int, LocalizedError {
    
    /// This error represents that you've not set the URLScheme in your Info.plist file
    case CFBundleURLSchemesNotSetError = -1
    
    /// This error represents a state where you have made a request of the SDK but have not yet called the setup function.
    case SetupNotCompletedError = -2
    
    /// This error is a generic error when trying to parse a response from Unidays
    case CouldNotParseResponse = -3
    
    /// The BehaviourMode you have set on your UnidaysConfig is not supported by this device. This can happen if you have requested `.nativeAppOnly` but the native app isn't/ wasn't installed via the product launcher
    case ModeNotSupported = -4
    
    /// The UrlBuilder was unable to generate the request for some reason.
    case CouldNotGenerateRequestUrl = -5
    
    public var errorDescription: String? {
        switch(self) {
        case .CouldNotGenerateRequestUrl:
            return("The Unidays SDK was unable to create the request url. Please file this as an issue on the github repository with details of your setup and we will get back to you as soon as possible.")
        case .SetupNotCompletedError:
            return("The Unidays SDK has not been setup. You can do this via UnidaysSDK.sharedInstance.setup(settings: UnidaysConfig).")
        case .CFBundleURLSchemesNotSetError:
            return("The custom Scheme you have specified has not been set within the applications Info.plist.")
        case .CouldNotParseResponse:
            return("We were unable to parse the response from the unidays app")
        case .ModeNotSupported:
            return("The behaviour mode you are trying to use is not supported on this device.")
        }
    }
}
