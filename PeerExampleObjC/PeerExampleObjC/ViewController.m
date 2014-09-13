//
//  ViewController.m
//  PeerExampleObjC
//
//  Created by Jeffrey Wescott on 9/10/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import "ViewController.h"
#import "CineSignalingClient.h"
#import "RTCEAGLVideoView.h"

@interface ViewController () <CineSignalingClientDelegate>

@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *remoteVideoView;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *localVideoView;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://smile.local:8888/primus/websocket"];
    CineSignalingClient *signalingClient = [[CineSignalingClient alloc] initWithDelegate:self];
    [signalingClient connect:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CineSignalingClientDelegate

- (void)signalingClient:(CineSignalingClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)track
{
    
}

- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)track
{
    
}
- (void)signalingClient:(CineSignalingClient *)client didReceiveRemoteAudioTrack:(RTCAudioTrack *)track
{
    
}

- (void)signalingClientDidReceiveHangup:(CineSignalingClient *)client
{
    
}

- (void)signalingClient:(CineSignalingClient *)client didErrorWithMessage:(NSString *)message
{
    
}

@end
