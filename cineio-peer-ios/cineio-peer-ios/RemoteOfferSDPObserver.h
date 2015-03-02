//
//  RemoteOfferSDPObserver.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_RemoteOfferSDPObserver_h
#define cineioPeerIOS_RemoteOfferSDPObserver_h

//Cine Peer SDK
@class CinePeerClient;
@class RTCMember;

@interface RemoteOfferSDPObserver : NSObject
- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end

#endif
