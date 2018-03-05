//
//  ProductResponderTests.swift
//  UnidaysSDKTests
//
//  Created by Adam Mitchell on 21/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import XCTest
@testable import UnidaysSDK

class ProductResponderTests: XCTestCase {
    
    func testWhenErrorReportedWithNilValue_ThenProductResponderCallsCompletionHandler() {
        
        let expectation = self.expectation(description: "waiting for completion handler to be called")
        let responder = ProductResponder() { (error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        responder.onProductFailedToLoad(error: nil)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWhenErrorReportedWithValue_ThenProductResponderCallsCompletionHandlerWithError() {
        
        let expectation = self.expectation(description: "waiting for completion handler to be called")
        let responder = ProductResponder() { (error) in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        responder.onProductFailedToLoad(error: UnidaysError.ModeNotSupported)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWhenProductFinish_ThenProductResponderCallsCompletionHandlerWithNoError() {
        
        let expectation = self.expectation(description: "waiting for completion handler to be called")
        let responder = ProductResponder() { (error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        responder.onProductViewDidFinish()
        self.waitForExpectations(timeout: 5, handler: nil)
    }
}
