//
//  PeerObserver.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_PeerObserver_h
#define PeerExampleObjC_PeerObserver_h

//Cine Peer SDK
@class RTCMember;
@class CinePeerClient;

@interface PeerObserver : NSObject
- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
- (void)close;

@end
#endif
