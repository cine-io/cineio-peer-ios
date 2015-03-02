//
//  RemoteOfferSDPObserver.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RemoteOfferSDPObserver.h"
#import "LocalAnswerSDPObserver.h"
#import "RTCSessionDescriptionDelegate.h"
#import "CinePeerClient.h"
#import "RTCPeerConnection.h"
#import "RTCMember.h"


@interface RemoteOfferSDPObserver () <RTCSessionDescriptionDelegate>
@property (nonatomic, weak) RTCMember* rtcMember;
@property (nonatomic, weak) CinePeerClient* cinePeerClient;
@end

@implementation RemoteOfferSDPObserver

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
    NSLog(@"RemoteOfferSDPObserver");
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
    NSLog(@"RemoteOfferSDPObserver");
    NSLog(@"didSetSessionDescriptionWithError");
    if (error) {
        NSAssert(NO, error.description);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        LocalAnswerSDPObserver *observer = [[LocalAnswerSDPObserver alloc] init];
        [observer rtcMember:self.rtcMember cinePeerClient:self.cinePeerClient];
        [peerConnection createAnswerWithDelegate:(id)observer constraints:[self.cinePeerClient constraintsForMedia]];
    });
}

@end
