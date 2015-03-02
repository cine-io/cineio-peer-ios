//
//  Identity.m
//  cineio-peer-ios
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

- (id) initWithName:(NSString *)identityName timestamp:(long)timestamp signature:(NSString *)signature;
{
    if (self = [super init]) {
        self.identity = identityName;
        self.timestamp = timestamp;
        self.signature = signature;
    }
    return self;
}

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
