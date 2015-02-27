//
//  CineSignalingClient.h
//  PeerExampleObjC
//
//  Created by Jeffrey Wescott on 9/10/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTCVideoTrack;
@class RTCAudioTrack;
@class CineSignalingClient;


@protocol CineSignalingClientDelegate <NSObject>

- (void)signalingClient:(CineSignalingClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)track;

- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)track;
- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteAudioTrack:(RTCAudioTrack *)track;

- (void)signalingClientDidReceiveHangup:(CineSignalingClient *)client;

- (void)signalingClient:(CineSignalingClient *)client didErrorWithMessage:(NSString *)message;

@end


@interface CineSignalingClient : NSObject

@property (nonatomic, weak) id<CineSignalingClientDelegate> delegate;

- (id)initWithDelegate:(id<CineSignalingClientDelegate>)delegate;
- (void)connect;
- (void)init:(NSString *)publicKey;
- (void)joinRoom:(NSString *)roomName;
@end
