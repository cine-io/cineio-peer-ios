//
//  CineCall.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CineCall_h
#define cineioPeerIOS_CineCall_h

//Cine Peer SDK
@class CinePeerClientConfig;
@class SignalingConnection;

@interface CineCall : NSObject

- (id)initWithRoom:(NSString *)roomName config:(CinePeerClientConfig *)config signalingConnection:(SignalingConnection *)signalingConnection initiated:(BOOL)initiated;

- (void)answer;
- (void)reject;
- (void)hangup;

- (void)cancelled:(NSString *)identity;
- (void)rejected:(NSString *)identity;

@end

#endif
