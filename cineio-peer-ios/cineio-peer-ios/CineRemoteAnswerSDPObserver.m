//
//  CineRemoteAnswerSDPObserver.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CineRemoteAnswerSDPObserver.h"
#import "CineLocalAnswerSDPObserver.h"
#import "RTCSessionDescriptionDelegate.h"
#import "CinePeerClient.h"
#import "CineRTCMember.h"
#import "RTCPeerConnection.h"


@interface CineRemoteAnswerSDPObserver () <RTCSessionDescriptionDelegate>
@property (nonatomic, weak) CineRTCMember* rtcMember;
@property (nonatomic, weak) CinePeerClient* cinePeerClient;
@end

@implementation CineRemoteAnswerSDPObserver

- (void)rtcMember:(CineRTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient
{
    self.rtcMember = member;
    self.cinePeerClient = cinePeerClient;
}

#pragma mark - RTCSessionDescriptionDelegate

- (void)         peerConnection:(RTCPeerConnection *)peerConnection
    didCreateSessionDescription:(RTCSessionDescription *)origSdp
                          error:(NSError *)error
{
    NSLog(@"CineRemoteAnswerSDPObserver");
    NSLog(@"SHOULD NOT CREATE REMOTE ANSWER");
}

// Called when setting a local or remote description.
- (void)               peerConnection:(RTCPeerConnection *)peerConnection
    didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"CineRemoteAnswerSDPObserver");
    NSLog(@"didSetSessionDescriptionWithError");
    if (error) {
        NSAssert(NO, error.description);
        return;
    }
}

@end
