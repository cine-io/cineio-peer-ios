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
@class Identity;
@class SignalingConnection;
@class CinePeerClientConfig;

@interface CinePeerClient : NSObject

//API METHODS
- (id)initWithConfig:(CinePeerClientConfig *)config;
- (void)joinRoom:(NSString *)roomName;
- (void)startMediaStream;
- (void)identify:(Identity *)identity;
//END API METHODS

- (void)addStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection;
- (void)removeStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection;

- (SignalingConnection *)getSignalingConnection;
- (RTCMediaConstraints*)constraintsForMedia;
- (RTCMediaConstraints*)constraintsForPeer;
@end
#endif
