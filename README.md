# cineio-peer-ios

This is the [cine.io][cineio] [Peer][cineio-peer] iOS SDK. This
library allows you to integrate real-time live video and audio chat to your iOS application.
It is fully compatable with with the [cine.io Peer Android SDK][cineio-peer-android] and [cine.io peer JavaScript SDK][cineio-peer-js].

## Table of Contents

- [Installation](#installation)
- [Example Application](#example-application)
- [Basic Usage](#basic-usage)
- [Contributing](#contributing)

## Installation

The easiest way to use the SDK is via [CocoaPods][cocoapods]. Create a new
XCode project with a file named `Podfile` that contains the
following:

```ruby

pod 'cineio-peer-ios', '0.0.5'
```

Then, install the Pod by running the `pod install` command:

```bash
pod install
```

Then you can open the project using the `<project>.xcworkspace` file:

```bash
open <project>.xcworkspace
```

## Example Application

Check out the [cineio-peer-ios-example-app][cineio-peer-ios-example-app] repository
for a working example that use this SDK.

## Basic Usage

Start by including the necessary files
```objective-c
#import "CinePeerClient.h"
#import "CinePeerClientConfig.h"
#import "CineCall.h"
#import "CineIdentity.h" // Only necessary if your app requires identifying
#import "RTCMediaStream.h"
#import "RTCEAGLVideoView.h" // For displaying media strems
```

### Initializing

#### Create a CinePeerClientDelegate

For simplicity sake, let's make our `ViewController` a `CinePeerClientDelegate`

In ViewController.m

```
@interface ViewController () <CinePeerClientDelegate>

```

#### Create the CinePeerClient

In `ViewController.m`, because that's our `CinePeerClientDelegate`.

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *CINE_IO_PUBLIC_KEY = @"CINE_IO_PUBLIC_KEY";
    NSString *CINE_IO_SECRET_KEY = @"CINE_IO_SECRET_KEY";

    // Initialize the CinePeerClientConfig class
    // Pass in a CinePeerClientDelegate
    CinePeerClientConfig *config = [[CinePeerClientConfig alloc] initWithPublicKey:CINE_IO_PUBLIC_KEY delegate:self];

    // Create the peer client
    CinePeerClient *cinePeerClient  = [[CinePeerClient alloc] initWithConfig:config];
}
```

### `CinePeerClientDelegate` methods

You'll add the `CinePeerClientDelegate` methods to your `ViewController`.

```objective-c
// happens when a new peer joins, or your local camera and microphone starts
- (void) addStream:(RTCMediaStream *)stream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local;
// happens when a peer leaves, or your local camera and microphone stops
- (void) removeStream:(RTCMediaStream *)stream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local;
// when a new call comes in
- (void) handleCall:(CineCall *)call;
// when a call that came to you is cancelled
- (void) onCallCancel:(CineCall *)call;
// when a call that you sent out is rejected
- (void) onCallReject:(CineCall *)call;
// generic error catcher
- (void) handleError:(NSDictionary *)error;
```
### `CinePeerClient` Methods

#### Starting the camera and microphone

```objective-c
[cinePeerClient startMediaStream];
```

#### Joining a room

```objective-c
NSString *roomName = @"example";
[cinePeerClient joinRoom:roomName];
```

#### Identifying

You'll need to set the secretKey on the config to identify.

```objective-c
[config setSecretKey:CINE_IO_SECRET_KEY];

NSString *identityName = @"UNIQUE-IDENTITY";
CineIdentity *identity = [config generateIdentity:identityName];
[self.cinePeerClient identify:identity];
```

#### Calling an other identity

```objective-c
NSString *identityName = @"UNIQUE-IDENTITY-TO-CALL";
[self.cinePeerClient call:identity];
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


<!-- external links -->

[cineio]:https://www.cine.io/
[cineio-peer]:https://www.cine.io/products/peer
[cineio-peer-android]:https://github.com/cine-io/cineio-peer-android
[cineio-peer-js]:https://github.com/cine-io/peer-js-sdk
[cocoapods]:http://cocoapods.org/
[cineio-peer-ios-example-app]:https://github.com/cine-io/cineio-peer-ios-example-app
