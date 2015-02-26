    //
//  ViewController.m
//  PeerExampleObjC
//
//  Created by Jeffrey Wescott on 9/10/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "CineSignalingClient.h"
#import "RTCEAGLVideoView.h"

static CGFloat const kLocalViewPadding = 20;

@interface ViewController () <CineSignalingClientDelegate, RTCEAGLVideoViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *videosView;
@property (nonatomic, strong) RTCEAGLVideoView* localVideoView;
@property (nonatomic, strong) RTCEAGLVideoView* remoteVideoView;

@end

@implementation ViewController
{
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
}
            
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initializeVideoViews];
    NSURL *url = [NSURL URLWithString:@"http://signaling.cine.io/primus/websocket"];
    CineSignalingClient *signalingClient = [[CineSignalingClient alloc] initWithDelegate:self];
    [signalingClient connect:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeVideoViews {
    self.videosView.hidden = NO;
    self.remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.videosView.bounds];
    self.remoteVideoView.delegate = self;
    self.remoteVideoView.transform = CGAffineTransformMakeScale(-1, 1);
    [self.videosView addSubview:self.remoteVideoView];
    
    self.localVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.videosView.bounds];
    self.localVideoView.delegate = self;
    [self.videosView addSubview:self.localVideoView];

    [self updateVideoViewLayout];
}

- (void)updateVideoViewLayout {
    // TODO(tkchin): handle rotation.
    CGSize defaultAspectRatio = CGSizeMake(4, 3);
    CGSize localAspectRatio =
        CGSizeEqualToSize(_localVideoSize, CGSizeZero) ? defaultAspectRatio : _localVideoSize;
    CGSize remoteAspectRatio =
        CGSizeEqualToSize(_remoteVideoSize, CGSizeZero) ? defaultAspectRatio : _remoteVideoSize;
    
    CGRect remoteVideoFrame =
        AVMakeRectWithAspectRatioInsideRect(remoteAspectRatio, self.videosView.bounds);
    self.remoteVideoView.frame = remoteVideoFrame;
    
    CGRect localVideoFrame =
        AVMakeRectWithAspectRatioInsideRect(localAspectRatio, self.videosView.bounds);
    localVideoFrame.size.width = localVideoFrame.size.width / 3;
    localVideoFrame.size.height = localVideoFrame.size.height / 3;
    localVideoFrame.origin.x = CGRectGetMaxX(self.videosView.bounds) - localVideoFrame.size.width - kLocalViewPadding;
    localVideoFrame.origin.y = CGRectGetMaxY(self.videosView.bounds) - localVideoFrame.size.height - kLocalViewPadding;
    self.localVideoView.frame = localVideoFrame;
}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
    if (videoView == self.localVideoView) {
        _localVideoSize = size;
    } else if (videoView == self.remoteVideoView) {
        _remoteVideoSize = size;
    } else {
        NSParameterAssert(NO);
    }
    [self updateVideoViewLayout];
}

#pragma mark - CineSignalingClientDelegate

- (void)signalingClient:(CineSignalingClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)track
{
//    self.localVideoView.videoTrack = track;
}

- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)track
{
//    self.remoteVideoView.videoTrack = track;
}
- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteAudioTrack:(RTCAudioTrack *)track
{
    NSLog(@"received audio track");
}

- (void)signalingClientDidReceiveHangup:(CineSignalingClient *)client
{
    NSLog(@"received hangup");
}

- (void)signalingClient:(CineSignalingClient *)client didErrorWithMessage:(NSString *)message
{
    NSLog(@"ERROR: %@", message);
}

@end
