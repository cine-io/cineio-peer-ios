//
//  PeerConnectionManager.m
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/26/15.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import "PeerConnectionManager.h"
#import <AVFoundation/AVFoundation.h>

#import "CinePeerUtil.h"

// WebRTC includes
#import "RTCICECandidate.h"
#import "RTCICEServer.h"
#import "RTCMediaConstraints.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCStatsDelegate.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoSource.h"


@interface PeerConnectionManager ()
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;

@end


@implementation PeerConnectionManager

@synthesize delegate;

- (id)initWithDelegate:(id<PeerConnectionManagerDelegate>)theDelegate
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
    }
    return self;
}

- (void)ensurePeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer
{
    NSLog(@"DONE!");
}


@end
