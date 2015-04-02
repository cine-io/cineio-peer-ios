//
//  CinePeerConnectionManager.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 02/26/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CinePeerConnectionManager_h
#define cineioPeerIOS_CinePeerConnectionManager_h

#import <Foundation/Foundation.h>

//Vendor
@class RTCMediaStream;
@class RTCPeerConnectionFactory;

//Cine Peer SDK
@class CinePeerClient;
@class CineRTCMember;

@interface CinePeerConnectionManager : NSObject

- (id)initWithPeerClient:(CinePeerClient *)cinePeerClient;
- (void)setLocalMediaStream:(RTCMediaStream *)localMediaStream;

- (RTCPeerConnectionFactory*)getFactory;

- (void)configureICEServers:(NSArray *)configDicts;

- (void)ensurePeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer support:(NSDictionary *)support;

- (CineRTCMember*)getPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer support:(NSDictionary *)support;

- (void)closePeerConnection:(NSString *)otherClientSparkUUID;

- (void)handleIce:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId iceCandidate:(NSDictionary *)iceCandidate support:(NSDictionary *)support;
- (void)handleOffer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(NSDictionary *)offer support:(NSDictionary *)support;
- (void)handleAnswer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId answer:(NSDictionary *)answer support:(NSDictionary *)support;

@end

#endif
