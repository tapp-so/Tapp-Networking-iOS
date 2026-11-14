# Tapp-Networking iOS SDK

The networking package used by the Tapp iOS SDKs.

Swift Package Manager is the primary installation path.

## Swift Package Manager

In Xcode, choose **File → Add Packages…**, enter `https://github.com/tapp-so/Tapp-Networking-iOS.git`, and add the **TappNetworking** product.

For `Package.swift`, add this package dependency and the `TappNetworking` product to your target:

```swift
.package(url: "https://github.com/tapp-so/Tapp-Networking-iOS.git", from: "1.1.7")
```

## CocoaPods

CocoaPods releases after 1.1.7 are published only to [tapp-so/Specs](https://github.com/tapp-so/Specs).

Add both source lines at the top of your Podfile, in this order, then the pod:

```ruby
source 'https://github.com/tapp-so/Specs.git'   # must come first
source 'https://cdn.cocoapods.org/'

pod 'Tapp-Networking'
```

Both lines are required, in this order. Once a Podfile declares any source, CocoaPods stops adding trunk automatically, so the CDN line is needed for other pods.
