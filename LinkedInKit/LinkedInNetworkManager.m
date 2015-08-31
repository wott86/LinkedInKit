//
//  LinkedInNetworkManager.m
//  LifeKee
//
//  Created by César Vilera on 2/26/15.
//  Copyright (c) 2015 18Feats. All rights reserved.
//

#import "LinkedInNetworkManager.h"

@implementation LinkedInNetworkManager
- (instancetype)sharedInstance {
    static LinkedInNetworkManager *_sharedInstance = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        NSURL *URL = [NSURL URLWithString:@"https://api.linkedin.com/"];
        // Network activity indicator manager setup
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        // Initialize the session
        _sharedInstance = [[LinkedInNetworkManager alloc] initWithBaseURL:URL];
        [_sharedInstance setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [_sharedInstance setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [_sharedInstance.requestSerializer setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    });
    return _sharedInstance;
}

- (id)init
{
    return [self sharedInstance];
}

- (id)new
{
    return [self sharedInstance];
}
@end
