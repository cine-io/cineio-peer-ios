//
//  CineRTCMember.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 02/26/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

//Vendor
@class RTCPeerConnection;

//Cine Peer SDK
@class CinePeerObserver;

@interface CineRTCMember : NSObject

- (void)setSparkId:(NSString *)sparkId;

- (NSString *)getSparkId;

- (void)setSparkUUID:(NSString *)sparkUUID;

- (void)setPeerConnection:(RTCPeerConnection *)peerConnection;
- (RTCPeerConnection *)getPeerConnection;

- (void) setPeerObserver:(CinePeerObserver *)peerObserver;
- (CinePeerObserver *) getPeerObserver;

- (void) close;
@end
