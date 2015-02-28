//
//  RemoteAnswerSDPObserver.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_RemoteAnswerSDPObserver_h
#define PeerExampleObjC_RemoteAnswerSDPObserver_h

@class RemoteAnswerSDPObserver;
@class RTCMember;
@class CinePeerClient;

@interface RemoteAnswerSDPObserver : NSObject
- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end

#endif
