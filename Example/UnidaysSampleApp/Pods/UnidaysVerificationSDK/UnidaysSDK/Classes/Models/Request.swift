//
//  Request.swift
//  UnidaysSDK
//
//  Created by Adam Mitchell on 16/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import Foundation
//MARK: -
/// Types which implement `Request` are convertable to `URL` via the `UrlBuilder`
protocol Request {
    /// The type of request this is
    var type: RequestType { get }
    
    /// Additional parameters to be added to the request
    func params() -> [String: String]
}

//MARK: -
/// Responsible for providing the path for the `URL`
enum RequestType {
    
    /// A `RequestType` which is responsible for fetching a code from Unidays
    case Code
    
    /// Get the path for the current `RequestType`
    ///
    /// - returns: The path for this request type
    func getPath() -> String {
        switch self {
        case .Code:
            return Constants.getCodePath
        }
    }
}

//MARK: -
/// Represents a `Request` for a code from Unidays
struct CodeRequest {
    
    /// The channel of code to be fetched
    let channel: UnidaysChannel
    
    /// The Perk subdomain for the code
    let subdomain: String
    
    let type = RequestType.Code
}

extension CodeRequest: Request {
    
    func params() -> [String : String] {
        return [
            "subdomain": subdomain,
            "channel": self.channel.toString()
        ]
    }
}

//MARK: -
extension UnidaysChannel {
    
    /// Convert the unidays channel to a string
    ///
    /// - returns: A string representation of the `UnidaysChannel`
    func toString() -> String {
        switch self {
        case .Online:
            return "online"
        case .Instore:
            return "instore"
        }
    }
}
