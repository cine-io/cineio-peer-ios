//
//  CineLocalOfferSDPObserver.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CineLocalOfferSDPObserver_h
#define cineioPeerIOS_CineLocalOfferSDPObserver_h

//Cine Peer SDK
@class CinePeerClient;
@class CineRTCMember;

@interface CineLocalOfferSDPObserver : NSObject
- (void)rtcMember:(CineRTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end

#endif
