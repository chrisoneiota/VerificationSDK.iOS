//
//  ResponseValidator.swift
//  Pods
//
//  Created by Adam Gask on 06/01/2016.
//
//

import UIKit
import Foundation

/// Responsible for validating the `URL`s coming into the app are for `UnidaysSDK`
class ResponseValidator {

    ///
    /// Validate a given `NSURL`.
    ///
    /// - parameter url: The `URL` to validate
    ///
    /// - parameter withSettings: The `UnidaysConfig` to validate the url with
    ///
    /// - returns: `true` if the `URL` is valid.
    ///
    func validate(url: URL, withSettings: UnidaysConfig) -> Bool {
        let components = URLComponents(url: url as URL, resolvingAgainstBaseURL: true)
        let isSchemeValid = components?.scheme == withSettings.scheme
        let isPathValid = validatePath(path: url.absoluteString)
        guard isSchemeValid && isPathValid else {
            return false
        }
        return true
    }
}

extension ResponseValidator {
    
    ///
    /// Validate the URL Success or Failure Path.
    ///
    /// - parameter path: The URL String to validate
    ///
    /// - returns: True if the URL Path is valid.
    ///
    private func validatePath(path: String?) -> Bool {
        let acceptedPaths = [Constants.successPath, Constants.failurePath]
        for acceptedPath in acceptedPaths {
            if let _ = path?.range(of: acceptedPath) {
                return true
            }
        }
        return false
    }
}
