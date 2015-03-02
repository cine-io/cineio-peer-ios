//
//  CineRTCHelper.h
//  cineio-peer-ios
//
//  Created by Jeffrey Wescott on 9/12/14.
//  Copyright (c) 2014 cine.io. All rights reserved.
//

#ifndef cineioPeerIOS_CineRTCHelper_h
#define cineioPeerIOS_CineRTCHelper_h

#import <Foundation/Foundation.h>

@interface CineRTCHelper : NSObject

+ (NSString*)preferISAC:(NSString*)origSDP;

@end

#endif
