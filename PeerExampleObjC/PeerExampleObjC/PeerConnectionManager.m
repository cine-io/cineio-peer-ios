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
#import "RTCMember.h"
#import "RemoteOfferSDPObserver.h"

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
#import "PeerObserver.h"


@interface PeerConnectionManager ()
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) NSMutableDictionary *rtcMembers;
@property (nonatomic, strong) RTCMediaStream *localMediaStream;
@property (nonatomic, strong) NSMutableArray *iceServers;
@property (nonatomic, strong) CinePeerClient *cinePeerClient;

@end


@implementation PeerConnectionManager

@synthesize localMediaStream;

- (id)initWithPeerClient:(CinePeerClient *)cinePeerClient
{
    if (self = [super init]) {
        self.cinePeerClient = cinePeerClient;
        self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
        self.rtcMembers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (RTCPeerConnectionFactory*)getFactory
{
    return self.peerConnectionFactory;
}

- (void)configureICEServers:(NSArray *)configDicts
{
    self.iceServers = [NSMutableArray array];
    for (NSDictionary* dict in configDicts) {
        NSString* url = dict[@"url"];
        NSString* username = dict[@"username"];
        NSString* credential = dict[@"credential"];
        username = username ? username : @"";
        credential = credential ? credential : @"";
        RTCICEServer* iceServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url]
                                                           username:username
                                                           password:credential];
        [self.iceServers addObject:iceServer];
    }
}

- (void)handleOffer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(NSDictionary *)offer
{
    NSLog(@"HANDLE OFFER");

    NSString* sdpString = offer[@"sdp"];
    RTCSessionDescription* sdp =
    [[RTCSessionDescription alloc] initWithType:offer[@"type"]
                                    sdp:[CinePeerUtil preferISAC:sdpString]];

    RTCMember *rtcMember = [self getPeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:false];
    NSLog(@"GOT member");

    RTCPeerConnection* conn = [rtcMember getPeerConnection];
    NSLog(@"got connection");

    RemoteOfferSDPObserver *observer = [[RemoteOfferSDPObserver alloc] init];
    [observer rtcMember:rtcMember cinePeerClient:self.cinePeerClient];
    [conn setRemoteDescriptionWithDelegate:(id)observer sessionDescription:sdp];

}

- (void)handleAnswer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId answer:(NSDictionary *)answer
{
    NSLog(@"HANDLE ANSWER");
}


- (void)ensurePeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer
{
    [self getPeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:offer];
}

- (RTCMember*)getPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer
{
    RTCMember *member = [self.rtcMembers objectForKey:otherClientSparkUUID];
    if (member != nil) {
        [member setSparkId:otherClientSparkId];
        return member;
    }
    return [self createPeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:offer];
}

- (RTCMember*)createPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer
{
    NSLog(@"creating new peer connection: %@", otherClientSparkUUID);
    RTCMember *member = [[RTCMember alloc] init];
    NSLog(@"created member");
    [member setSparkId:otherClientSparkId];
    NSLog(@"set spark id");
    [member setSparkUUID:otherClientSparkUUID];
    NSLog(@"set spark uuid");


    PeerObserver *observer = [[PeerObserver alloc] init];
    NSLog(@"created observer");

    [member setPeerObserver:observer];
    NSLog(@"set observer on member");

    [observer rtcMember:member cinePeerClient:self.cinePeerClient];
    NSLog(@"set member on observer");

    RTCPeerConnection *conn =
    [self.peerConnectionFactory peerConnectionWithICEServers:self.iceServers
                                                 constraints:[self.cinePeerClient constraintsForPeer]
                                                    delegate:(id)observer];
    NSLog(@"created peer connection");

    [conn addStream:self.localMediaStream];
    NSLog(@"added media stream");

    [member setPeerConnection:conn];
    NSLog(@"member prepared");

    [self.rtcMembers setObject:member forKey:otherClientSparkUUID];

    if (offer) {
        NSLog(@"offerring");
        [conn createOfferWithDelegate:(id)self constraints:[self.cinePeerClient constraintsForMedia]];
    }

    NSLog(@"returning member");

    return member;
}


@end
