//
//  PeerObserver.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/27/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_PeerObserver_h
#define PeerExampleObjC_PeerObserver_h

#import "CinePeerClient.h"

@class PeerObserver;
@class RTCMember;

@interface PeerObserver : NSObject
- (void)rtcMember:(RTCMember *)member cinePeerClient:(CinePeerClient *)cinePeerClient;
@end
#endif
