//
//  ProductResponder.swift
//  UnidaysSDK
//
//  Created by Adam Mitchell on 21/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import Foundation

/// Responsible for converting the ProductLauncherDelegate methods into a more consumable completion handler
class ProductResponder {
    
    /// Completion handler which is called via the ProductLauncherDelegate methods
    private let completion: ((Error?) -> Void)
    
    /// - parameter withCompletion: the completion handler to be called when the ProductLauncher finishes
    init(withCompletion: @escaping (Error?) -> Void) {
        self.completion = withCompletion
    }
}

// MARK: ProductLauncherDelegate
extension ProductResponder: ProductLauncherDelegate {
    
    func onProductViewDidFinish() {
        self.completion(nil)
    }
    
    func onProductFailedToLoad(error: Error?) {
        if let error = error {
            self.completion(error)
        } else {
            self.completion(nil)
        }
    }
}
