//
//  PeerConnectionManager.m
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/26/15.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "RTCMember.h"
#import "PeerObserver.h"

// WebRTC includes
#import "RTCPeerConnection.h"


@interface RTCMember ()

@property (nonatomic, strong) NSString* sparkId;
@property (nonatomic, strong) NSString* sparkUUID;
@property (nonatomic, strong) RTCPeerConnection* peerConnection;
@property (nonatomic, strong) PeerObserver* peerObserver;

@end


@implementation RTCMember

@synthesize sparkId;
@synthesize sparkUUID;
@synthesize peerConnection;
@synthesize peerObserver;

- (NSString *)getSparkId
{
    return self.sparkId;
}
- (RTCPeerConnection *)getPeerConnection
{
    return self.peerConnection;
}

- (PeerObserver *) getPeerObserver
{
    return self.peerObserver;
}

- (void)close
{
    if (self.peerConnection != nil) {
        [self.peerConnection close];
    }
    if (self.peerObserver != nil){
        [self.peerObserver close];
    }
}


@end
