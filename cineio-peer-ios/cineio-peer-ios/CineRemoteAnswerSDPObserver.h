//
//  CineRemoteAnswerSDPObserver.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CineRemoteAnswerSDPObserver_h
#define cineioPeerIOS_CineRemoteAnswerSDPObserver_h

//Cine Peer SDK
@class CinePeerClient;
@class CineRTCMember;

@interface CineRemoteAnswerSDPObserver : NSObject
- (void)rtcMember:(CineRTCMember *)member;
@end

#endif
