# VerificationSDK

This is beta documentation and is subject to change.

The VerificationSDK allows you to retrieve a code directly from UNiDAYS. The SDK will handle retrieving a code using your user's UNiDAYS credentials and then return it to your app.

### Cocoapods

Cocoapods can be used to install the UNiDAYS Verification SDK.

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate the UNiDAYS Verification SDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'UnidaysVerificationSDK', '0.2.1'
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage

### Example project

There are two example projects included in this repository, for both Swift and Objective-C.

### Add Unidays to your own project

#### 1. Make sure you define a custom scheme for your application

Info.plist -> URL types -> URL Schemes -> your-custom-scheme

![UNiDAYS Custom Scheme](https://raw.githubusercontent.com/MyUNiDAYS/VerificationSDK.iOS/develop/docs/usage-url-schemes.png)

It's very possible you already have one set but you can add a new one specifically for the SDK.

#### 2. Send your custom scheme to UNiDAYS.

We use the custom scheme to validate your integration with UNiDAYS.

#### 3. Add the Unidays query scheme to the Info.Plist

Info.plist -> LSApplicationQueriesSchemes -> `unidays-sdk`

![UNiDAYS Custom Scheme](https://raw.githubusercontent.com/MyUNiDAYS/VerificationSDK.iOS/develop/docs/usage-query-scheme.png)

#### 4. Setup the Unidays SDK

Within your `didFinishLaunchingWithOptions` method in the applications `AppDelegate`, setup the SDK with your customerID:

```swift
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        //Setup Unidays
        let scheme = "your_custom_scheme"

        // This is subdomain of the perk you want to get a code for. If in doubt what this is speak to your UNiDAYS representative.
        let subdomain = "partner_store"

        let settings = UnidaysConfig(scheme: scheme, customerSubdomain: subdomain)

        do {
            try sdk.setup(settings: settings)
        } catch {
            switch error {
                case UnidaysError.CFBundleURLSChemesNotSetError:
                // The scheme you've provided is not available in your info.plist we will not be able to return the user to your app correctly.
                break
                default:
                break
            }
        }

        return true
    }
```

#### 5. Call Unidays SDK and create a success and error handler

Call the Unidays SDK:

Where the variable `response` will contain a number of parameters whose contents are linked to your code type in the UNiDAYS system.

```swift
    func getCode() {
        // Perks have a channel. Either instore or online if your not sure which you should be using then speak to your unidays representative.
        let channel = UnidaysSDK.Channel.Online

        UnidaysSDK.sharedInstance.getCode(channel: channel), success: { (response)
            // Handle the code
            let code = response.code
            // Some codes may return an image url which you can use to show a barcode or QR code where relevant.
            let imageUrl = response.imageUrl
        }, error: { (error) in
            // Handle error has you deam appropriate
        }
    }
```

#### 6. Listen for callbacks from the Unidays app

Within your `application(app:open:options:)` method in the applications `AppDelegate`, listen for incoming callbacks:

```swift
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if UnidaysSDK.sharedInstance.process(url: url as NSURL) {
            // The UnidaysSDK handles this link and returns it to either your error handler or the success handler
            return true
        }
        return false
    }
```

## Debugging and Testing

The VerificationSDK does support a sandbox environment which allows you test different code types without having a verified user or a full integration. You will require a physical device with the ability to install the UNiDAYS native app.

You are not required to have fully integrated with UNiDAYS in order for this step to work.

#### 1. Enable debug mode on the SDK

```swift
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        //Setup Unidays
        var settings = UnidaysConfig(scheme: scheme, customerSubdomain: subdomain)
        // Make sure you switch this back off in production
        settings.isDebugEnabled = true

        // Continue setup as before
    }
```

#### 2. Call the UNiDAYS SDK

When you call the UNiDAYS SDK as described in the usage section, you will see the following screen open in the native UNiDAYS app:

![UNiDAYS Debug list screen](https://raw.githubusercontent.com/MyUNiDAYS/VerificationSDK.iOS/develop/docs/debug-list.png)

Here you can select from a list of stock responses in order to test your integration quickly. It will also allow to try different code types if you should wish to change them in the future.

#### 3. Submit or edit your response

You can either submit one of the pre-defined responses or edit one to suit your own needs.

![UNiDAYS Debug list screen](https://raw.githubusercontent.com/MyUNiDAYS/VerificationSDK.iOS/develop/docs/debug-edit-response.png)

Either way, using the pre-defined responses or editing one and clicking submit will result in the response being sent back to your app.

## License

VerificationSDK is available under a license. See the LICENSE file for more info.
