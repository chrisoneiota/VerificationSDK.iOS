//
//  UnidaysSDKTests.swift
//  UnidaysSDKTests
//
//  Created by Adam Mitchell on 20/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import XCTest
@testable import UnidaysSDK

class UnidaysSDKTests: XCTestCase {

    func testGivenValidResponse_ThenUnidaysSDKCallsSuccessHandler() {
        let sdk = UnidaysSDK(unidaysLauncher: MockLauncher(openUnidays: true, launchResult: true), settingsValidator: MockSettingsValidator())
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        
        let expectation = self.expectation(description: "waiting for success handler")
        sdk.getCode(channel: UnidaysChannel.Instore, success: { (result) in
            expectation.fulfill()
        }) { (error) in
            XCTFail()
            expectation.fulfill()
        }
        let url = getPerkUrl(code: "testing", image: nil, url: nil, expiresDate: nil)
        let handled = sdk.process(url: url)
        XCTAssert(handled)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGivenSuccessResponse_WhenItHasNoParameters_ThenUnidaysSDKCallsErrorHandler() {
        let sdk = UnidaysSDK(unidaysLauncher: MockLauncher(openUnidays: true, launchResult: true), settingsValidator: MockSettingsValidator())
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        
        let expectation = self.expectation(description: "waiting for error handler")
        sdk.getCode(channel: UnidaysChannel.Instore, success: { (result) in
            XCTFail()
            expectation.fulfill()
        }) { (error) in
            
            expectation.fulfill()
        }
        let url = getPerkUrl(code: nil, image: nil, url: nil, expiresDate: nil)
        let handled = sdk.process(url: url)
        XCTAssert(handled)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGivenLaunchUnidaysFails_WhenRequestingACode_ThenUnidaysSDKCallsErrorHandler() {
        
        let sdk = UnidaysSDK(unidaysLauncher: MockLauncher(openUnidays: true, launchResult: false), settingsValidator: MockSettingsValidator())
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        
        let expectation = self.expectation(description: "waiting for error handler")
        sdk.getCode(channel: UnidaysChannel.Instore, success: { (result) in
            XCTFail()
            expectation.fulfill()
        }) { (error) in
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGivenCanOpenUnidaysFails_WhenRequestingACode_ThenUnidaysSDKOpensProductPage() {
        
        let expectation = self.expectation(description: "waiting for product page")
        
        let productLaunch = MockProductLauncher() { (_) in
            expectation.fulfill()
        }
        
        let sdk = UnidaysSDK(productLauncher: productLaunch, unidaysLauncher: MockLauncher(openUnidays: false, launchResult: false), settingsValidator: MockSettingsValidator())
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        
        sdk.getCode(channel: UnidaysChannel.Online, success: { (result) in
            XCTFail()
        }) { (error) in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGivenProductPageCompletesSuccessfully_WhenUnidaysIsAvailableUpdates_ThenUnidaysSDKAttemptsToLaunchApp() {
        
        let expectation = self.expectation(description: "waiting for app to attempt to launch")
        let productExpectation = self.expectation(description: "Expecting product to launch")
        
        var helper = MockLauncher(openUnidays: false, launchResult: true)
        helper.launchExpectation = expectation
        
        let productLaunch = MockProductLauncher() { (delegate) in
            helper.openUnidays = true
            productExpectation.fulfill()
            delegate?.onProductViewDidFinish()
        }
        
        let sdk = UnidaysSDK(productLauncher: productLaunch, unidaysLauncher: helper, settingsValidator: MockSettingsValidator())
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        
        sdk.getCode(channel: UnidaysChannel.Online, success: { (result) in
            XCTFail()
        }) { (error) in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGivenTheProductPageFailsToLoadWithNilError_WhenTryingToGetCode_ThenUnidaysSDKCallsErrorHandler() {
        
        let expectation = self.expectation(description: "waiting for product page")
        
        let productLaunch = MockProductLauncher() { (delegate) in
            delegate?.onProductFailedToLoad(error: nil)
        }
        
        let sdk = UnidaysSDK(productLauncher: productLaunch, unidaysLauncher: MockLauncher(openUnidays: false, launchResult: false), settingsValidator: MockSettingsValidator())
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        
        sdk.getCode(channel: UnidaysChannel.Online, success: { (result) in
            XCTFail()
            expectation.fulfill()
        }) { (_) in
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGivenTheProductPageFailsToLoadWithError_WhenTryingToGetCode_ThenUnidaysSDKCallsErrorHandler() {
        
        let expectation = self.expectation(description: "waiting for product page")
        
        let expectedDomain = "mock_error"
        
        let productLaunch = MockProductLauncher() { (delegate) in
            delegate?.onProductFailedToLoad(error: NSError(domain: "mock_error", code: 0, userInfo: nil))
        }
        
        let sdk = UnidaysSDK(productLauncher: productLaunch, unidaysLauncher: MockLauncher(openUnidays: false, launchResult: false), settingsValidator: MockSettingsValidator())
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        
        sdk.getCode(channel: UnidaysChannel.Online, success: { (result) in
            XCTFail()
            expectation.fulfill()
        }) { (error) in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, expectedDomain)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGivenValidConfigurationSettings_WhenHelperReportsPlistNotSet_ThenSDKThrowsError() {
        let sdk = UnidaysSDK(unidaysLauncher: MockLauncher(openUnidays: true, launchResult: true))
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
            XCTFail()
        } catch {}
    }
    
    func testGivenUrlToProcess_WhenSettingsNotSet_SDKReturnsFalse() {
        let sdk = UnidaysSDK(unidaysLauncher: MockLauncher(openUnidays: true, launchResult: true))
        let url = getPerkUrl(code: "test", image: nil, url: nil, expiresDate: nil)
        let result = sdk.process(url: url)
        XCTAssertFalse(result)
    }
    
    func testGivenInvalidUrlToProcess_WhenSettingsSet_SDKReturnsFalse() {
        let sdk = UnidaysSDK(unidaysLauncher: MockLauncher(openUnidays: true, launchResult: true), settingsValidator: MockSettingsValidator())
        
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        
        let url = NSURL(string: "https://www.google.com")!
        let result = sdk.process(url: url)
        XCTAssertFalse(result)
    }
    
    func testGivenSetupHasNotBeenCompleted_WhenTryToGetCode_ThenUnidaysSDKCallsErrorHandler() {
        
        let expectation = self.expectation(description: "waiting for error to be thrown")
        
        let sdk = UnidaysSDK(unidaysLauncher: MockLauncher(openUnidays: true, launchResult: true))
        
        sdk.getCode(channel: UnidaysChannel.Online, success: { (result) in
            XCTFail()
            expectation.fulfill()
        }) { (_) in
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGivenUrlBuilderCannotGenereateRequest_WhenTryToGetCode_ThenUnidaysSDKCallsErrorHandler() {
        
        let expectation = self.expectation(description: "waiting for error to be thrown")
        let builder = MockUrlBuilder()
        builder.url = nil
        let sdk = UnidaysSDK(urlBuilder: builder, unidaysLauncher: MockLauncher(openUnidays: true, launchResult: true), settingsValidator: MockSettingsValidator())
        do {
            try sdk.setup(settings: UnidaysConfig(scheme: "samplescheme", customerSubdomain: "testing"))
        } catch {
            XCTFail()
        }
        sdk.getCode(channel: UnidaysChannel.Online, success: { (result) in
            XCTFail()
            expectation.fulfill()
        }) { (_) in
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
}

extension UnidaysSDKTests {
    
    func getPerkUrl(code: String?, image: String?, url: String?, expiresDate: String?) -> NSURL {
        var items = [URLQueryItem]()
        if let code = code {
            items.append(URLQueryItem(name: Constants.codeQueryParameterKey, value: code))
        }
        if let image = image {
            items.append(URLQueryItem(name: Constants.imageQueryParameterKey, value: image))
        }
        if let url = url {
            items.append(URLQueryItem(name: Constants.urlQueryParameterKey, value: url))
        }
        if let date = expiresDate {
            items.append(URLQueryItem(name: Constants.expiresQueryParameterKey, value: date))
        }
        guard var components = URLComponents(string: "samplescheme://\(Constants.successPath)") else {
            XCTFail()
            fatalError()
        }
        components.queryItems = items
        return (components.url as NSURL?)!
    }
}

private class MockUrlBuilder: UrlBuilder {
    
    var url: NSURL? = nil
    
    override func generateAppURL(withRequest request: Request, forScheme: String, debug: Bool?) -> NSURL? {
        return url
    }
}

private class MockProductLauncher: ProductLauncherProtocol {
    
    var delegate: ProductLauncherDelegate? = nil
    
    let showProductPageHandler: (ProductLauncherDelegate?) -> Void
    
    init(showProductPage: @escaping (ProductLauncherDelegate?) -> Void) {
        self.showProductPageHandler = showProductPage
    }
    
    func showProductPage() {
        self.showProductPageHandler(self.delegate)
    }
}

private class MockSettingsValidator: SettingsValidator {
    
    var error: Error? = nil
    
    override func validateSettings(_ settings: UnidaysConfig) throws {
        if let error = error {
            throw error
        }
    }
}

private class MockLauncher: UnidaysLauncherProtocol {
    
    var openUnidays: Bool
    var launchResult: Bool
    
    var launchExpectation: XCTestExpectation? = nil
    
    init(openUnidays: Bool, launchResult: Bool) {
        self.openUnidays = openUnidays
        self.launchResult = launchResult
    }
    
    func canOpenUnidays() -> Bool {
        return openUnidays
    }
    
    func launch(url: NSURL) -> Bool {
        launchExpectation?.fulfill()
        return launchResult
    }
}
