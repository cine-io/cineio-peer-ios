//
//  SignalingConnection.m
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import "SignalingConnection.h"
#import <AVFoundation/AVFoundation.h>

#import <Primus/Primus.h>
#import <Primus/SocketRocketClient.h>

#import "CinePeerUtil.h"
#import "RTCMember.h"
#import "PeerConnectionManager.h"

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


@interface SignalingConnection ()

@property (nonatomic, strong) Primus *signalingServer;
@property (nonatomic, assign) BOOL initiator;
@property (nonatomic, strong) NSString *remoteSparkId;
@property (nonatomic, strong) RTCSessionDescription *localSDP;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) PeerConnectionManager *peerConnectionManager;
@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) NSString *uuid;

@end


@implementation SignalingConnection

@synthesize delegate;

- (id)initWithDelegate:(id<SignalingConnectionDelegate>)theDelegate
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
    }
    return self;
}

- (void)setPeerConnectionsManager:(PeerConnectionManager *)peerConnectionManager
{
    self.peerConnectionManager = peerConnectionManager;
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
    // for some reason I can't use /primus so it can't properly get the /spec
    // so i need to manually specify the timeout and ping
    options.autodetect = false;
    options.strategy = @[@(kPrimusReconnectionStrategyTimeout)];

    options.timeout = 35000;
    options.ping = pingInterval;
    NSLog(@"CONNECT");
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.139:8443/primus/websocket"];

    self.signalingServer = [[Primus alloc] initWithURL:url options:options];

    [self.signalingServer on:@"open" listener:^{
        NSLog(@"[open] - The connection has been established.");
        [self onOpen];
    }];

    [self.signalingServer on:@"reconnect" listener:^(PrimusReconnectOptions *options) {
        NSLog(@"Reconnect attempt %@ of %@", @(options.attempt), @(options.retries));
    }];

    [self.signalingServer on:@"data" selector:@selector(onData:withRaw:) target:self];
    [self.signalingServer on:@"error" selector:@selector(onError:) target:self];

    [self.signalingServer on:@"end" listener:^{
        NSLog(@"[end] - The connection has ended.");
    }];

    //    [self.signalingServer open];
    NSLog(@"CONNECTED");

}

- (void)send:(id)data
{
    NSLog(@"send, action:%@", [data valueForKey:@"action"]);

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"cineio-peer-ios version-" forKey:@"client"];
    [dict setValue:self.publicKey forKey:@"publicKey"];
    [dict setValue:@"NEED-TO-CREATE-UUID" forKey:@"uuid"];

    for (id key in data) {
        [dict setValue:[data objectForKey:key] forKey:key];
    }

    [self.signalingServer write:dict];
}

- (void)sendToOtherSpark:(NSString*)otherClientSparkId data:(id)data
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:otherClientSparkId forKey:@"sparkId"];

    for (id key in data) {
        [dict setValue:[data objectForKey:key] forKey:key];
    }

    [self send:dict];
}


- (void)onOpen
{
    NSLog(@"connected");
    [self send:@{@"action": @"auth"}];
}

// Signaling API
- (void)joinRoom:(NSString *)roomName
{
    [self send:@{@"action": @"room-join", @"room": roomName}];
}

- (void)leaveRoom:(NSString *)roomName
{
    [self send:@{@"action": @"room-leave", @"room": roomName}];
}

- (void)sendIceCandidate:(NSString *)sparkId candidate:(RTCICECandidate *)candidate;
{
    NSLog(@"sendIceCandidate");
    [self sendToOtherSpark:sparkId data:@{
                                          @"action": @"rtc-ice",
                                          @"candidate": @{
                                                  @"candidate": @{
                                                          @"sdpMLineIndex": @(candidate.sdpMLineIndex),
                                                          @"sdpMid": candidate.sdpMid,
                                                          @"candidate": candidate.sdp
                                                          }
                                                  }
                                          }];
}
//END Signaling api

- (void)handleOffer:(NSDictionary *)message
{
    [self.peerConnectionManager handleOffer:message[@"sparkUUID"] otherClientSparkId:message[@"sparkId"] offer:message[@"offer"]];
}

- (void)handleAnswer:(NSDictionary *)message
{
    [self.peerConnectionManager handleAnswer:message[@"sparkUUID"] otherClientSparkId:message[@"sparkId"] answer:message[@"answer"]];
}

// Signaling callbacks
- (void)roomJoin:(NSDictionary *)message
{
    NSString* otherClientSparkId = message[@"sparkId"];
    NSString* otherClientSparkUUID = message[@"sparkUUID"];
    [self.peerConnectionManager ensurePeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:true];
    [self sendToOtherSpark:otherClientSparkId data:@{@"action": @"room-announce", @"room": message[@"room"]}];

}

- (void)roomLeave:(NSDictionary *)message
{
    NSString* otherClientSparkId = message[@"sparkId"];
    NSString* otherClientSparkUUID = message[@"sparkUUID"];
    [self.peerConnectionManager closePeerConnection:otherClientSparkUUID];
    [self sendToOtherSpark:otherClientSparkId data:@{@"action": @"room-goodbye", @"room": message[@"room"]}];

}

- (void)roomAnnounce:(NSDictionary *)message
{
    NSString* otherClientSparkId = message[@"sparkId"];
    NSString* otherClientSparkUUID = message[@"sparkUUID"];
    [self.peerConnectionManager ensurePeerConnection:otherClientSparkUUID otherClientSparkId:otherClientSparkId offer:false];
}

- (void)roomGoodbye:(NSDictionary *)message
{
    NSString* otherClientSparkUUID = message[@"sparkUUID"];
    [self.peerConnectionManager closePeerConnection:otherClientSparkUUID];
}

//End callbacks

- (void)onError:(NSError *)error
{
    NSLog(@"ERROR: %@", error);
}

- (void)onData:(NSDictionary *)data withRaw:(id)raw
{
    NSLog(@"ON DATA WITH RAW");
    typedef void (^OnDataBlock)(NSDictionary*);
    NSDictionary *caseDict =
    @{
      // BASE
      @"ack": ^(NSDictionary *message) {
          NSLog(@"ack: %@", message);
      },
      @"rtc-servers": ^(NSDictionary *message) {
          NSArray *serverConfigs = message[@"data"];
          //            NSLog(@"got ICE servers: %@", serverConfigs);
          [self.peerConnectionManager configureICEServers:serverConfigs];
      },
      // END BASE
      // ROOMS
      @"room-join": ^(NSDictionary *message) {
          NSLog(@"room-join: %@", message);
          [self roomJoin:message];
      },
      @"room-leave": ^(NSDictionary *message) {
          NSLog(@"room-leave: %@", message);
          [self roomLeave:message];
      },
      @"room-announce": ^(NSDictionary *message) {
          NSLog(@"room-leave: %@", message);
          [self roomAnnounce:message];
      },
      @"room-goodbye": ^(NSDictionary *message) {
          NSLog(@"room-leave: %@", message);
          [self roomGoodbye:message];
      },
      // END ROOMS
      // RTC
      @"rtc-ice": ^(NSDictionary *message) {
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
      @"rtc-offer": ^(NSDictionary *message) {
          NSLog(@"got offer: %@", message);
          [self handleOffer:message];
      },
      @"rtc-answer": ^(NSDictionary *message) {
          NSLog(@"got answer: %@", message);
          [self handleAnswer:message];
      }
      //END RTC
    };

    OnDataBlock blk = caseDict[data[@"action"]];
    if (blk) {
        blk(data);
    } else {
        NSLog(@"unknown data: %@", data);
    }
}

- (void)sendLocalDescription:(NSString *)sparkId  description:(RTCSessionDescription *)description
{
    NSLog(@"sendLocalDescription signaling client");

    NSMutableString *rtcType = [[NSMutableString alloc] init];
    [rtcType appendString:@"rtc-"];
    [rtcType appendString:description.type];
    [self sendToOtherSpark:sparkId data:@{
                                          @"action": rtcType,
                                          description.type: @{
                                                  @"type": description.type,
                                                  @"sdp": description.description
                                                  }

                                          }];
}

- (void)sendLocalSDP
{
    [self.signalingServer write:@{
                                  @"source": @"iOS",
                                  @"action": self.localSDP.type,
                                  @"sparkId": self.remoteSparkId,
                                  }];
}

@end
