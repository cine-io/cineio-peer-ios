//
//  DigestHelper.h
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_DigestHelper_h
#define cineioPeerIOS_DigestHelper_h

@interface DigestHelper : NSObject
+(NSString*) sha1:(NSString*)input;
@end


#endif
