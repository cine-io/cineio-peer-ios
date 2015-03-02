//
//  Identity.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_Identity_h
#define cineioPeerIOS_Identity_h

@interface Identity : NSObject

- (id) initWithName:(NSString *)identityName timestamp:(long)timestamp signature:(NSString *)signature;

- (NSString *)getIdentity;

- (NSString *)getSignature;

- (long) getTimestamp;

@end


#endif
