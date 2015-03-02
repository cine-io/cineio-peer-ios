//
//  CinePeerClientConfig.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CinePeerClientConfig.h"
#import "CineIdentity.h"
#import "CineDigestHelper.h"

@interface CinePeerClientConfig ()

@property (nonatomic, strong) NSString* publicKey;
@property (nonatomic, strong) NSString* secretKey;

@end


@implementation CinePeerClientConfig

@synthesize delegate;
@synthesize secretKey;

- (id) initWithPublicKey:(NSString *)publicKey delegate:(id<CinePeerClientDelegate>)theDelegate;
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.publicKey = publicKey;
    }
    return self;
}


- (NSString *)getPublicKey;
{
    return self.publicKey;
}

- (NSString *)getSecretKey
{
    return self.secretKey;
}

- (id)getDelegate
{
    return self.delegate;
}
- (CineIdentity *) generateIdentity:(NSString *)identityName
{
    long timestamp = CFAbsoluteTimeGetCurrent();

    NSMutableString *signatureToSha = [[NSMutableString alloc] init];
    //    "identity="+identityName+"&timestamp="+timestamp+secretKey
    [signatureToSha appendString:@"identity="];
    [signatureToSha appendString:identityName];
    [signatureToSha appendString:@"&timestamp="];
    [signatureToSha appendFormat:@"%ld",timestamp];
    [signatureToSha appendString:secretKey];

    NSString *signature = [CineDigestHelper sha1:signatureToSha];

    CineIdentity *identity = [[CineIdentity alloc] initWithName:identityName timestamp:timestamp signature:signature];
    return identity;
}


@end
