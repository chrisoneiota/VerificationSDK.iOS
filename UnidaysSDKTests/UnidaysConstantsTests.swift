//
//  ConstantsTests.swift
//  UnidaysSDKTests
//
//  Created by Adam Mitchell on 22/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import XCTest
@testable import UnidaysSDK

class ConstantsTests: XCTestCase {
    
    func testGivenSDKVersionSet_WhenRequested_ThenReturnsExpectedValue() {
        let version = Constants.sdkVersion
        XCTAssertEqual("0.2.1", version)
    }
    
    func testGivenAUnidaysError_ThenReturnsNonTrivialDescription() {
        let values = [UnidaysError.CFBundleURLSchemesNotSetError,
                        UnidaysError.CouldNotGenerateRequestUrl,
                        UnidaysError.CouldNotParseResponse,
                        UnidaysError.ModeNotSupported,
                        UnidaysError.SetupNotCompletedError]
        
        for error in values {
            let description = error.localizedDescription
            XCTAssert(description.count > 0)
        }
    }
}

private extension ConstantsTests {
    
    func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
}
