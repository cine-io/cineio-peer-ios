//
//  CineSignalingClient.m
//  PeerExampleObjC
//
//  Created by Jeffrey Wescott on 9/10/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import "CineSignalingClient.h"
#import "CinePeerConnectionDelegate.h"
#import <Primus/Primus.h>
#import <Primus/SocketRocketClient.h>

// WebRTC includes
#import "RTCICECandidate.h"
#import "RTCICEServer.h"
#import "RTCMediaConstraints.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCStatsDelegate.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoSource.h"


@interface CineSignalingClient ()

@property (nonatomic, strong) Primus *signalingServer;
@property (nonatomic, strong) CinePeerConnectionDelegate *connectionDelegate;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) RTCVideoSource *videoSource;
@property (nonatomic, strong) NSMutableArray *queuedRemoteCandidates;

@end


@implementation CineSignalingClient

@synthesize delegate;

- (id)initWithDelegate:(id<CineSignalingClientDelegate>)theDelegate
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.connectionDelegate = [[CinePeerConnectionDelegate alloc] init];
        self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
    }
    return self;
}

- (void)connect:(NSURL *)url
{
    PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];
    options.transformerClass = SocketRocketClient.class;
    options.manual = YES;
    
    self.signalingServer = [[Primus alloc] initWithURL:url options:options];
    
    [self.signalingServer on:@"open" selector:@selector(onOpen) target:self];
    [self.signalingServer on:@"data" selector:@selector(onData:withRaw:) target:self];
    [self.signalingServer on:@"error" selector:@selector(onError:) target:self];
    
    [self.signalingServer open];
}

- (void)onOpen
{
    NSLog(@"connected");
    [self.signalingServer write:@{
                                  @"action": @"join",
                                  @"room": @(123)
                                  }];
}

- (NSArray *)parseICEServers:(NSArray *)configDicts
{
    NSMutableArray* servers = [NSMutableArray array];
    for (NSDictionary* dict in configDicts) {
        NSString* url = dict[@"url"];
        NSString* username = dict[@"username"];
        NSString* credential = dict[@"credential"];
        username = username ? username : @"";
        credential = credential ? credential : @"";
        RTCICEServer* iceServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url]
                                                           username:username
                                                           password:credential];
        [servers addObject:iceServer];
    }
    return servers;
}

- (void)didReceiveICEServers:(NSArray *)servers
{
    self.queuedRemoteCandidates = [NSMutableArray array];
    
    // set up the media constraints
    RTCMediaConstraints* constraints =
        [[RTCMediaConstraints alloc]
    initWithMandatoryConstraints:@[
                                   [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio"
                                                          value:@"true"],
                                   [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo"
                                                          value:@"true"]
                                   ]
             optionalConstraints:@[
                                   [[RTCPair alloc] initWithKey:@"internalSctpDataChannels"
                                                          value:@"true"],
                                   [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement"
                                                          value:@"true"]
                                   ]];

    self.peerConnection = [self.peerConnectionFactory peerConnectionWithICEServers:servers
                                                                       constraints:constraints
                                                                          delegate:self.connectionDelegate];

    RTCMediaStream *lms = [self.peerConnectionFactory mediaStreamWithLabel:@"CINESTREAM"];
    
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
    RTCVideoTrack* localVideoTrack;
    NSString* cameraID = nil;
    for (AVCaptureDevice* captureDevice in
         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (captureDevice.position == AVCaptureDevicePositionFront) {
            cameraID = [captureDevice localizedName];
            break;
        }
    }
    NSAssert(cameraID, @"Unable to get the front camera id");
    
    RTCVideoCapturer* capturer =
    [RTCVideoCapturer capturerWithDeviceName:cameraID];
    self.videoSource = [self.peerConnectionFactory
                        videoSourceWithCapturer:capturer
                        constraints:self.client.videoConstraints];
    localVideoTrack = [self.peerConnectionFactory videoTrackWithID:@"CINESTREAMv0"
                                                            source:self.videoSource];
    if (localVideoTrack) {
        [lms addVideoTrack:localVideoTrack];
    }
    [self.delegate connectionManager:self
           didReceiveLocalVideoTrack:localVideoTrack];
#endif
    
    [lms addAudioTrack:[self.peerConnectionFactory audioTrackWithID:@"CINESTREAMa0"]];
    [self.peerConnection addStream:lms constraints:constraints];
}

- (void)onError:(NSError *)error
{
    NSLog(@"ERROR: %@", error);
}

- (void)onData:(NSDictionary *)data withRaw:(id)raw
{
    typedef void (^OnDataBlock)(NSDictionary*);
    NSLog(@"incoming data: %@", data);
    NSDictionary *caseDict =
    @{
        @"allservers": ^(NSArray *serverConfigs) {
            NSLog(@"got ICE servers: %@", serverConfigs);
            [self didReceiveICEServers:[self parseICEServers:serverConfigs]];
        },
        @"leave": ^(NSDictionary *dict) {
            NSLog(@"leave: %@", dict);
        },
        @"member": ^(NSDictionary *dict) {
            NSLog(@"got new member: %@", dict);
            //newMember(data.sparkId, offer: true)
        },
        @"members": ^(NSDictionary *dict) {
            NSLog(@"got members: %@", dict);
        },
        @"ice": ^(NSDictionary *dict) {
            NSLog(@"got remote ice: %@", dict);
            //peerConnections[data.sparkId].processIce(data.candidate)
        },
        @"offer": ^(NSDictionary *dict) {
            NSLog(@"got offer: %@", dict);
//            roomSparkId = data.sparkId
//            pc = newMember(data.sparkId, offer: false)
//            pc.handleOffer data.offer, (err)->
//            console.log('handled offer', err)
//            peerConnections[data.sparkId].answer (err, answer)->
//            primus.write action: 'answer', answer: answer, sparkId: roomSparkId
        },
        @"answer": ^(NSDictionary *dict) {
            NSLog(@"got answer: %@", dict);
            //peerConnections[data.sparkId].handleAnswer(data.answer)
        }
    };
    
    OnDataBlock blk = caseDict[data[@"action"]];
    if (blk) {
        blk(data[@"data"]);
    } else {
        NSLog(@"default case");
    }
}

@end
