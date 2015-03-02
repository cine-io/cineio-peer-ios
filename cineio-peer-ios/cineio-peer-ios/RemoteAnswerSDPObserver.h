//
//  RemoteAnswerSDPObserver.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_RemoteAnswerSDPObserver_h
#define cineioPeerIOS_RemoteAnswerSDPObserver_h

//Cine Peer SDK
@class CinePeerClient;
@class RTCMember;

@interface RemoteAnswerSDPObserver : NSObject
- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end

#endif
