//
//  MediaStreamAndRenderer.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 3/1/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_MediaStreamAndRenderer_h
#define cineioPeerIOS_MediaStreamAndRenderer_h

@class RTCMediaStream;
@class RTCEAGLVideoView;
@class RTCPeerConnection;

@interface MediaStreamAndRenderer : NSObject
- (id)initWithStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local;
- (void)setView:(RTCEAGLVideoView *)view;
- (RTCMediaStream *)getMediaStream;
- (RTCEAGLVideoView *)getView;
- (void)setVideoSize:(CGSize)size videosView:(UIView *)videosView;
- (RTCPeerConnection *)getPeerConnection;
- (void)removeVideoRenderer;
- (void)cleanup;

@end
#endif
