//
//  PeerConnectionManager.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 02/26/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PeerConnectionManager;

@protocol PeerConnectionManagerDelegate <NSObject>

//- (void)signalingClient:(CineSignalingClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)track;
//
//- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)track;
//- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteAudioTrack:(RTCAudioTrack *)track;
//
//- (void)signalingClientDidReceiveHangup:(CineSignalingClient *)client;
//
//- (void)signalingClient:(CineSignalingClient *)client didErrorWithMessage:(NSString *)message;

@end


@interface PeerConnectionManager : NSObject

@property (nonatomic, weak) id<PeerConnectionManagerDelegate> delegate;

- (id)initWithDelegate:(id<PeerConnectionManagerDelegate>)delegate;

- (void)ensurePeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer;

@end
