//
//  SettingsValidator.swift
//  UnidaysSDK
//
//  Created by Adam Mitchell on 22/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import Foundation

/// Responsible for validating the UnidaysConfig object passed into the SDK
class SettingsValidator {
    
    /// The bundle we should query for the plist which contains the URLSchemes
    fileprivate let bundle: Bundle
    
    /// The plist filename which is used when looking up the URLSchemes
    fileprivate let resourceName: String
    
    init(bundle: Bundle = Bundle.main, resourceName: String = "Info") {
        self.bundle = bundle
        self.resourceName = resourceName
    }
    
    
    /// Validates the settings object
    ///
    /// - parameter settings:     The settings object to be validated
    ///
    /// - throws: If the settings object is invalid
    func validateSettings(_ settings: UnidaysConfig) throws {
        guard self.checkPlistHasSchemeSet(scheme: settings.scheme) else {
            throw UnidaysError.CFBundleURLSchemesNotSetError
        }
    }
}

private extension SettingsValidator {
    
    /// Checks that the plist specified in the validators bundle contains the scheme.
    ///
    /// - parameter scheme:     The scheme to confirm is contained in the plist
    ///
    /// - returns: true if the plist contains the scheme set correctly.
    func checkPlistHasSchemeSet(scheme: String) -> Bool {
        if let plistPath = self.bundle.path(forResource: resourceName, ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? Dictionary<String, AnyObject> {
                if let cfBundleURLTypes = plistDictionary["CFBundleURLTypes"] as? NSArray {
                    for item in cfBundleURLTypes {
                        if let bundleType = item as? Dictionary<String, AnyObject> {
                            if let schemes = bundleType["CFBundleURLSchemes"] as? NSArray {
                                for testScheme in schemes.flatMap({ (anyObject) -> String? in
                                    return anyObject as? String
                                }) {
                                    if testScheme == scheme {
                                        return true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}
