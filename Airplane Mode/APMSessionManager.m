//
//  APMSessionManager.m
//  Airplane Mode
//
//  Created by Matt Rubin on 1/22/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "APMSessionManager.h"
@import MultipeerConnectivity;


static NSString * const APMServiceType = @"airplane-mode";


@interface APMSessionManager () <MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) MCSession *session;

@end


@implementation APMSessionManager

+ (instancetype)sharedManager
{
    static id _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    return _sharedInstance;
}

- (void)start
{
    [self.browser startBrowsingForPeers];
    [self.advertiser startAdvertisingPeer];
    [self logMessage:@"Started..."];
}

- (void)logMessage:(NSString *)message
{
    NSLog(@"%@", message);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APMSessionManagerNotification"
                                                        object:self
                                                      userInfo:@{@"log": (message ?: @"")}];
}


#pragma mark -

- (MCPeerID *)peerID
{
    if (!_peerID) {
        _peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    }
    return _peerID;
}

- (MCNearbyServiceBrowser *)browser
{
    if (!_browser) {
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:APMServiceType];
        _browser.delegate = self;
        [self logMessage:@"Broswer created."];
    }
    return _browser;
}

- (MCNearbyServiceAdvertiser *)advertiser
{
    if (!_advertiser) {
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:APMServiceType];
        _advertiser.delegate = self;
        [self logMessage:@"Advertiser created."];
    }
    return _advertiser;
}

- (MCSession *)session
{
    if (!_session) {
        _session = [[MCSession alloc] initWithPeer:self.peerID];
    }
    return _session;
}


#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    [self logMessage:[NSString stringWithFormat:@"Found %@", peerID.displayName]];
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:0];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self logMessage:[NSString stringWithFormat:@"Lost %@", peerID.displayName]];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    [self logMessage:[NSString stringWithFormat:@"Browser Error: %@", error]];
}


#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    [self logMessage:[NSString stringWithFormat:@"Received invitation from %@", peerID.displayName]];
    invitationHandler(YES, self.session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    [self logMessage:[NSString stringWithFormat:@"Advertiser error: %@", error]];
}

@end
