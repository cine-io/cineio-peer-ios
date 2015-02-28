//
//  Call.m
//  PeerExampleObjC
//
//  Created by Thomas Shafer on 2/28/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Call.h"
#import "SignalingConnection.h"

@interface Call ()

@property (nonatomic, strong) NSString* roomName;
@property (nonatomic, strong) SignalingConnection* signalingConnection;
@property BOOL initiated;

@end


@implementation Call

- (id)initWithRoom:(NSString *)roomName signalingConnection:(SignalingConnection *)signalingConnection initiated:(BOOL)initiated
{
    if (self = [super init]) {
        self.roomName = roomName;
        self.signalingConnection = signalingConnection;
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

}
- (void)rejected:(NSString *)identity
{
    NSLog(@"rejected");
}


@end
