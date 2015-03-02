//
//  CineRemoteOfferSDPObserver.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CineRemoteOfferSDPObserver_h
#define cineioPeerIOS_CineRemoteOfferSDPObserver_h

//Cine Peer SDK
@class CinePeerClient;
@class CineRTCMember;

@interface CineRemoteOfferSDPObserver : NSObject
- (void)rtcMember:(CineRTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end

#endif
