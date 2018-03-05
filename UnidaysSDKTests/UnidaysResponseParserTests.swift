//
//  UnidaysResponseParserTests.swift
//  UnidaysSDKTests
//
//  Created by Adam Mitchell on 19/02/2018.
//  Copyright © 2018 UNiDAYS. All rights reserved.
//

import XCTest
@testable import UnidaysSDK

class UnidaysResponseParserTests: XCTestCase {
    
    var parser: ResponseParser!
    
    override func setUp() {
        self.parser = ResponseParser()
    }
    
    override func tearDown() {
        self.parser = nil
    }
    
    func testGivenAValidError_ParsesToErrorResult() {
        let url = self.getErrorUrl()
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Error(_):
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenAValidError_ParsesToErrorResultWithLocalizedDescription() {
        let expectedDescription = "test"
        let url = self.getErrorUrl(errorMessage: expectedDescription)
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Error(let error):
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenAValidError_ParsesToErrorResultWithMatchingErrorCode() {
        let expectedErrorCode = 123
        let url = self.getErrorUrl(errorCode: expectedErrorCode)
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Error(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, expectedErrorCode)
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenErrorResult_WhenItHasNoParams_ThenReturnsCouldNotParseError() {
        let url = URL(string: "samplescheme://\(Constants.failurePath)")! as NSURL
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Error(let error):
            switch error {
            case UnidaysError.CouldNotParseResponse:
                break
            default:
                XCTFail()
                break
            }
        default:
            XCTFail()
        }
    }
    
    func testGivenAnEmptySuccessResponse_ParsesToError() {
        let url = self.getPerkUrl(code: nil, image: nil, url: nil, expiresDate: nil)
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Error(_):
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenASuccessResponseWithCode_ParsesToPerk() {
        let url = self.getPerkUrl(code: "test", image: nil, url: nil, expiresDate: nil)
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Code(_):
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenASuccessResponseWithImage_ParsesToPerk() {
        let url = self.getPerkUrl(code: nil, image: "https://picsum.photos/100/100", url: nil, expiresDate: nil)
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Code(_):
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenASuccessResponseWithUrl_ParsesToPerk() {
        let url = self.getPerkUrl(code: nil, image: nil, url: "https://www.myunidays.com", expiresDate: nil)
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Code(_):
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenASuccessResponseWithExpiresDate_WhenThereAreNoOtherParameters_ThenParsesToError() {
        let url = self.getPerkUrl(code: nil, image: nil, url: nil, expiresDate: "2018-02-01T00:00:00Z")
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Error(_):
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenASuccessResponse_WhenItIncludesACodeAndAnExpiresDate_ThenParsesToPerk() {
        let url = self.getPerkUrl(code: "test", image: nil, url: nil, expiresDate: "2018-02-01T00:00:00Z")
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Code(_):
            break
        default:
            XCTFail()
            break
        }
    }
    
    func testGivenASuccessResponseWithParams_ParsesToPerkWithValuesSet() {
        
        let expectedCode = "code"
        let expectedImage = "https://picsum.photos/100/100"
        let expectedUrl = "https://www.myunidays.com"
        
        let url = self.getPerkUrl(code: expectedCode, image: expectedImage, url: expectedUrl, expiresDate: nil)
        let result = parser.getResult(fromURL: url)
        switch result {
        case .Code(let perk):
            XCTAssertEqual(perk.code, expectedCode)
            XCTAssertEqual(perk.imageUrl?.absoluteString, expectedImage)
            XCTAssertEqual(perk.url?.absoluteString, expectedUrl)
            break
        default:
            XCTFail()
            break
        }
    }
}

@available(iOS 10.0, *)
extension UnidaysResponseParserTests {
    
    
    func testGivenValidDateFormat_WhenUsingCurrentDateParser_ThenReturnsNonNilDate() {
        let dateString = "2018-01-01T00:00:00Z"
        let dateParser = DateParser()
        guard let _ = dateParser.getISO8601FromString(dateString) else {
            XCTFail()
            return
        }
    }
    
    func testGivenValidDateFormat_WhenUsingCurrentDateParser_ThenReturnsNonNilDateWithCorrectComponents() {
        let dateString = "2018-01-01T12:30:15Z"
        let dateParser = DateParser()
        guard let date = dateParser.getISO8601FromString(dateString) else {
            XCTFail()
            return
        }
        let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let components = Calendar.current.dateComponents(unitFlags, from: date)
        XCTAssertEqual(2018, components.year)
        XCTAssertEqual(1, components.month)
        XCTAssertEqual(1, components.day)
        XCTAssertEqual(12, components.hour)
        XCTAssertEqual(30, components.minute)
        XCTAssertEqual(15, components.second)
    }
}

extension UnidaysResponseParserTests {
    
    func testGivenValidDateFormat_WhenUseLegacyDateParser_ThenReturnsNonNilDate() {
        let dateString = "2018-01-01T01:01:01Z"
        let dateParser = LegacyDateParser()
        guard let _ = dateParser.getISO8601FromString(dateString) else {
            XCTFail()
            return
        }
    }
    
    func testGivenValidDateFormat_WhenUseLegacyDateParser_ThenReturnsDateWithCorrectComponents() {
        let dateString = "2018-01-01T12:30:15Z"
        let dateParser = LegacyDateParser()
        guard let date = dateParser.getISO8601FromString(dateString) else {
            XCTFail()
            return
        }
        let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let components = Calendar.current.dateComponents(unitFlags, from: date)
        XCTAssertEqual(2018, components.year)
        XCTAssertEqual(1, components.month)
        XCTAssertEqual(1, components.day)
        XCTAssertEqual(12, components.hour)
        XCTAssertEqual(30, components.minute)
        XCTAssertEqual(15, components.second)
    }
}

private extension UnidaysResponseParserTests {
    func getErrorUrl(errorCode: Int = 1, errorMessage: String = "test") -> NSURL {
        return URL(string: "samplescheme://\(Constants.failurePath)?\(Constants.errorCodeQueryParameterKey)=\(errorCode)&\(Constants.errorMessageQueryParameterKey)=\(errorMessage)")! as NSURL
    }
    
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
        guard let result = components.url else {
            fatalError()
        }
        return result as NSURL
    }
}
