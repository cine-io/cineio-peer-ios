//
//  LocalAnswerSDPObserver.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_LocalAnswerSDPObserver_h
#define PeerExampleObjC_LocalAnswerSDPObserver_h

@class LocalAnswerSDPObserver;
@class RTCMember;
@class CinePeerClient;

@interface LocalAnswerSDPObserver : NSObject
- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end

#endif
