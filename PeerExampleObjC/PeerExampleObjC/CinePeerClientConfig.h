//
//  CinePeerClientConfig.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_CinePeerClientConfig_h
#define PeerExampleObjC_CinePeerClientConfig_h


@class CinePeerClientConfig;
@class RTCMediaStream;

@protocol CinePeerClientDelegate <NSObject>
- (void) addStream:(RTCMediaStream *)stream local:(BOOL)local;
- (void) removeStream:(RTCMediaStream *)stream local:(BOOL)local;
- (void) handleError:(NSDictionary *)error;

//- (void)signalingClient:(CineSignalingClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)track;
//
//- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)track;
//- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteAudioTrack:(RTCAudioTrack *)track;
//
//- (void)signalingClientDidReceiveHangup:(CineSignalingClient *)client;
//
//- (void)signalingClient:(CineSignalingClient *)client didErrorWithMessage:(NSString *)message;

@end

@interface CinePeerClientConfig : NSObject
@property (nonatomic, weak) id<CinePeerClientDelegate> delegate;

- (NSString *)getPublicKey;

- (NSString *)getSecretKey;
- (void)setSecretKey:(NSString *)secretKey;

- (id) initWithPublicKey:(NSString *)publicKey delegate:(id<CinePeerClientDelegate>)delegate;

- (id<CinePeerClientDelegate>) getDelegate;
@end

#endif
