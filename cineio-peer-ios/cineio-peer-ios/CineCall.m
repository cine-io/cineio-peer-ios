//
//  CineCall.m
//  cineio-peer-ios
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CineCall.h"
#import "CineSignalingConnection.h"
#import "CinePeerClientConfig.h"

@interface CineCall ()

@property (nonatomic, strong) NSString* roomName;
@property (nonatomic, weak) CinePeerClientConfig* config;
@property (nonatomic, weak) CineSignalingConnection* signalingConnection;

@property BOOL initiated;

@end


@implementation CineCall

- (id)initWithRoom:(NSString *)roomName config:(CinePeerClientConfig *)config signalingConnection:(CineSignalingConnection *)signalingConnection initiated:(BOOL)initiated
{
    if (self = [super init]) {
        self.roomName = roomName;
        self.config = config;
        self.initiated = initiated;
    }
    return self;
}
- (void)answer
{
    NSLog(@"Answer");
    [self.signalingConnection joinRoom:self.roomName];
}
- (void)reject
{
    NSLog(@"reject");
    [self.signalingConnection rejectCall:self.roomName];
}
- (void)hangup
{
    NSLog(@"hangup");
    [self.signalingConnection leaveRoom:self.roomName];
}

- (void)cancelled:(NSString *)identity
{
    NSLog(@"cancelled");
    [[self.config getDelegate] onCallCancel:self];

}
- (void)rejected:(NSString *)identity
{
    NSLog(@"rejected");
    [[self.config getDelegate] onCallReject:self];
}


@end
