Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "UnidaysVerificationSDK"
s.summary = "The VerificationSDK allows you to retrieve a code directly from UNiDAYS."
s.requires_arc = true

s.version = "0.2.2"

s.license = { :type => "MIT", :file => "LICENSE" }

s.author = "MyUNiDAYS ltd"

s.homepage = "https://github.com/MyUNiDAYS/VerificationSDK.iOS.git"

s.source = { :git => "https://github.com/MyUNiDAYS/VerificationSDK.iOS.git", :tag => "#{s.version}"}

s.source_files = "UnidaysSDK/**/*"

s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

s.swift_version = "4.0"

end
