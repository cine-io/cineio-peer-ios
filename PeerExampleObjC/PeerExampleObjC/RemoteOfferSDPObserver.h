//
//  RemoteOfferSDPObserver.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_RemoteOfferSDPObserver_h
#define PeerExampleObjC_RemoteOfferSDPObserver_h

@class RemoteOfferSDPObserver;
@class RTCMember;
@class CinePeerClient;

@interface RemoteOfferSDPObserver : NSObject
- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end

#endif
