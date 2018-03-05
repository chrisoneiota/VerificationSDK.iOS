//
//  UnidaysSDK.swift
//
//  Created by Adam Gask on 06/01/2016.
//
//

import UIKit

// MARK: -
/// A closure which handles a successful get code request
public typealias UNiDAYSCompletionHandlerBlock = (CodeResultProtocol) -> Void

/// A closure which handles an unidays get code request
public typealias UNiDAYSErrorHandlerBlock = (Error) -> Void

// MARK: -
/// The channel for a get code request.
@objc public enum UnidaysChannel: Int {
    case Online
    case Instore
}

// MARK: -
/// Responsible for being the consumable front for the UnidaysSDK. This class contains methods available to intergrating apps.
public class UnidaysSDK: NSObject {
    
    /// The shared instance to be used by integrating apps.
    @objc public static let sharedInstance: UnidaysSDK = UnidaysSDK()
    
    /// The settings applied to the UnidaysSDK
    private var settings: UnidaysConfig?
    
    /// The `UrlBuilder` for request from the SDK
    private let urlBuilder: UrlBuilder
    
    /// The `ResponseParser` used to parse responses provided to the SDK
    private let responseParser: ResponseParser
    
    /// Used to launch the product page when the native app isn't available
    private let productLauncher: ProductLauncherProtocol
    
    /// Used to launch unidays
    private let launcher: UnidaysLauncherProtocol
    
    /// Validate responses coming into the UnidaysSDK
    private let responseValidator: ResponseValidator
    
    /// Validates the `UnidaysConfig` passed in `setup(settings: UnidaysConfig)
    private let settingsValidator: SettingsValidator
    
    /// The success handler for a request
    private var successHandler: UNiDAYSCompletionHandlerBlock?
    
    /// The error handler for a request
    private var errorHandler: UNiDAYSErrorHandlerBlock?
    
    /// Setup the UNiDAYS SDK with your Customer ID.
    ///
    /// - parameter settings: The `UnidaysConfig` you wish to use with the SDK.
    ///
    /// - throws: An error if there was a problem validating your settings.
    @objc public func setup(settings: UnidaysConfig) throws -> Void {
        try self.settingsValidator.validateSettings(settings)
        self.settings = settings
    }
    
    init(urlBuilder: UrlBuilder = UrlBuilder(),
                  responseParser: ResponseParser = ResponseParser(),
                  productLauncher: ProductLauncherProtocol = ProductLauncher(),
                  unidaysLauncher: UnidaysLauncherProtocol = UnidaysNativeAppLauncher(),
                  responseValidator: ResponseValidator = ResponseValidator(),
                  settingsValidator: SettingsValidator = SettingsValidator()) {
        self.urlBuilder = urlBuilder
        self.responseParser = responseParser
        self.productLauncher = productLauncher
        self.launcher = unidaysLauncher
        self.responseValidator = responseValidator
        self.settingsValidator = settingsValidator
    }
    
    ///
    /// Method to get a UNiDAYS Code.
    ///
    /// - parameter channel: The type of code requested, either Online or Instore.
    ///
    /// - parameter success: The closure to handle a successful result of the get code request.
    ///
    /// - parameter error: The closure to handle an unsuccessful get code request
    @objc(getCodeWithChannel:withSuccessHandler:withErrorHandler:)
    public func getCode(channel: UnidaysChannel,
                        success: @escaping UNiDAYSCompletionHandlerBlock,
                        error: @escaping UNiDAYSErrorHandlerBlock) {
        guard let settings = self.settings else {
            error(UnidaysError.SetupNotCompletedError)
            return
        }
        self.successHandler = success
        self.errorHandler = error
        
        let request = CodeRequest(channel: channel, subdomain: settings.customerSubdomain)
        
        let launchOrReportError = {
            do {
                guard try self.launchUnidays(withRequest: request, withSettings: settings, withMode: settings.behaviourMode) else {
                    self.errorHandler?(UnidaysError.ModeNotSupported)
                    return
                }
            } catch {
                self.errorHandler?(error)
            }
        }
        
        if isBehaviourModeSupported(settings.behaviourMode) {
            launchOrReportError()
        } else {
            switch settings.behaviourMode {
            case .nativeAppOnly:
                self.productLauncher.delegate = ProductResponder(withCompletion: { (error) in
                    self.productLauncher.delegate = nil
                    if let error = error {
                        self.errorHandler?(error)
                    } else {
                        if self.isBehaviourModeSupported(settings.behaviourMode) {
                            launchOrReportError()
                        } else {
                            self.errorHandler?(UnidaysError.ModeNotSupported)
                        }
                    }
                })
                self.productLauncher.showProductPage()
                break
            }
        }
    }
    
    ///
    /// Method to process the URL response from the AppDelegate application.openURL() method. If the URL was intended for the UNiDAYS SDK, the block is passed the resulting code.
    ///
    /// - parameter url: The URL response from the AppDelegate application.openURL() method.
    ///
    /// - returns: `true` if the request was handled by the unidays SDK otherwise `false`
    @objc public func process(url: NSURL) -> Bool {
        guard let settings = self.settings else {
            return false
        }
        if self.responseValidator.validate(url: url as URL, withSettings: settings) {
            let code = self.responseParser.getResult(fromURL: url)
            switch code {
                
            case .Code(let result):
                if let successHandler = self.successHandler {
                    successHandler(result)
                }
                break
                
            case .Error(let error):
                if let errorHandler = self.errorHandler {
                    errorHandler(error)
                }
                break
            }
            return true
        }
        return false
    }
}

private extension UnidaysSDK {
    
    /// Launches unidays for the current request, settings and mode
    ///
    /// - parameter withRequest: The request to launch in unidays
    ///
    /// - parameter withSettings: The settings used to generate the request
    ///
    /// - parameter withMode: The specified mode to use to launch
    ///
    /// - throws: `UnidaysError.CouldNotGenerateRequestUrl` if it was unable to generate the url to launch
    ///
    /// - returns: `true` if able to launch unidays
    func launchUnidays(withRequest request: Request, withSettings settings: UnidaysConfig, withMode mode: BehaviourMode) throws -> Bool {
        
        switch mode {
        case .nativeAppOnly:
            guard let appUrl = self.urlBuilder.generateAppURL(withRequest: request, forScheme: settings.scheme, debug: settings.isDebugEnabled) else {
                 throw UnidaysError.CouldNotGenerateRequestUrl
            }
            return self.launcher.launch(url: appUrl)
        }
    }
    
    /// Checks if the behaviour mode is supported
    ///
    /// - parameter mode: The mode you want to try and launch
    ///
    /// - returns: `true` if the mode is supported
    func isBehaviourModeSupported(_ mode: BehaviourMode) -> Bool {
        switch mode {
        case .nativeAppOnly:
            return self.launcher.canOpenUnidays()
        }
    }
}
