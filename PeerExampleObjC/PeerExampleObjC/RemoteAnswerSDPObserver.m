//
//  RemoteAnswerSDPObserver.m
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RemoteAnswerSDPObserver.h"
#import "LocalAnswerSDPObserver.h"
#import "RTCSessionDescriptionDelegate.h"
#import "CinePeerClient.h"
#import "RTCPeerConnection.h"


@interface RemoteAnswerSDPObserver () <RTCSessionDescriptionDelegate>
@property (nonatomic, strong) RTCMember* rtcMember;
@property (nonatomic, strong) CinePeerClient* cinePeerClient;
@end

@implementation RemoteAnswerSDPObserver

- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient
{
    self.rtcMember = member;
    self.cinePeerClient = cinePeerClient;
}

#pragma mark - RTCSessionDescriptionDelegate

- (void)         peerConnection:(RTCPeerConnection *)peerConnection
    didCreateSessionDescription:(RTCSessionDescription *)origSdp
                          error:(NSError *)error
{
    NSLog(@"RemoteAnswerSDPObserver");
    NSLog(@"SHOULD NOT CREATE REMOTE ANSWER");
}

// Called when setting a local or remote description.
- (void)               peerConnection:(RTCPeerConnection *)peerConnection
    didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"RemoteAnswerSDPObserver");
    NSLog(@"didSetSessionDescriptionWithError");
    if (error) {
        NSAssert(NO, error.description);
        return;
    }
}

@end
