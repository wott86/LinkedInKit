//
//  LinkedInNetworkManager.h
//  LifeKee
//
//  Created by César Vilera on 2/26/15.
//  Copyright (c) 2015 18Feats. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface LinkedInNetworkManager : AFHTTPRequestOperationManager
- (instancetype)sharedInstance;
@end
