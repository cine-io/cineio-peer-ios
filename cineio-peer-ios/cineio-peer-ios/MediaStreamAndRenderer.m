//
//  MediaStreamAndRenderer.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 3/1/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "RTCMediaStream.h"
#import "RTCVideoTrack.h"
#import "RTCEAGLVideoView.h"
#import "MediaStreamAndRenderer.h"

@interface MediaStreamAndRenderer ()

@property (nonatomic, strong) RTCMediaStream* mediaStream;
@property (nonatomic, strong) RTCEAGLVideoView* view;
@property (nonatomic, strong) RTCPeerConnection* peerConnection;

@property BOOL local;

@end


@implementation MediaStreamAndRenderer

@synthesize view;

- (id)initWithStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)thePeerConnection local:(BOOL)local
{
    if (self = [super init]) {
        self.mediaStream = mediaStream;
        self.local = local;
        self.peerConnection = thePeerConnection;
    }
    return self;

}
- (RTCPeerConnection *)getPeerConnection
{
    return self.peerConnection;
}


- (RTCMediaStream *)getMediaStream
{
    return self.mediaStream;
}
//- (CGSize)getSize
//{
//    return self.size;
//}
- (void)setVideoSize:(CGSize)theSize videosView:(UIView *)videosView;
{
    CGSize defaultAspectRatio = CGSizeMake(4, 3);
    CGSize aspectRatio = CGSizeEqualToSize(theSize, CGSizeZero) ? defaultAspectRatio : theSize;
    CGRect videoFrame = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videosView.bounds);
    videoFrame.size.width = videoFrame.size.width / 3;
    videoFrame.size.height = videoFrame.size.height / 3;

//    self.videoFrame = videoFrame;
    self.view.frame = videoFrame;


//    self.size = theSize;
}

- (RTCEAGLVideoView *)getView
{
    return self.view;
}

- (void)cleanup
{
    if (self.view != nil){
                RTCVideoTrack *track = [[self.mediaStream videoTracks] firstObject];
                if (track != nil){
                    [track removeRenderer:self.view];
                }
        [self removeVideoRenderer];
    }
    self.view = nil;

}

- (void)removeVideoRenderer
{
    if (self.view != nil){
        if ([self.view superview] != nil){
            [self.view removeFromSuperview];
//            [self.view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        }
    }

}

@end
