//
//  CineRemoteOfferSDPObserver.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CineRemoteOfferSDPObserver.h"
#import "CineLocalAnswerSDPObserver.h"
#import "RTCSessionDescriptionDelegate.h"
#import "CinePeerClient.h"
#import "RTCPeerConnection.h"
#import "CineRTCMember.h"


@interface CineRemoteOfferSDPObserver () <RTCSessionDescriptionDelegate>
@property (nonatomic, weak) CineRTCMember* rtcMember;
@property (nonatomic, weak) CinePeerClient* cinePeerClient;
@end

@implementation CineRemoteOfferSDPObserver

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
    NSLog(@"CineRemoteOfferSDPObserver");
    NSLog(@"SHOULD NOT CREATE REMOTE DESCRIPTION");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSAssert(NO, error.description);
            return;
        }
    });
}

// Called when setting a local or remote description.
- (void)               peerConnection:(RTCPeerConnection *)peerConnection
    didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"CineRemoteOfferSDPObserver");
    NSLog(@"didSetSessionDescriptionWithError");
    if (error) {
        NSAssert(NO, error.description);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CineLocalAnswerSDPObserver *observer = [[CineLocalAnswerSDPObserver alloc] init];
        [observer rtcMember:self.rtcMember cinePeerClient:self.cinePeerClient];
        [peerConnection createAnswerWithDelegate:(id)observer constraints:[self.cinePeerClient constraintsForPeer]];
    });
}

@end
