//
//  CinePeerClient.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_CinePeerClient_h
#define PeerExampleObjC_CinePeerClient_h

#include "SignalingConnection.h"
#include "RTCMediaStream.h"
#include "RTCMediaConstraints.h"
@class CinePeerClient;
@class Identity;

@interface CinePeerClient : NSObject

//API METHODS
- (id)initWithConfig:(CinePeerClientConfig *)config;
- (void)joinRoom:(NSString *)roomName;
- (void)startMediaStream;
- (void)identify:(Identity *)identity;
//END API METHODS

- (void)addStream:(RTCMediaStream *)mediaStream;
- (void)removeStream:(RTCMediaStream *)mediaStream;

- (SignalingConnection *)getSignalingConnection;
- (RTCMediaConstraints*)constraintsForMedia;
- (RTCMediaConstraints*)constraintsForPeer;
@end
#endif
