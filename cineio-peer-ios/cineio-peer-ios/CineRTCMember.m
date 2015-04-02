//
//  CineRTCMember.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/26/15.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "CineRTCMember.h"
#import "CinePeerObserver.h"
#import "CineRemoteAnswerSDPObserver.h"
#import "CineRTCHelper.h"
#import "RTCSessionDescription.h"
#import "CineSignalingConnection.h"

// WebRTC includes
#import "RTCPeerConnection.h"


@interface CineRTCMember ()

@property (nonatomic, strong) NSString* sparkId;
@property (nonatomic, strong) NSString* sparkUUID;
@property (nonatomic, strong) RTCPeerConnection* peerConnection;
@property (nonatomic, strong) CinePeerObserver* peerObserver;
@property (nonatomic, strong) NSString* remoteAnswer;
@property (nonatomic, strong) NSDictionary* support;
@property (nonatomic, strong) CineSignalingConnection* signalingConnection;

@property BOOL iceGatheringComplete;
@property BOOL waitingToSendLocalDescription;

@end


@implementation CineRTCMember

@synthesize sparkId;
@synthesize sparkUUID;
@synthesize peerConnection;
@synthesize peerObserver;
@synthesize support;
@synthesize signalingConnection;

- (void)markIceComplete
{
    self.iceGatheringComplete = true;
    if (self.remoteAnswer){
        NSLog(@"markIceComplete remoteAnswer");
        [self setAnswerOnPeerConnection];
    }
    if (self.waitingToSendLocalDescription) {
        NSLog(@"markIceComplete waitingToSendLocalDescription");
        [self sendLocalDescription];
    }
}

- (void)localDescriptionReady
{
    if ([self supportsTrickleIce]) {
        NSLog(@"localDescriptionReady supports trickleIce");
        [self sendLocalDescription];
    } else if (self.iceGatheringComplete) {
        NSLog(@"localDescriptionReady sending because iceGatheringComplete");
        [self sendLocalDescription];
    } else {
        self.waitingToSendLocalDescription = true;
        NSLog(@"localDescriptionReady waiting for iceGatheringComplete");
    }

}

- (void)sendLocalDescription
{
    RTCSessionDescription* localDescription = [self.peerConnection localDescription];
    [self.signalingConnection sendLocalDescription:self.sparkId description:localDescription];
}

- (void)setRemoteAnswerAndSetIfIceIsComplete:(NSString *)remoteAnswer
{
    self.remoteAnswer = remoteAnswer;
    if (self.iceGatheringComplete){
        [self setAnswerOnPeerConnection];
    }
}

// The app crashes if we have not gotten our own ice candidates yet
// We need to wait for our own ice candidates before setting the remote answer
- (void)setAnswerOnPeerConnection
{
    RTCSessionDescription* sdp =
    [[RTCSessionDescription alloc] initWithType:@"answer"
                                            sdp:[CineRTCHelper preferISAC:self.remoteAnswer]];

    NSLog(@"got connection");

    CineRemoteAnswerSDPObserver *observer = [[CineRemoteAnswerSDPObserver alloc] init];

    [observer rtcMember:self];
    NSLog(@"set observer");

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"set description async in setAnswerOnPeerConnection");

        [self.peerConnection setRemoteDescriptionWithDelegate:(id)observer sessionDescription:sdp];
        NSLog(@"set description");
    });

    NSLog(@"set description from markIceComplete");
    self.remoteAnswer = nil;

}

- (BOOL)supportsTrickleIce
{
    return self.support[@"trickleIce"] != NO;
}

- (NSString *)getSparkId
{
    return self.sparkId;
}
- (RTCPeerConnection *)getPeerConnection
{
    return self.peerConnection;
}

- (CinePeerObserver *) getPeerObserver
{
    return self.peerObserver;
}

- (void)close
{
    if (self.peerConnection != nil) {
        [self.peerConnection close];
    }
    if (self.peerObserver != nil){
        [self.peerObserver close];
    }
}


@end
