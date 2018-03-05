//
//  ProductLauncher.swift
//  UnidaysSDK
//
//  Created by Adam Mitchell on 20/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import Foundation
import StoreKit

// MARK: -
/// Types implementing `ProductLauncherDelegate` are response for handling messages passed from the `ProductLauncher`
protocol ProductLauncherDelegate: class {
    /// Called when there is an error loading the product view
    func onProductFailedToLoad(error: Error?)
    /// Called when the product view is dismissed by the user
    func onProductViewDidFinish()
}

// MARK: -
/// Types implementing `ProductLauncherProtocol` are able to launch product views and pass messages back to their `ProductLauncherDelegate`
protocol ProductLauncherProtocol: class {
    
    /// The delegate to pass messages to from the `SKStoreProductViewController`
    var delegate: ProductLauncherDelegate? { get set }
    /// Shows the `SKStoreProductViewController` passing any errors onto the delegate
    func showProductPage()
}

// MARK: -
/// Wrapper around the `SKStoreProductViewController`
class ProductLauncher: NSObject {
    
    var delegate: ProductLauncherDelegate?
}

// MARK: ProductLauncherProtocol
extension ProductLauncher: ProductLauncherProtocol {
    
    func showProductPage() {
        
        let productViewController = SKStoreProductViewController()
        
        productViewController.delegate = self
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            self.delegate?.onProductFailedToLoad(error: nil)
            return
        }
        
        rootViewController.present(productViewController, animated: true, completion: nil)
        
        productViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: NSNumber(value: 599608562)], completionBlock: { (result, error) in
            
            if !result || error != nil {
                productViewController.presentingViewController?.dismiss(animated: true, completion: nil)
                self.delegate?.onProductFailedToLoad(error: error)
            }
        })
    }
}

// MARK: SKStoreProductViewControllerDelegate
extension ProductLauncher: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
        self.delegate?.onProductViewDidFinish()
    }
}


