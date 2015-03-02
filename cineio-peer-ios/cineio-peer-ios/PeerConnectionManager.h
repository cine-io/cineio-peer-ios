//
//  PeerConnectionManager.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 02/26/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

//Vendor
@class RTCMediaStream;
@class RTCPeerConnectionFactory;

//Cine Peer SDK
@class CinePeerClient;
@class RTCMember;

@interface PeerConnectionManager : NSObject

- (id)initWithPeerClient:(CinePeerClient *)cinePeerClient;
- (void)setLocalMediaStream:(RTCMediaStream *)localMediaStream;

- (RTCPeerConnectionFactory*)getFactory;

- (void)configureICEServers:(NSArray *)configDicts;

- (void)ensurePeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer;

- (RTCMember*)getPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer;
//- (RTCMember*)createPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer;

- (void)closePeerConnection:(NSString *)otherClientSparkUUID;

- (void)handleOffer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(NSDictionary *)offer;
- (void)handleAnswer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId answer:(NSDictionary *)answer;
- (void)handleIce:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId iceCandidate:(NSDictionary *)iceCandidate;

@end
