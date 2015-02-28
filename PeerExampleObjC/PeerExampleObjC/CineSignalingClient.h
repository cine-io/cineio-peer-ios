//
//  CineSignalingClient.h
//  PeerExampleObjC
//
//  Created by Jeffrey Wescott on 9/10/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CineSignalingClient;
@class PeerConnectionManager;
@class RTCICECandidate;
@class RTCSessionDescription;


@protocol CineSignalingClientDelegate <NSObject>

- (void)signalingClientDidReceiveHangup:(CineSignalingClient *)client;

- (void)signalingClient:(CineSignalingClient *)client didErrorWithMessage:(NSString *)message;

@end


@interface CineSignalingClient : NSObject

@property (nonatomic, weak) id<CineSignalingClientDelegate> delegate;

- (id)initWithDelegate:(id<CineSignalingClientDelegate>)delegate;
- (void)connect;
- (void)init:(NSString *)publicKey;
- (void)joinRoom:(NSString *)roomName;
- (void)setPeerConnectionsManager:(PeerConnectionManager *)peerConnectionManager;
- (void)sendIceCandidate:(NSString *)sparkId candidate:(RTCICECandidate *)candidate;
- (void)sendLocalDescription:(NSString *)sparkId  description:(RTCSessionDescription *)description;
@end
