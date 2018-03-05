//
//  UnidaysLauncher.swift
//
//  Created by Adam Gask on 06/01/2016.
//
//

import UIKit

/// Types implementing this are responsible for checking if Unidays can be opened and launching it if requested
protocol UnidaysLauncherProtocol {
    
    ///
    /// Helper method to check if the current application can open the UNiDAYS app.
    ///
    /// - returns: `true` if the application is allowed to query and open the UNiDAYS app.
    func canOpenUnidays() -> Bool
    
    ///
    /// Launch a given NSURL.
    ///
    /// - parameter url: The `NSURL` to launch.
    ///
    /// - returns: `true` if the url was launched successfully
    func launch(url: NSURL) -> Bool
}

/// Responsible for handling communication with the UIApplication to check whether the unidays native app is installed and launching it.
class UnidaysNativeAppLauncher: UnidaysLauncherProtocol {
    
    func canOpenUnidays() -> Bool {
        if let appURL = NSURL(string: "\(Constants.unidaysScheme)://") {
            let canOpen = UIApplication.shared.canOpenURL(appURL as URL)
            return canOpen
        }
        return false
    }
    
    func launch(url: NSURL) -> Bool {
        return UIApplication.shared.openURL(url as URL)
    }
}
