//
//  CinePeerClient.m
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "CinePeerClient.h"
#import "CineSignalingClient.h"
#import "PeerConnectionManager.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCVideoTrack.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoSource.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCMediaConstraints.h"

@interface CinePeerClient () <CineSignalingClientDelegate>
@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) PeerConnectionManager *connectionManager;
@property (nonatomic, strong) CineSignalingClient *signalingConnection;
@property (nonatomic, strong) RTCVideoSource *videoSource;
@property (nonatomic, strong) RTCMediaStream *localMediaStream;

@end

@implementation CinePeerClient

@synthesize delegate;

- (id)initWithDelegate:(id<CinePeerClientDelegate>)theDelegate
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.connectionManager = [[PeerConnectionManager alloc] initWithPeerClient:self];
        self.signalingConnection = [[CineSignalingClient alloc] initWithDelegate:self];
        [self.signalingConnection setPeerConnectionsManager:self.connectionManager];

    }
    return self;
}
- (void)init:(NSString *)publicKey
{
    NSLog(@"INIT peer client");

    self.publicKey = publicKey;
    [self.signalingConnection init:publicKey];
}

- (void)joinRoom:(NSString *)roomName
{
    [self.signalingConnection joinRoom:roomName];
}

- (void)startMediaStream
{
    RTCPeerConnectionFactory *factory = [self.connectionManager getFactory];
    self.localMediaStream = [factory mediaStreamWithLabel:@"ARDAMS"];

#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
    NSString* cameraID = nil;
    for (AVCaptureDevice* captureDevice in
         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (captureDevice.position == AVCaptureDevicePositionFront) {
            cameraID = [captureDevice localizedName];
            break;
        }
    }
    NSAssert(cameraID, @"Unable to get the front camera id");

    RTCVideoCapturer* capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
    self.videoSource = [factory
                        videoSourceWithCapturer:capturer
                        constraints:[[RTCMediaConstraints alloc] init]];

    RTCVideoTrack* localVideoTrack = [factory videoTrackWithID:@"ARDAMSv0"
                                                        source:self.videoSource];
    if (localVideoTrack) {
        [self.localMediaStream addVideoTrack:localVideoTrack];
    }

    [self.localMediaStream addAudioTrack:[factory audioTrackWithID:@"ARDAMSa0"]];

    [self.connectionManager setLocalMediaStream:self.localMediaStream];

    [self.delegate addStream:self.localMediaStream local:true];

#endif

}

- (void)addStream:(RTCMediaStream *)mediaStream
{
    [self.delegate addStream:mediaStream local:false];
}

- (CineSignalingClient *)getSignalingConnection
{
    return self.signalingConnection;
}

- (RTCMediaConstraints*)constraintsForPeer
{
    NSArray *mandatoryConstraints = @[
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio"
                                                             value:@"true"],
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo"
                                                             value:@"true"]
                                      ];
    NSArray *optionalConstraints = @[
                                     [[RTCPair alloc] initWithKey:@"internalSctpDataChannels"
                                                            value:@"true"],
                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement"
                                                            value:@"true"]
                                     ];

    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                 optionalConstraints:optionalConstraints];
}

- (RTCMediaConstraints*)constraintsForMedia
{
    NSArray *mandatoryConstraints = @[
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio"
                                                             value:@"true"],
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo"
                                                             value:@"true"]
                                      ];

    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                 optionalConstraints:nil];
}


#pragma mark - CineSignalingClientDelegate

- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)track
{
    //    self.remoteVideoView.videoTrack = track;
}
- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteAudioTrack:(RTCAudioTrack *)track
{
    NSLog(@"received audio track");
}

- (void)signalingClientDidReceiveHangup:(CineSignalingClient *)client
{
    NSLog(@"received hangup");
}

- (void)signalingClient:(CineSignalingClient *)client didErrorWithMessage:(NSString *)message
{
    NSLog(@"ERROR: %@", message);
}



@end