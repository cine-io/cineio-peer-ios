//
//  SignalingConnection.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_SignalingConnection_h
#define PeerExampleObjC_SignalingConnection_h
#import <Foundation/Foundation.h>

@class SignalingConnection;
@class PeerConnectionManager;
@class RTCICECandidate;
@class RTCSessionDescription;


@protocol SignalingConnectionDelegate <NSObject>

- (void)signalingClientDidReceiveHangup:(SignalingConnection *)client;

- (void)signalingClient:(SignalingConnection *)client didErrorWithMessage:(NSString *)message;

@end


@interface SignalingConnection : NSObject

@property (nonatomic, weak) id<SignalingConnectionDelegate> delegate;

- (id)initWithDelegate:(id<SignalingConnectionDelegate>)delegate;
- (void)connect;
- (void)init:(NSString *)publicKey;
- (void)joinRoom:(NSString *)roomName;
- (void)leaveRoom:(NSString *)roomName;
- (void)setPeerConnectionsManager:(PeerConnectionManager *)peerConnectionManager;
- (void)sendIceCandidate:(NSString *)sparkId candidate:(RTCICECandidate *)candidate;
- (void)sendLocalDescription:(NSString *)sparkId  description:(RTCSessionDescription *)description;
@end


#endif
