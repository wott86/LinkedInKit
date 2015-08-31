//
//  LinkedInKit.h
//  LinkedInKit
//
//  Created by César Vilera on 2/25/15.
//  Copyright (c) 2015 18Feats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LinkedInNetworkManager.h"
#import "LinkedInOAuthNetworkManager.h"

@interface LinkedInKit : NSObject
typedef void(^LinkedInLoginBlock)(NSString *code,NSString *state,NSError* error);
typedef void(^LinkedInSuccessBlock)(id response);
typedef void(^LinkedInFailureBlock)(NSError* error);

typedef enum
{
    kLinkedInKitErrorCodeNone,
    kLinkedInKitErrorCodeAccessNotGranted,
    kLinkedInKitErrorCodeUserCancelled = NSUserCancelledError,
    
} LinkedInKitErrorCode;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *expiresIn;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, strong) NSString *code;
+ (LinkedInKit *)sharedLinkedInKit;
- (void)loginWithBlock:(LinkedInLoginBlock)linkedInLoginBlock;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;


-(void)postRequestAccessToken:(NSDictionary *)parameters success:(LinkedInSuccessBlock)success failure:(LinkedInFailureBlock)failure;
-(void)getMyProfile:(NSDictionary *)parameters success:(LinkedInSuccessBlock)success failure:(LinkedInFailureBlock)failure;
@end
