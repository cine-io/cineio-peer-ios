//
//  Identity.m
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Identity.h"

@interface Identity ()

@property (nonatomic, strong) NSString* identity;
@property (nonatomic, strong) NSString* signature;
@property long timestamp;

@end


@implementation Identity

//@synthesize identity;
//@synthesize signature;
//@synthesize timestamp;

- (NSString *)getIdentity;
{
    return self.identity;
}

- (NSString *)getSignature
{
    return self.signature;
}

- (long) getTimestamp
{
    return self.timestamp;
}



@end
