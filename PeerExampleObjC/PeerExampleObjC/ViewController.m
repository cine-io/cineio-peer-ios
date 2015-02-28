    //
//  ViewController.m
//  PeerExampleObjC
//
//  Created by Jeffrey Wescott on 9/10/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "SignalingConnection.h"
#import "PeerConnectionManager.h"
#import "RTCEAGLVideoView.h"
#import "RTCVideoTrack.h"
#import "RTCMediaStream.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoSource.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCMediaConstraints.h"
#import "CinePeerClient.h"
#import "CinePeerClientConfig.h"

static CGFloat const kLocalViewPadding = 20;

@interface ViewController () <RTCEAGLVideoViewDelegate, CinePeerClientDelegate>

@property (weak, nonatomic) IBOutlet UIView *videosView;
@property (nonatomic, strong) RTCEAGLVideoView* localVideoView;
@property (nonatomic, strong) RTCEAGLVideoView* remoteVideoView;
@property (nonatomic, strong) CinePeerClient *cinePeerClient;
@end


@implementation ViewController
{
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
}
            
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initializeVideoViews];

    NSString *publicKey = @"0b519f759096c48bf455941a02cf2c90";
    NSString *secretKey = @"d9c0f1cd4de4cf45616b350930dfb399";
    NSString *roomName = @"example";
    NSString *identityName = @"Thomas";

    CinePeerClientConfig *config = [[CinePeerClientConfig alloc] initWithPublicKey:publicKey delegate:self];
    [config setSecretKey:secretKey];

    self.cinePeerClient  = [[CinePeerClient alloc] initWithConfig:config];

    Identity *identity = [config generateIdentity:identityName];
    [self.cinePeerClient identify:identity];

    [self.cinePeerClient startMediaStream];

    [self.cinePeerClient joinRoom:roomName];
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

#pragma mark - CinePeerClientDelegate
- (void) addStream:(RTCMediaStream *)stream local:(BOOL)local
{
    RTCVideoTrack *track = [stream.videoTracks firstObject];
    if(local){
        [track addRenderer:self.localVideoView];
    }
    else{
        [track addRenderer:self.remoteVideoView];
    }
}

- (void) removeStream:(RTCMediaStream *)stream local:(BOOL)local
{
    RTCVideoTrack *track = [stream.videoTracks firstObject];
    if(local){
        [track removeRenderer:self.localVideoView];
    }
    else{
        [track removeRenderer:self.remoteVideoView];
    }
}

-(void) handleError:(NSDictionary *)error
{
    NSLog(@"ViewController got error: %@", error);
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

@end
