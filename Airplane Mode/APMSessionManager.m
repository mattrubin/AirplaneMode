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
    NSLog(@"Started...");
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
        NSLog(@"Broswer created.");
    }
    return _browser;
}

- (MCNearbyServiceAdvertiser *)advertiser
{
    if (!_advertiser) {
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:APMServiceType];
        _advertiser.delegate = self;
        NSLog(@"Advertiser created.");
    }
    return _advertiser;
}


#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"Browser found %@", peerID);
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Browser lost %@", peerID);
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Browser Error: %@", error);
}


#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    NSLog(@"Advertiser received invitation!");
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"Advertiser error: %@", error);
}

@end
