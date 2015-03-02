//
//  PeerObserver.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_PeerObserver_h
#define cineioPeerIOS_PeerObserver_h

//Cine Peer SDK
@class RTCMember;
@class CinePeerClient;

@interface PeerObserver : NSObject
- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
- (void)close;

@end
#endif
