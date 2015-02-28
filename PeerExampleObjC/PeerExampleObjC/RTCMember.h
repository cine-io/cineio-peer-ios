//
//  RTCMember.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 02/26/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCPeerConnection.h"

@class RTCMember;
@class PeerObserver;

@interface RTCMember : NSObject

- (void)setSparkId:(NSString *)sparkId;

- (NSString *)getSparkId;

- (void)setSparkUUID:(NSString *)sparkUUID;

- (void)setPeerConnection:(RTCPeerConnection *)peerConnection;
- (RTCPeerConnection *)getPeerConnection;

- (void) setPeerObserver:(PeerObserver *)peerObserver;
- (PeerObserver *) getPeerObserver;

- (void) close;
@end
