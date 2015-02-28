//
//  CinePeerClient.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_CinePeerClient_h
#define PeerExampleObjC_CinePeerClient_h

#include "CineSignalingClient.h"
#include "RTCMediaStream.h"
#include "RTCMediaConstraints.h"
@class CinePeerClient;

@protocol CinePeerClientDelegate <NSObject>
- (void) addStream:(RTCMediaStream *)stream local:(BOOL)local;

//- (void)signalingClient:(CineSignalingClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)track;
//
//- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)track;
//- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteAudioTrack:(RTCAudioTrack *)track;
//
//- (void)signalingClientDidReceiveHangup:(CineSignalingClient *)client;
//
//- (void)signalingClient:(CineSignalingClient *)client didErrorWithMessage:(NSString *)message;

@end

@interface CinePeerClient : NSObject
@property (nonatomic, weak) id<CinePeerClientDelegate> delegate;

- (id)initWithDelegate:(id<CinePeerClientDelegate>)delegate;
- (void)init:(NSString *)publicKey;
- (void)joinRoom:(NSString *)roomName;
- (void)startMediaStream;
- (void)addStream:(RTCMediaStream *)mediaStream;
- (CineSignalingClient *)getSignalingConnection;
- (RTCMediaConstraints*)constraintsForMedia;
- (RTCMediaConstraints*)constraintsForPeer;

@end
#endif
