//
//  ViewController.m
//  PeerExampleObjC
//
//  Created by Jeffrey Wescott on 9/10/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "CinePeerClient.h"
#import "CinePeerClientConfig.h"
#import "Call.h"
#import "RTCEAGLVideoView.h"
#import "RTCVideoTrack.h"
#import "RTCMediaStream.h"
#import "MediaStreamAndRenderer.h"

static CGFloat const kLocalViewPadding = 20;

@interface ViewController () <RTCEAGLVideoViewDelegate, CinePeerClientDelegate>

@property (weak, nonatomic) IBOutlet UIView *videosView;
@property (strong, nonatomic) UIView *videosSubView;
@property (nonatomic, strong) NSMutableArray* videoViews;
//@property (nonatomic, strong) RTCEAGLVideoView* localVideoView;
//@property (nonatomic, strong) RTCEAGLVideoView* remoteVideoView;
@property (nonatomic, strong) CinePeerClient *cinePeerClient;
@end


@implementation ViewController
{
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoViews = [[NSMutableArray alloc] init];

    [self initializeVideoViews];

    NSString *publicKey = @"0b519f759096c48bf455941a02cf2c90";
    NSString *secretKey = @"d9c0f1cd4de4cf45616b350930dfb399";
    NSString *roomName = @"example";
    NSString *identityName = @"Thomas";

    CinePeerClientConfig *config = [[CinePeerClientConfig alloc] initWithPublicKey:publicKey delegate:self];
    [config setSecretKey:secretKey];

    self.cinePeerClient  = [[CinePeerClient alloc] initWithConfig:config];

    Identity *identity = [config generateIdentity:identityName];


    [self.cinePeerClient startMediaStream];

    [self.cinePeerClient identify:identity];

    [self.cinePeerClient joinRoom:roomName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeVideoViews {
    self.videosView.hidden = NO;
    [self resetVideoLayout];
}

- (void)resetVideoLayout {
    // TODO: handle rotation.

    NSLog(@"Reset video layout");
    for(MediaStreamAndRenderer* msr in self.videoViews){
        [msr removeVideoRenderer];
    }
    if (self.videosSubView != nil){
        NSLog(@"removing view");
        [self.videosSubView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    }
    self.videosSubView = [[UIView alloc] initWithFrame:self.videosView.frame];
    [self.videosView addSubview:self.videosSubView];

    NSUInteger index = 0;
    NSUInteger offset = 0;
    for(MediaStreamAndRenderer* msr in self.videoViews){
        offset = [self showMediaStream:msr index:index offset:offset];
        [self.videosSubView addSubview:[msr getView]];
        index++;
    }
}

- (int)showMediaStream:(MediaStreamAndRenderer *)msr index:(int)index offset:(int)offset
{
    NSLog(@"Showing media stream");

    RTCEAGLVideoView *renderer = [msr getView];
    CGRect videoFrame = renderer.frame;

    videoFrame.origin.x = CGRectGetMaxX(self.videosView.bounds) - videoFrame.size.width - offset - kLocalViewPadding;
    videoFrame.origin.y = CGRectGetMaxY(self.videosView.bounds) - videoFrame.size.height - kLocalViewPadding;
    renderer.frame = videoFrame;
    offset += (videoFrame.size.width + kLocalViewPadding);
    return offset;
}

#pragma mark - CinePeerClientDelegate
- (void) addStream:(RTCMediaStream *)stream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local
{
    NSLog(@"Got media stream");
    MediaStreamAndRenderer *msr = [[MediaStreamAndRenderer alloc] initWithStream:stream peerConnection:peerConnection local:local];

    RTCEAGLVideoView *renderer = [[RTCEAGLVideoView alloc] initWithFrame:self.videosView.bounds];
    renderer.delegate = self;

    RTCVideoTrack *track = [stream.videoTracks firstObject];
    [track addRenderer:renderer];

    [msr setView:renderer];

    [self.videoViews addObject:msr];
    [self resetVideoLayout];
}

- (MediaStreamAndRenderer *)getMediaStreamAndRendererForPeerConnection:(RTCPeerConnection *)peerConnection
{
    MediaStreamAndRenderer *msrToReturn = nil;
    for(MediaStreamAndRenderer* msr in self.videoViews){
        if ([msr getPeerConnection] == peerConnection)
            msrToReturn = msr;
    }
    return msrToReturn;
}
- (MediaStreamAndRenderer *)getMediaStreamAndRendererForView:(RTCEAGLVideoView *)view
{
    MediaStreamAndRenderer *msrToReturn = nil;
    for(MediaStreamAndRenderer* msr in self.videoViews){
        if ([msr getView] == view)
            msrToReturn = msr;
    }
    return msrToReturn;
}

- (void)removeStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local;
{
    NSLog(@"Remove stream");
    MediaStreamAndRenderer *msrToDelete = [self getMediaStreamAndRendererForPeerConnection:peerConnection];
    if (msrToDelete != nil){
        [msrToDelete cleanup];
        [self.videoViews removeObject:msrToDelete];
    }
    NSLog(@"Did removed");

    [self resetVideoLayout];
}

-(void) handleError:(NSDictionary *)error
{
    NSLog(@"ViewController got error: %@", error);
}

- (void) handleCall:(Call *)call
{
    NSLog(@"ViewController got call");
    //    [call answer];
}


- (void) onCallCancel:(Call *)call
{
    NSLog(@"ViewController got call cancel");
}

- (void) onCallReject:(Call *)call
{
    NSLog(@"ViewController got call reject");
}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
    NSLog(@"DID CHANGE SIZE");
    MediaStreamAndRenderer *msr = [self getMediaStreamAndRendererForView:videoView];
    if (msr != nil){
        [msr setVideoSize:size videosView:self.videosView];
    } else {
        NSParameterAssert(NO);
    }
    [self resetVideoLayout];
}

@end
