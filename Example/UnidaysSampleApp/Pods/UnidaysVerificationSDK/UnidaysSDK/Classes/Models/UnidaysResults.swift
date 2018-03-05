//
//  UnidaysResponse.swift
//  UnidaysSDK
//
//  Created by Adam Mitchell on 30/11/2017.
//  Copyright © 2017 UNiDAYS. All rights reserved.
//

import Foundation
// MARK: -
/// Types implementing CodeResultProtocol can be used to represent a successful get code request.
@objc public protocol CodeResultProtocol {
    
    /// The discount code returned from Unidays
    var code: String? { get }
    
    /// An image url returned from Unidays. This may be a barcode or QR code other code representation
    var imageUrl: NSURL? { get }
    
    /// The date in which this code expires
    var expires: Date? { get }
    
    /// A url as provided by unidays. This will normally link back to your site or can be used for tracking purposes. It's also possible if you have a URL based integration with unidays you may only recieve this property.
    var url: NSURL? { get }
}

// MARK: -
/// Simple implementation of the CodeResultProtocol
class CodeResult: CodeResultProtocol {
    
    let code: String?
    let imageUrl: NSURL?
    let url: NSURL?
    let expires: Date?
    
    init(code: String?, imageUrl: NSURL?, url: NSURL?, expires: Date?) {
        self.code = code
        self.imageUrl = imageUrl
        self.url = url
        self.expires = expires
    }
}
