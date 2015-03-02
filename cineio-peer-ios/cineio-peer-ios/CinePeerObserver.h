//
//  CinePeerObserver.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CinePeerObserver_h
#define cineioPeerIOS_CinePeerObserver_h

//Cine Peer SDK
@class CineRTCMember;
@class CinePeerClient;

@interface CinePeerObserver : NSObject
- (void)rtcMember:(CineRTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
- (void)close;

@end
#endif
