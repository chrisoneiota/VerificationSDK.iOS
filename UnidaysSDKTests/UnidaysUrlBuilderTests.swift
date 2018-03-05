//
//  UnidaysUrlBuilder.swift
//  UnidaysSDKTests
//
//  Created by Adam Mitchell on 15/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import XCTest
@testable import UnidaysSDK

class UnidaysUrlBuilderTests: XCTestCase {
    
    func testGivenAValidRequest_BuilderDoesNotReturnNil() {
        let url = self.getSampleUrl()
        XCTAssertNotNil(url)
    }
    
    func testGivenACustomScheme_BuilderReturnsUrlWithSameScheme() {
        let expectedScheme = Constants.unidaysScheme
        let url = self.getSampleUrl(scheme: expectedScheme)!
        XCTAssert(url.absoluteString.starts(with: expectedScheme))
    }
    
    func testGivenAValidRequest_UrlContainsSuccessCallback() {
        let url = self.getSampleUrl()!
        XCTAssert(containsQueryParameter(url: url, name: Constants.successCallbackParameterKey))
    }
    
    func testGivenAValidRequestWithCustomScheme_UrlContainsSuccessCallbackWithCustomScheme() {
        let expectedScheme = "tobetested"
        let url = self.getSampleUrl(scheme: expectedScheme)!
        let query = queryForKey(url: url, name: Constants.successCallbackParameterKey)
        XCTAssertNotNil(query)
        let result: Bool
        if let value = query?.value {
            result = value.starts(with: expectedScheme)
        } else {
            result = false
        }
        XCTAssert(result)
    }
    
    func testGivenAValidRequest_UrlContainsFailureCallback() {
        let url = self.getSampleUrl()!
        XCTAssert(containsQueryParameter(url: url, name: Constants.errorCallbackParameterKey))
    }
    
    func testGivenAValidRequest_UrlContainsSDKVersionCallback() {
        let url = self.getSampleUrl()!
        XCTAssert(containsQueryParameter(url: url, name: Constants.sdkVersionCallbackParameterKey))
    }
    
    func testGivenAValidRequest_UrlContainsDebugQuery() {
        let url = self.getSampleUrl()!
        XCTAssert(containsQueryParameter(url: url, name: Constants.debugCallbackParameterKey))
    }
    
    func testGivenAValidRequest_UrlDebugQueryIsFalse() {
        let url = self.getSampleUrl(debug: false)!
        let queryParameter = queryForKey(url: url, name: Constants.debugCallbackParameterKey)
        XCTAssertEqual(queryParameter?.value, "false")
    }
    
    func testGivenAValidRequestWithDebugEnabled_UrlDebugQueryIsTrue() {
        let url = self.getSampleUrl(debug: true)!
        let queryParameter = queryForKey(url: url, name: Constants.debugCallbackParameterKey)
        XCTAssertEqual(queryParameter?.value, "true")
    }
}

private extension UnidaysUrlBuilderTests {
    
    func containsQueryParameter(url: URL, name: String) -> Bool {
        return queryForKey(url: url, name: name) != nil
    }
    
    func queryForKey(url: URL, name: String) -> URLQueryItem? {
        let components = URLComponents(url: url as URL, resolvingAgainstBaseURL: false)!
        return components.queryItems?.filter({ (item) -> Bool in
            return item.name == name
        }).first
    }
    
    func getSampleUrl(scheme: String = "testing", channel: UnidaysChannel = UnidaysChannel.Online, subdomain: String = "test", debug: Bool = false) -> URL? {
        let builder = UrlBuilder()
        let perkRequest = CodeRequest(channel: channel, subdomain: subdomain)
        return builder.generateAppURL(withRequest: perkRequest, forScheme: scheme, debug: debug) as URL?
    }
}
