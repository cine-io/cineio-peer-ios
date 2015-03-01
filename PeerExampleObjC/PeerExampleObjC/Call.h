//
//  Call.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_Call_h
#define PeerExampleObjC_Call_h

@class Call;
@class CinePeerClientConfig;
@class SignalingConnection;

@interface Call : NSObject

- (id)initWithRoom:(NSString *)roomName config:(CinePeerClientConfig *)config signalingConnection:(SignalingConnection *)signalingConnection initiated:(BOOL)initiated;

- (void)answer;
- (void)reject;
- (void)hangup;

- (void)cancelled:(NSString *)identity;
- (void)rejected:(NSString *)identity;

@end

#endif
