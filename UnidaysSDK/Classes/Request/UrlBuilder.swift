//
//  UnidaysUrlBuilder.swift
//  UnidaysSDK
//
//  Created by Adam Mitchell on 15/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import Foundation

/// Responsible for generating the app url for a `Request`
class UrlBuilder {
    
    /// Takes the `Request`, scheme and whether it should be debug or not and builds a native app url
    ///
    /// - parameter request: The `Request` object which represents what type of request you are making. This provides the path and parameters for the request.
    ///
    /// - parameter forScheme: The custom scheme of the app to return to from the Unidays App.
    ///
    /// - parameter debug: Whether or not to add the debug flag to the request. This change the behaviour of the Unidays Native app to support testing.
    ///
    /// - returns: An `NSURL` object if it was able to create the request successfully otherwise `nil`
    func generateAppURL(withRequest request: Request, forScheme: String, debug: Bool) -> NSURL? {
        let params = generateRequestParams(withRequest: request, forScheme: forScheme, debugEnabled: debug)
        
        var components = URLComponents()
        components.scheme = Constants.unidaysScheme
        components.host = request.type.getPath()
        
        components.queryItems = [URLQueryItem]()
        for param in params {
            guard let key = param.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let value = param.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    continue
            }
            
            let item = URLQueryItem(name: key, value: value)
            components.queryItems?.append(item)
        }
        
        return components.url as NSURL?
    }
}

private extension UrlBuilder {
    
    /// Generates the request parameters
    ///
    /// - parameter request: The `Request` who's parameters are added to the request
    ///
    /// - parameter forScheme: The custom scheme of the app to return to from the Unidays App. Used to generate the success and failure callbacks
    ///
    /// - parameter debug: Whether or not to add the debug flag to the request. This change the behaviour of the Unidays Native app to support testing.
    ///
    /// - returns: A `[String: String]` dictionary representing the parameters to add.
    func generateRequestParams(withRequest request: Request, forScheme: String, debugEnabled debug: Bool) -> [String: String] {
        
        var parameters: Dictionary<String, String> = [
            Constants.successCallbackParameterKey : self.getSuccessCallbackURL(withScheme: forScheme),
            Constants.errorCallbackParameterKey   : self.getFailureCallbackURL(withScheme: forScheme),
            Constants.sourceCallbackParameterKey  : Constants.callbackSource,
            Constants.debugCallbackParameterKey   : debug ? "true" : "false",
            Constants.sdkVersionCallbackParameterKey : Constants.sdkVersion
        ]
        
        request.params().forEach { (key, value) in
            parameters[key] = value
        }
        
        return parameters
    }
    
    /// Generates the success callback url
    ///
    /// - parameter withScheme: The custom scheme of the app to return to from the Unidays App. Used to generate callback
    ///
    /// - returns: A string representing the callback url.
    func getSuccessCallbackURL(withScheme: String) -> String {
        return "\(withScheme)://x-callback-url/\(Constants.successPath)"
    }
    
    /// Generates the error callback url
    ///
    /// - parameter withScheme: The custom scheme of the app to return to from the Unidays App. Used to generate callback
    ///
    /// - returns: A string representing the callback url.
    func getFailureCallbackURL(withScheme: String) -> String {
        return "\(withScheme)://x-callback-url/\(Constants.failurePath)"
    }
}
