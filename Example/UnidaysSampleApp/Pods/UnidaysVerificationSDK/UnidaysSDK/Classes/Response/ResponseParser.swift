//
//  UnidaysResponseParser.swift
//  UnidaysSDK
//
//  Created by Adam Mitchell on 16/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import Foundation
//MARK:-
/// A enum representations of the kind of results you can get from the SDK
enum ResponseResult {
    
    /// Represents the result of a successful getCode request
    case Code(CodeResultProtocol)
    /// Represents either an error in parsing or an error from Unidays
    case Error(Error)
}

//MARK:-
/// Types implementing DateParserProtocol are used to convert `String`s to `Date`s
protocol DateParserProtocol {
    
    /// Attempt to parse a date from an input string in ISO8601 format
    ///
    /// - parameter input: The string in ISO8601 format you want to attempt to parse
    ///
    /// - returns: The date if successfully parsed otherwise nil
    func getISO8601FromString(_ input: String) -> Date?
}
//MARK:-

// Responsible for parsing a `ResponseResult` from an `NSURL`
class ResponseParser {
    
    ///
    /// Get the ResponseResults from an `NSURL`.
    ///
    /// - parameter url: The `NSURL` with code.
    ///
    /// - returns: The ResponseResult which represents what kind of result it retrieved from the url.
    ///
    func getResult(fromURL url: NSURL) -> ResponseResult {
        
        if let _ = url.absoluteString?.range(of: Constants.failurePath) {
            
            let error = self.parseErrorResult(url: url)
            return .Error(error)
        } else {
            
            guard let result = self.parsePerkResult(url: url) else {
                return .Error(UnidaysError.CouldNotParseResponse)
            }
            return .Code(result)
        }
    }
}

private extension ResponseParser {
    
    /// Parse an `NSURL` into an `Error`
    ///
    /// - parameter url: The `NSURL` in which to try and convert into an `Error`
    ///
    /// - returns: The `Error` parsed from the `NSURL`
    func parseErrorResult(url: NSURL) -> Error {
        guard let components = URLComponents(url: url as URL, resolvingAgainstBaseURL: false) else {
            return UnidaysError.CouldNotParseResponse
        }
        var items = [String: URLQueryItem]()
        components.queryItems?.forEach({ (item) in
            items[item.name] = item
        })
        
        guard let errorCodeString = items[Constants.errorCodeQueryParameterKey]?.value,
            let errorCode = Int(errorCodeString),
            let errorMessage = items[Constants.errorMessageQueryParameterKey]?.value else {
                return UnidaysError.CouldNotParseResponse
        }
        
        let error = NSError(domain: "com.myunidays.unidayssdk", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        return error
    }
    
    /// Attempt to convert an `NSURL` into a CodeResultProtocol
    ///
    /// - parameter url: The `NSURL` in which to try and convert into a `CodeResultProtocol`
    ///
    /// - returns: A `CodeResultProtocol` if it was able to successfully parse the `NSURL` otherwise `nil`
    func parsePerkResult(url: NSURL) -> CodeResultProtocol? {
        let components = NSURLComponents(url: url as URL, resolvingAgainstBaseURL: true)
        guard let items = components?.queryItems, items.count > 0 else {
            return nil
        }
        
        var dictionary = [String: String]()
        
        for item in items {
            dictionary[item.name] = item.value
        }
        
        let code: String? = dictionary[Constants.codeQueryParameterKey]
        let image: String? = dictionary[Constants.imageQueryParameterKey]
        let accessUrlString: String? = dictionary[Constants.urlQueryParameterKey]
        let expires: String? = dictionary[Constants.expiresQueryParameterKey]
        
        guard image != nil || code != nil || accessUrlString != nil else {
            return nil
        }
        
        let imageUrl: NSURL?
        if let image = image, let url = NSURL(string: image) {
            imageUrl = url
        } else {
            imageUrl = nil
        }
        
        let accessUrl: NSURL?
        if let accessUrlString = accessUrlString, let url = NSURL(string: accessUrlString) {
            accessUrl = url
        } else {
            accessUrl = nil
        }
        
        let expiresDate: Date?
        if let expires = expires {
            expiresDate = self.getISO8601FromString(expires)
        } else {
            expiresDate = nil
        }
        
        return CodeResult(code: code, imageUrl: imageUrl, url: accessUrl, expires: expiresDate)
    }
    
    /// Attempt to parse a date from an input string in ISO8601 format
    ///
    /// - parameter input: The string in ISO8601 format you want to attempt to parse
    ///
    /// - returns: The date if successfully parsed otherwise nil
    func getISO8601FromString(_ input: String) -> Date? {
        let parser: DateParserProtocol
        
        if #available(iOS 10.0, *) {
            parser = DateParser()
        } else {
            parser = LegacyDateParser()
        }
        return parser.getISO8601FromString(input)
    }
}

/// Responsible for parsing dates in version of iOS greater than or equal to 10.0
@available(iOS 10.0, *)
class DateParser: DateParserProtocol {
    
    func getISO8601FromString(_ input: String) -> Date? {
        return ISO8601DateFormatter().date(from: input)
    }
}

/// Responsible for parsing dates in version of iOS earlier than 10.0
class LegacyDateParser: DateParserProtocol {
    
    func getISO8601FromString(_ input: String) -> Date? {
        // https://developer.apple.com/documentation/foundation/dateformatter
        // Working With Fixed Format Date Representations
        let isoDateFormatter = DateFormatter()
        isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        isoDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return isoDateFormatter.date(from: input)
    }
}
