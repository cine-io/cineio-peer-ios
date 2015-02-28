//
//  LocalOfferSDPObserver.m
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CinePeerClient.h"
#import "LocalOfferSDPObserver.h"
#import "RTCSessionDescriptionDelegate.h"
#import "CinePeerUtil.h"
#import "RTCSessionDescription.h"
#import "RTCPeerConnection.h"
#import "RTCMember.h"


@interface LocalOfferSDPObserver () <RTCSessionDescriptionDelegate>
@property (nonatomic, strong) RTCMember* rtcMember;
@property (nonatomic, strong) CinePeerClient* cinePeerClient;
@property (nonatomic, strong) RTCSessionDescription* localSdp;
@end

@implementation LocalOfferSDPObserver

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
    NSLog(@"LocalOfferSDPObserver");
    NSLog(@"didCreateSessionDescription");
    self.localSdp = origSdp;


    RTCSessionDescription* sdp =
    [[RTCSessionDescription alloc] initWithType:origSdp.type
                                            sdp:[CinePeerUtil preferISAC:origSdp.description]];


    //TODO: That craziness that Android is doing with preferISAC

    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSAssert(NO, error.description);
            return;
        }
        [peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdp];
    });
}

- (void) sendLocalDescription
{
    NSLog(@"sendLocalDescription");

    [[self.cinePeerClient getSignalingConnection] sendLocalDescription:[self.rtcMember getSparkId] description:self.localSdp];
}

// Called when setting a local or remote description.
- (void)               peerConnection:(RTCPeerConnection *)peerConnection
    didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"LocalOfferSDPObserver");
    NSLog(@"didSetSessionDescriptionWithError");
    if (error) {
        NSLog(@"didSetSessionDescriptionWithError has error");
        NSAssert(NO, error.description);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didSetSessionDescriptionWithError no error");
        [self sendLocalDescription];
    });
}

@end
