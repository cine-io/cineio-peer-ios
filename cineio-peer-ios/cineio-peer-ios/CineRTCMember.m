//
//  CineRTCMember.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/26/15.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "CineRTCMember.h"
#import "CinePeerObserver.h"

// WebRTC includes
#import "RTCPeerConnection.h"


@interface CineRTCMember ()

@property (nonatomic, strong) NSString* sparkId;
@property (nonatomic, strong) NSString* sparkUUID;
@property (nonatomic, strong) RTCPeerConnection* peerConnection;
@property (nonatomic, strong) CinePeerObserver* peerObserver;

@end


@implementation CineRTCMember

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

- (CinePeerObserver *) getPeerObserver
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
