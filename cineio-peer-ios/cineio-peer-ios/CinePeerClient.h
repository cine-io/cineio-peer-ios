//
//  CinePeerClient.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CinePeerClient_h
#define cineioPeerIOS_CinePeerClient_h


//Vendor
@class RTCMediaConstraints;
@class RTCMediaStream;
@class RTCPeerConnection;

//Cine Peer SDK
@class CineIdentity;
@class CineSignalingConnection;
@class CinePeerClientConfig;

@interface CinePeerClient : NSObject

//API METHODS
+ (void)setup;
+ (void)teardown;

- (id)initWithConfig:(CinePeerClientConfig *)config;
- (void)joinRoom:(NSString *)roomName;
- (void)startMediaStream;
- (void)identify:(CineIdentity *)identity;
- (void)call:(NSString *) identity;
//END API METHODS

- (void)addStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection;
- (void)removeStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection;

- (CineSignalingConnection *)getSignalingConnection;
- (RTCMediaConstraints*)constraintsForPeer;
@end
#endif
