//
//  SignalingConnection.m
//  cineio-peer-ios
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
#import "CinePeerClientConfig.h"
#import "Identity.h"
#import "Call.h"

// WebRTC includes
#import "RTCICECandidate.h"
#import "RTCSessionDescription.h"


@interface SignalingConnection ()

@property (nonatomic, strong) Primus *signalingServer;
@property (nonatomic, weak) CinePeerClientConfig *config;
@property (nonatomic, weak) PeerConnectionManager *peerConnectionManager;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) Identity *identity;
@property (nonatomic, strong) NSMutableDictionary *ongoingCalls;
@property (nonatomic, strong) NSMutableArray *joinedRooms;

@end


@implementation SignalingConnection

- (id)initWithConfig:(CinePeerClientConfig *)theConfig;
{
    NSLog(@"INIT");
    if (self = [super init]) {
        self.config = theConfig;
        self.uuid = [[NSUUID UUID] UUIDString];
        self.ongoingCalls = [[NSMutableDictionary alloc] init];
        self.joinedRooms = [[NSMutableArray alloc] init];
        [self connect];
    }
    return self;
}

- (void)setPeerConnectionsManager:(PeerConnectionManager *)peerConnectionManager
{
    self.peerConnectionManager = peerConnectionManager;
}

- (void)connect
{
    NSTimeInterval pingInterval = 25;
    PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];
    options.transformerClass = SocketRocketClient.class;
    // for some reason I can't use /primus so it can't properly get the /spec
    // so i need to manually specify the timeout and ping
    options.autodetect = false;

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
    [dict setValue:@"cineio-peer-ios version-0.0.1" forKey:@"client"];
    [dict setValue:[self.config getPublicKey] forKey:@"publicKey"];
    [dict setValue:self.uuid forKey:@"uuid"];
    if (self.identity != nil) {
        [dict setValue:[self.identity getIdentity] forKey:@"identity"];
    }

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
    [self sendIdentity];
    for (id roomName in self.joinedRooms) {
        [self sendJoinRoom:roomName];
    }
}

// Signaling API
- (void)joinRoom:(NSString *)roomName
{
    [self.joinedRooms addObject:roomName];
    [self sendJoinRoom:roomName];
}

- (void)sendJoinRoom:(NSString *)roomName
{
    [self send:@{@"action": @"room-join", @"room": roomName}];
}

- (void)leaveRoom:(NSString *)roomName
{
    [self.joinedRooms removeObject:roomName];
    [self send:@{@"action": @"room-leave", @"room": roomName}];
}
- (void)identify:(Identity *)theIdentity
{
    self.identity = theIdentity;
    [self sendIdentity];
}
- (void)sendIdentity
{
    [self send:@{
                 @"action": @"identify",
                 @"identity": [self.identity getIdentity],
                 @"timestamp": [NSNumber numberWithLong:[self.identity getTimestamp]],
                 @"signature": [self.identity getSignature]
                 }
     ];

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
- (void)rejectCall:(NSString *)roomName
{
    [self send:@{
                 @"action": @"call-reject",
                 @"room": roomName
                 }];
}

//END Signaling api
// Signaling callbacks
- (void)handleIce:(NSDictionary *)message
{
    [self.peerConnectionManager handleIce:message[@"sparkUUID"] otherClientSparkId:message[@"sparkId"] iceCandidate:message[@"offer"]];
}

- (void)handleOffer:(NSDictionary *)message
{
    [self.peerConnectionManager handleOffer:message[@"sparkUUID"] otherClientSparkId:message[@"sparkId"] offer:message[@"offer"]];
}

- (void)handleAnswer:(NSDictionary *)message
{
    [self.peerConnectionManager handleAnswer:message[@"sparkUUID"] otherClientSparkId:message[@"sparkId"] answer:message[@"answer"]];
}

- (void)handleError:(NSDictionary *)message
{
    NSLog(@"Got error");
    // todo handle error
    [[self.config getDelegate] handleError:message];
}

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

- (void)handleCall:(NSDictionary *)message
{
    NSLog(@"handleCall: %@", message);
    Call *call = [self callForRoom:message[@"room"] initated:false];
    [[self.config getDelegate] handleCall:call];

}
- (void)handleCallCancel:(NSDictionary *)message
{
    NSLog(@"handleCallCancel: %@", message);
    Call *call = [self callForRoom:message[@"room"] initated:false];
    [call cancelled:message[@"identity"]];

}
- (void)handleCallReject:(NSDictionary *)message
{
    NSLog(@"handleCallReject: %@", message);
    Call *call = [self callForRoom:message[@"room"] initated:false];
    [call rejected:message[@"identity"]];

    //    call.rejected(response.getString("identity"));
}

-(Call *)callForRoom:(NSString *)roomName initated:(BOOL)initiated
{
    Call *call = [self.ongoingCalls valueForKey:roomName];
    if (call == nil) {
        call = [[Call alloc]initWithRoom:roomName config:self.config signalingConnection:self initiated:initiated];
        [self.ongoingCalls setObject:call forKey:roomName];
        return call;
    }
    return call;
}


//End callbacks

- (void)onError:(NSError *)error
{
    NSLog(@"PRIMUS ERROR: %@", error);
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
      @"error": ^(NSDictionary *message) {
          [self handleError:message];
      },
      // END BASE
      // CALLING
      @"call": ^(NSDictionary *message) {
          NSLog(@"call: %@", message);
          [self handleCall:message];
      },
      @"call-cancel": ^(NSDictionary *message) {
          NSLog(@"call-cancel: %@", message);
          [self handleCallCancel:message];
      },
      @"call-reject": ^(NSDictionary *message) {
          NSLog(@"call-reject: %@", message);
          [self handleCallReject:message];
      },
      // END CALLING
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
          NSLog(@"got remote ICE candidate: %@", message);
          [self handleIce:message];
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


@end
