//
//  APMSessionManager.h
//  Airplane Mode
//
//  Created by Matt Rubin on 1/22/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

@import Foundation;


@interface APMSessionManager : NSObject

+ (instancetype)sharedManager;

- (void)start;

@end
