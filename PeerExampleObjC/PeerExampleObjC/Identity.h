//
//  Identity.h
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef PeerExampleObjC_Identity_h
#define PeerExampleObjC_Identity_h

@class Identity;

@interface Identity : NSObject

- (id) initWithName:(NSString *)identityName timestamp:(long)timestamp signature:(NSString *)signature;

- (NSString *)getIdentity;

- (NSString *)getSignature;

- (long) getTimestamp;

@end


#endif
