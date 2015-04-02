//
//  CinePeerObserver.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CinePeerObserver.h"
#import "CineRTCMember.h"
#import "CinePeerClient.h"
#import "CineSignalingConnection.h"
#import "RTCMediaStream.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnection.h"

@interface CinePeerObserver () <RTCPeerConnectionDelegate>
@property (nonatomic, weak) CineRTCMember* rtcMember;
@property (nonatomic, weak) RTCPeerConnection* peerConnection;
@property (nonatomic, strong) RTCMediaStream* addedStream;
@property (nonatomic, weak) CinePeerClient* cinePeerClient;
@end

@implementation CinePeerObserver


- (void)rtcMember:(CineRTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient
{
    self.rtcMember = member;
    self.cinePeerClient = cinePeerClient;
}

#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnectionOnError:(RTCPeerConnection *)peerConnection
{
    NSLog(@"peerConnectionOnError");
}

- (void)   peerConnection:(RTCPeerConnection *)peerConnection
    signalingStateChanged:(RTCSignalingState)stateChanged
{
    NSLog(@"signalingStateChanged: %u", stateChanged);
    if (stateChanged == RTCSignalingStable){
        NSLog(@"RTCSignalingStable");
    }
    else if (stateChanged == RTCSignalingHaveLocalOffer){
        NSLog(@"RTCSignalingHaveLocalOffer");
    }
    else if (stateChanged == RTCSignalingHaveLocalPrAnswer){
        NSLog(@"RTCSignalingHaveLocalPrAnswer");
    }
    else if (stateChanged == RTCSignalingHaveRemoteOffer){
        NSLog(@"RTCSignalingHaveRemoteOffer");
    }
    else if (stateChanged == RTCSignalingHaveRemotePrAnswer){
        NSLog(@"RTCSignalingHaveRemotePrAnswer");
    }
    else if (stateChanged == RTCSignalingClosed){
        NSLog(@"RTCSignalingClosed");
    } else{
        NSLog(@"unknown state");
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream
{
    NSLog(@"addedStream");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAssert([stream.audioTracks count] == 1 || [stream.videoTracks count] == 1,
                 @"Expected audio or video track");
        NSAssert([stream.audioTracks count] <= 1, @"Expected at most 1 audio stream");
        NSAssert([stream.videoTracks count] <= 1, @"Expected at most 1 video stream");
        self.addedStream = stream;
        [self.cinePeerClient addStream:stream peerConnection:[self.rtcMember getPeerConnection]];
        //        if ([stream.videoTracks count] != 0) {
        //            [self.cinePeerClient addStream]
        //            [self.delegate signalingClient:self didReceiveRemoteVideoTrack:stream.videoTracks[0]];
        //        }
        //        if ([stream.audioTracks count] != 0) {
        //            [self.delegate signalingClient:self didReceiveRemoteAudioTrack:stream.audioTracks[0]];
        //        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream
{
    NSLog(@"removedStream");
    [self disposeOfStream:stream peerConnection:peerConnection];
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
    NSLog(@"peerConnectionOnRenegotiationNeeded");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState
{
    NSLog(@"iceConnectionChanged");

    if (newState == RTCICEConnectionNew){
        NSLog(@"RTCICEConnectionNew");
    }
    else if (newState == RTCICEConnectionChecking){
        NSLog(@"RTCICEConnectionChecking");
    }
    else if (newState == RTCICEConnectionConnected){
        NSLog(@"RTCICEConnectionConnected");
    }
    else if (newState == RTCICEConnectionCompleted){
        NSLog(@"RTCICEConnectionCompleted");
    }
    else if (newState == RTCICEConnectionFailed){
        NSLog(@"RTCICEConnectionFailed");
    }
    else if (newState == RTCICEConnectionDisconnected){
        NSLog(@"RTCICEConnectionDisconnected");
    }
    else if (newState == RTCICEConnectionClosed){
        NSLog(@"RTCICEConnectionClosed");
    } else {
        NSLog(@"Other");
    }

}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState
{
    NSLog(@"iceGatheringChanged");
    if (newState == RTCICEGatheringComplete) {
//        peerConnection.localDescription
        NSLog(@"iceGatheringChanged complete");
        [self.rtcMember markIceComplete];
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate
{
    if ([self.rtcMember supportsTrickleIce]) {
        NSLog(@"gotICECandidate and sending: %@", candidate);

        NSString* sparkId = [self.rtcMember getSparkId];
        [[self.cinePeerClient getSignalingConnection] sendIceCandidate:sparkId candidate:candidate];
    }else {
        NSLog(@"gotICECandidate but not sending: %@", candidate);
    }

    //    //NSLog(@"gotICECandidate: %@", candidate);
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.signalingServer write:];
    //    });
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel
{
    NSLog(@"didOpenDataChannel");
}

- (void)close
{
    [self disposeOfStream:self.addedStream peerConnection:[self.rtcMember getPeerConnection]];
}

- (void)disposeOfStream:(RTCMediaStream *)stream peerConnection:(RTCPeerConnection *)peerConnection
{
    [self.cinePeerClient removeStream:stream peerConnection:peerConnection];
}


@end
