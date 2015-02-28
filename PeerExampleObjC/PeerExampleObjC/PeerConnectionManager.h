//
//  PeerConnectionManager.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 02/26/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCPeerConnectionFactory.h"
#import "RTCMediaStream.h"

@class PeerConnectionManager;
@class CinePeerClient;
@class RTCMember;

@interface PeerConnectionManager : NSObject

- (id)initWithPeerClient:(CinePeerClient *)cinePeerClient;
- (void)setLocalMediaStream:(RTCMediaStream *)localMediaStream;

- (RTCPeerConnectionFactory*)getFactory;

- (void)configureICEServers:(NSArray *)configDicts;

- (void)ensurePeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer;

- (RTCMember*)getPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer;
- (RTCMember*)createPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer;

- (void)handleOffer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(NSDictionary *)offer;
- (void)handleAnswer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId answer:(NSDictionary *)answer;

@end
