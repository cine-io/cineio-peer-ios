//
//  CinePeerConnectionManager.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/26/15.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import "CinePeerConnectionManager.h"
#import <AVFoundation/AVFoundation.h>

#import "CineRTCHelper.h"
#import "CineRTCMember.h"
#import "CineRemoteOfferSDPObserver.h"
#import "CineLocalOfferSDPObserver.h"
#import "CineRemoteAnswerSDPObserver.h"
#import "CinePeerClient.h"
#import "CinePeerObserver.h"

// WebRTC includes
#import "RTCICECandidate.h"
#import "RTCICEServer.h"
#import "RTCMediaStream.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription.h"


@interface CinePeerConnectionManager ()
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) NSMutableDictionary *rtcMembers;
@property (nonatomic, weak) RTCMediaStream *localMediaStream;
@property (nonatomic, strong) NSMutableArray *iceServers;
@property (nonatomic, weak) CinePeerClient *cinePeerClient;

@end


@implementation CinePeerConnectionManager

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
    NSLog(@"setIceServers");
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

- (void)handleOffer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(NSDictionary *)offer support:(NSDictionary *)support
{
    NSLog(@"HANDLE OFFER");

    NSString* sdpString = offer[@"sdp"];
    RTCSessionDescription* sdp =
    [[RTCSessionDescription alloc] initWithType:offer[@"type"]
                                            sdp:[CineRTCHelper preferISAC:sdpString]];

    CineRTCMember *rtcMember = [self getPeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:false support:support];
    NSLog(@"GOT member");

    RTCPeerConnection* conn = [rtcMember getPeerConnection];
    NSLog(@"got connection");

    CineRemoteOfferSDPObserver *observer = [[CineRemoteOfferSDPObserver alloc] init];
    [observer rtcMember:rtcMember cinePeerClient:self.cinePeerClient];
    [conn setRemoteDescriptionWithDelegate:(id)observer sessionDescription:sdp];

}

- (void)handleAnswer:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId answer:(NSDictionary *)answer support:(NSDictionary *)support
{
    NSLog(@"HANDLE ANSWER");

    CineRTCMember *rtcMember = [self getPeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:false support:support];
    NSLog(@"GOT member");

    NSString* sdpString = answer[@"sdp"];
    [rtcMember setRemoteAnswerAndSetIfIceIsComplete:sdpString];
}

- (void)handleIce:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId iceCandidate:(NSDictionary *)iceCandidate support:(NSDictionary *)support
{
    NSLog(@"disregarding ice candidates, I do not support trickle ice");

//    NSDictionary *candidateDict = iceCandidate[@"candidate"][@"candidate"];
//    NSString* sdpMid = candidateDict[@"sdpMid"];
//    NSNumber* sdpLineIndex = candidateDict[@"sdpMLineIndex"];
//    NSString* sdp = candidateDict[@"candidate"];
//    RTCICECandidate* candidate = [[RTCICECandidate alloc] initWithMid:sdpMid index:sdpLineIndex.intValue sdp:sdp];
//
//    CineRTCMember *rtcMember = [self getPeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:false];
//    NSLog(@"GOT member");
//
//    RTCPeerConnection* conn = [rtcMember getPeerConnection];
//    NSLog(@"got connection");
//
//    NSLog(@"set add ice async");
//    [conn addICECandidate:candidate];
//    NSLog(@"added ice");
//    NSLog(@"dispatched ice");

}



- (void)ensurePeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer support:(NSDictionary *)support
{
    [self getPeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:offer support:support];
}

- (CineRTCMember*)getPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer support:(NSDictionary *)support
{
    CineRTCMember *member = [self.rtcMembers objectForKey:otherClientSparkUUID];
    if (member != nil) {
        [member setSparkId:otherClientSparkId];
        return member;
    }
    return [self createPeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:offer support:support];
}

- (CineRTCMember*)createPeerConnection:(NSString *)otherClientSparkUUID otherClientSparkId:(NSString *)otherClientSparkId offer:(BOOL)offer support:(NSDictionary *)support
{
    NSLog(@"creating new peer connection: %@", otherClientSparkUUID);
    CineRTCMember *member = [[CineRTCMember alloc] init];
    NSLog(@"created member");
    [member setSparkId:otherClientSparkId];
    NSLog(@"set spark id");
    [member setSparkUUID:otherClientSparkUUID];
    NSLog(@"set spark uuid");

    [member setSupport:support];
    NSLog(@"created set support");

    [member setSignalingConnection:[self.cinePeerClient getSignalingConnection]];
    NSLog(@"set signaling connection");


    CinePeerObserver *observer = [[CinePeerObserver alloc] init];
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
        NSLog(@"dispatching offer");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Async create offer");
            CineLocalOfferSDPObserver *observer = [[CineLocalOfferSDPObserver alloc] init];
            [observer rtcMember:member cinePeerClient:self.cinePeerClient];

            NSLog(@"offerring");
            [conn createOfferWithDelegate:(id)observer constraints:[self.cinePeerClient constraintsForPeer]];
        });
    }

    NSLog(@"returning member");

    return member;
}

- (void)closePeerConnection:(NSString *)otherClientSparkUUID
{
    CineRTCMember *member = [self.rtcMembers objectForKey:otherClientSparkUUID];
    if (member == nil) {
        return;
    }
    [member close];
    [self.rtcMembers removeObjectForKey:otherClientSparkUUID];

}



@end
