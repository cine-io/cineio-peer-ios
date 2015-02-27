//
//  CineSignalingClient.m
//  PeerExampleObjC
//
//  Created by Jeffrey Wescott on 9/10/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#import "CineSignalingClient.h"
#import <AVFoundation/AVFoundation.h>

#import <Primus/Primus.h>
#import <Primus/SocketRocketClient.h>

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


@interface CineSignalingClient () <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate>

@property (nonatomic, strong) Primus *signalingServer;
@property (nonatomic, strong) NSMutableArray *iceServers;
@property (nonatomic, assign) BOOL initiator;
@property (nonatomic, strong) NSString *remoteSparkId;
@property (nonatomic, strong) RTCSessionDescription *localSDP;
@property (nonatomic, strong) RTCMediaStream *localMediaStream;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) RTCVideoSource *videoSource;
@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) NSString *uuid;

@end


@implementation CineSignalingClient

@synthesize delegate;

- (id)initWithDelegate:(id<CineSignalingClientDelegate>)theDelegate
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
    }
    return self;
}

- (void)init:(NSString *)publicKey
{
    NSLog(@"INIT");

    self.publicKey = publicKey;
    [self connect];
}

- (void)connect
{
    NSTimeInterval pingInterval = 25;
    PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];
    options.transformerClass = SocketRocketClient.class;
    options.manual = YES;
    options.autodetect = false;
    options.timeout = 35000;
    options.ping = pingInterval;
    NSLog(@"CONNECT");
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.139:8443/primus/websocket"];

    self.signalingServer = [[Primus alloc] initWithURL:url options:options];
//        self.signalingServer = [[Primus alloc] initWithURL:url];

    [self.signalingServer on:@"open" listener:^{
        NSLog(@"[open] - The connection has been established.");
        [self onOpen];
    }];
    
    [self.signalingServer on:@"reconnect" listener:^(PrimusReconnectOptions *options) {
        NSLog(@"[reconnect] - We are scheduling a new reconnect attempt");
    }];

    [self.signalingServer on:@"data" selector:@selector(onData:withRaw:) target:self];
    [self.signalingServer on:@"error" selector:@selector(onError:) target:self];
    
    [self.signalingServer on:@"end" listener:^{
        NSLog(@"[end] - The connection has ended.");
    }];

    [self.signalingServer open];
    NSLog(@"CONNECTED");

}

- (void)send:(id)data
{
    NSLog(@"send");

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"cineio-peer-ios version-" forKey:@"client"];
    [dict setValue:self.publicKey forKey:@"publicKey"];
    [dict setValue:@"NEED-TO-CREATE-UUID" forKey:@"uuid"];

    for (id key in data) {
        [dict setValue:[data objectForKey:key] forKey:key];
    }
//    NSLog(@"send1");
//    [data setObject:@"cineio-peer-ios version-" forKey:@"client"];
//    NSLog(@"send2");
//    [data setObject:self.publicKey forKey:@"publicKey"];
//    NSLog(@"send3");

    [self.signalingServer write:dict];
//    [self.signalingServer write:@{
//                                  @"client": @"cineio-peer-ios version-", //TODO: set version
//                                  @"publicKey": self.publicKey,
//                                  @"uuid": @"NEED-TO-SET-UUID"
//                                  }];
}

- (void)onOpen
{
    NSLog(@"connected");
    [self send:@{@"action": @"auth"}];
//    [self.signalingServer write:@{
//                                  @"publicKey": self.publicKey,
//                                  @"action": @"auth",
//                                  @"uuid": @"NEED-TO-SET-UUID"
//                                  }];

}

- (void)joinRoom:(NSString *)roomName
{
    [self send:@{@"action": @"room-join", @"room": roomName}];
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

- (void)createLocalMediaStream
{
    self.localMediaStream = [self.peerConnectionFactory mediaStreamWithLabel:@"CINESTREAM"];
    
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
    NSString* cameraID = nil;
    for (AVCaptureDevice* captureDevice in
         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (captureDevice.position == AVCaptureDevicePositionFront) {
            cameraID = [captureDevice localizedName];
            break;
        }
    }
    NSAssert(cameraID, @"Unable to get the front camera id");
    
    RTCVideoCapturer* capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
    self.videoSource = [self.peerConnectionFactory
                        videoSourceWithCapturer:capturer
                        constraints:[[RTCMediaConstraints alloc] init]];
    RTCVideoTrack* localVideoTrack = [self.peerConnectionFactory videoTrackWithID:@"CINESTREAMv0"
                                                                           source:self.videoSource];
    if (localVideoTrack) {
        [self.localMediaStream addVideoTrack:localVideoTrack];
    }
    [self.delegate signalingClient:self didReceiveLocalVideoTrack:localVideoTrack];
#endif
    
    [self.localMediaStream addAudioTrack:[self.peerConnectionFactory audioTrackWithID:@"CINESTREAMa0"]];
}

- (RTCMediaConstraints*)constraintsForPeer
{
    NSArray *mandatoryConstraints = @[
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio"
                                                             value:@"true"],
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo"
                                                             value:@"true"]
                                      ];
    NSArray *optionalConstraints = @[
                                     [[RTCPair alloc] initWithKey:@"internalSctpDataChannels"
                                                            value:@"true"],
                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement"
                                                            value:@"true"]
                                     ];
    
    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                 optionalConstraints:optionalConstraints];
}


- (RTCMediaConstraints*)constraintsForMedia
{
    NSArray *mandatoryConstraints = @[
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio"
                                                             value:@"true"],
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo"
                                                             value:@"true"]
                                      ];
    
    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                 optionalConstraints:nil];
}


- (RTCPeerConnection *)createPeerConnection:(NSString *)sparkId asInitiator:(BOOL)initiator
{
    self.initiator = initiator;
    
    RTCPeerConnection *conn =
    [self.peerConnectionFactory peerConnectionWithICEServers:self.iceServers
                                                 constraints:[self constraintsForPeer]
                                                    delegate:self];

    [conn addStream:self.localMediaStream];
    
    if (self.initiator) {
        [conn createOfferWithDelegate:self constraints:[self constraintsForMedia]];
    }

    return conn;
}

- (RTCPeerConnection *)getPeerConnection:(NSString *)sparkId asInitiator:(BOOL)initator
{
    // TODO: handle multiple peers
    if (self.peerConnection) return self.peerConnection;
    
    self.peerConnection = [self createPeerConnection:sparkId asInitiator:initator];
    return self.peerConnection;
}

- (void)didReceiveRemoteOfferOrAnswer:(NSDictionary *)message
{
    // TODO: handle multi-person chat
    NSDictionary *sdpDict;
    if ([@"offer" isEqualToString:message[@"action"]]) {
        sdpDict = message[@"offer"];
    } else {
        sdpDict = message[@"answer"];
    }
    self.remoteSparkId = message[@"sparkId"];
    NSString* sdpString = sdpDict[@"sdp"];
    RTCSessionDescription* sdp =
    [[RTCSessionDescription alloc] initWithType:sdpDict[@"type"]
                                            sdp:[CinePeerUtil preferISAC:sdpString]];

    RTCPeerConnection *conn = [self getPeerConnection:self.remoteSparkId asInitiator:NO];
    [conn setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
}

- (void)didDetectNewMember:(NSDictionary *)message
{
    // TODO: handle multiple peers
    self.remoteSparkId = message[@"sparkId"];
    [self getPeerConnection:message[@"sparkId"] asInitiator:YES];
}

- (void)onError:(NSError *)error
{
    NSLog(@"ERROR:");

    NSLog(@"ERROR: %@", error);
}

- (void)onData:(NSDictionary *)data withRaw:(id)raw
{
    NSLog(@"ON DATA WITH RAW");
    typedef void (^OnDataBlock)(NSDictionary*);
    NSDictionary *caseDict =
    @{
        @"allservers": ^(NSDictionary *message) {
            NSArray *serverConfigs = message[@"data"];
            //NSLog(@"got ICE servers: %@", serverConfigs);
            [self configureICEServers:serverConfigs];
            [self createLocalMediaStream];
        },
        @"leave": ^(NSDictionary *message) {
            NSLog(@"leave: %@", message);
        },
        @"member": ^(NSDictionary *message) {
            NSLog(@"got new member: %@", message);
            [self didDetectNewMember:message];
        },
        @"ice": ^(NSDictionary *message) {
            NSDictionary *candidateDict = message[@"candidate"][@"candidate"];
            //NSLog(@"got remote ICE candidate: %@", message);
            NSString* sdpMid = candidateDict[@"sdpMid"];
            NSNumber* sdpLineIndex = candidateDict[@"sdpMLineIndex"];
            NSString* sdp = candidateDict[@"candidate"];
            RTCICECandidate* candidate = [[RTCICECandidate alloc] initWithMid:sdpMid
                                                                        index:sdpLineIndex.intValue
                                                                          sdp:sdp];
            [self.peerConnection addICECandidate:candidate];
        },
        @"offer": ^(NSDictionary *message) {
            NSLog(@"got offer: %@", message);
            [self didReceiveRemoteOfferOrAnswer:message];
        },
        @"answer": ^(NSDictionary *message) {
            NSLog(@"got answer: %@", message);
            [self didReceiveRemoteOfferOrAnswer:message];
        }
    };
    
    OnDataBlock blk = caseDict[data[@"action"]];
    if (blk) {
        blk(data);
    } else {
        NSLog(@"incoming data: %@", data);
    }
}


#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnectionOnError:(RTCPeerConnection *)peerConnection
{
    NSLog(@"peerConnectionOnError");
}

- (void)   peerConnection:(RTCPeerConnection *)peerConnection
    signalingStateChanged:(RTCSignalingState)stateChanged
{
    NSLog(@"signalingStateChanged: %u", stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream
{
    NSLog(@"addedStream");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAssert([stream.audioTracks count] == 1 || [stream.videoTracks count] == 1,
                 @"Expected audio or video track");
        NSAssert([stream.audioTracks count] <= 1, @"Expected at most 1 audio stream");
        NSAssert([stream.videoTracks count] <= 1, @"Expected at most 1 video stream");
        if ([stream.videoTracks count] != 0) {
            [self.delegate signalingClient:self didReceiveRemoteVideoTrack:stream.videoTracks[0]];
        }
        if ([stream.audioTracks count] != 0) {
            [self.delegate signalingClient:self didReceiveRemoteAudioTrack:stream.audioTracks[0]];
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream
{
    NSLog(@"removedStream");
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
    NSLog(@"peerConnectionOnRenegotiationNeeded");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState
{
    NSLog(@"iceConnectionChanged");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState
{
    NSLog(@"iceGatheringChanged");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate
{
    //NSLog(@"gotICECandidate: %@", candidate);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.signalingServer write:@{
                                      @"source": @"iOS",
                                      @"action": @"ice",
                                      @"sparkId": self.remoteSparkId,
                                      @"candidate": @{
                                              @"candidate": @{
                                                        @"sdpMLineIndex": @(candidate.sdpMLineIndex),
                                                        @"sdpMid": candidate.sdpMid,
                                                        @"candidate": candidate.sdp
                                                      }
                                              }
                                      }];
        });
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel
{
    NSLog(@"didOpenDataChannel");
}


#pragma mark - RTCSessionDescriptionDelegate

- (void)sendLocalSDP
{
    [self.signalingServer write:@{
                                  @"source": @"iOS",
                                  @"action": self.localSDP.type,
                                  @"sparkId": self.remoteSparkId,
                                  self.localSDP.type: @{
                                          @"type": self.localSDP.type,
                                          @"sdp": self.localSDP.description
                                          }
                                  }];
}

// Called when creating a session.
- (void)         peerConnection:(RTCPeerConnection *)peerConnection
    didCreateSessionDescription:(RTCSessionDescription *)origSdp
                          error:(NSError *)error
{
    NSLog(@"didCreateSessionDescription");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSAssert(NO, error.description);
            return;
        }
        
        self.localSDP =
            [[RTCSessionDescription alloc] initWithType:origSdp.type
                                                    sdp:[CinePeerUtil preferISAC:origSdp.description]];
        [self.peerConnection setLocalDescriptionWithDelegate:self
                                          sessionDescription:self.localSDP];
    });
}

// Called when setting a local or remote description.
- (void)               peerConnection:(RTCPeerConnection *)peerConnection
    didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"didSetSessionDescriptionWithError");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSAssert(NO, error.description);
            return;
        }

        if (self.initiator) {
            if (!self.peerConnection.remoteDescription) {
                [self sendLocalSDP];
            }
        } else {
            if (!self.peerConnection.localDescription) {
                    [self.peerConnection createAnswerWithDelegate:self
                                                      constraints:[self constraintsForMedia]];
            } else {
                [self sendLocalSDP];
            }
        }
    });
}

@end
