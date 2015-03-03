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

// WebRTC includes
#import "RTCPeerConnection.h"


@interface CineRTCMember ()

@property (nonatomic, strong) NSString* sparkId;
@property (nonatomic, strong) NSString* sparkUUID;
@property (nonatomic, strong) RTCPeerConnection* peerConnection;
@property (nonatomic, strong) CinePeerObserver* peerObserver;
@property (nonatomic, strong) NSString* remoteAnswer;

@property BOOL iceGatheringComplete;

@end


@implementation CineRTCMember

@synthesize sparkId;
@synthesize sparkUUID;
@synthesize peerConnection;
@synthesize peerObserver;

- (void)markIceComplete
{
    self.iceGatheringComplete = true;
    if (self.remoteAnswer){
        [self setAnswerOnPeerConnection];
    }
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
