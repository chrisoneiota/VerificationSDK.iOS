//
//  SettingsValidatorTests.swift
//  UnidaysSDKTests
//
//  Created by Adam Mitchell on 22/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import XCTest
@testable import UnidaysSDK

class SettingsValidatorTests: XCTestCase {
    
    let validPlist = "Mock-Info"

    func testGivenValidInfoPlist_WhenValidatingSettings_ThenDoesNotThrow() {
        let bundle = Bundle(for: SettingsValidatorTests.self)
        let validator = SettingsValidator(bundle: bundle, resourceName: validPlist)
        let settings = UnidaysConfig(scheme: "sampleapp", customerSubdomain: "test")
        do {
            try validator.validateSettings(settings)
        } catch {
            XCTFail()
        }
    }
    
    func testGivenValidInfoPlist_WhenProvidedWithSettingsWithIncorrectScheme_ThenThrows() {
        let bundle = Bundle(for: SettingsValidatorTests.self)
        let validator = SettingsValidator(bundle: bundle, resourceName: validPlist)
        let settings = UnidaysConfig(scheme: "not-a-scheme", customerSubdomain: "test")
        do {
            try validator.validateSettings(settings)
            XCTFail()
        } catch {}
    }
}
