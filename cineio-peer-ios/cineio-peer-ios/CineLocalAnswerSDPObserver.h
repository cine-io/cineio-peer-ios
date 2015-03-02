//
//  CineLocalAnswerSDPObserver.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CineLocalAnswerSDPObserver_h
#define cineioPeerIOS_CineLocalAnswerSDPObserver_h

//Cine Peer SDK
@class CinePeerClient;
@class CineRTCMember;

@interface CineLocalAnswerSDPObserver : NSObject
- (void)rtcMember:(CineRTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end

#endif
