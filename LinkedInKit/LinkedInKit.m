//
//  LinkedInKit.m
//  LinkedInKit
//
//  Created by César Vilera on 2/25/15.
//  Copyright (c) 2015 18Feats. All rights reserved.
//

#import "LinkedInKit.h"

@interface LinkedInKit()
@property (nonatomic, copy) LinkedInLoginBlock linkedInLoginBlock;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectURI;
@property (nonatomic, strong) NSString *redirectURL;
@property (nonatomic, strong) NSString *authorizationURL;
@property (nonatomic, strong) LinkedInNetworkManager *network;
@property (nonatomic, strong) LinkedInOAuthNetworkManager *oauthNetwork;
@end

@implementation LinkedInKit
NSString *const kLinkedInKitErrorDomain = @"LinkedInKitErrorDomain";
+ (LinkedInKit *)sharedLinkedInKit {
    static LinkedInKit *_sharedKit = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedKit = [[LinkedInKit alloc] init];
    });
    return _sharedKit;
}

+ (NSDictionary*) sharedConfiguration {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"LinkedInKit" withExtension:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:url];
    dict = dict ? dict : [[NSBundle mainBundle] infoDictionary];
    return dict;
}

- (id)init {
    if (self = [super init])
    {
        NSDictionary *configuration = [LinkedInKit sharedConfiguration];
        _clientID = configuration[@"clientID"];
        _clientSecret = configuration[@"clientSecret"];
        _redirectURL = configuration[@"redirectURL"];
        _redirectURI = configuration[@"redirectURI"];
        _authorizationURL = @"https://www.linkedin.com/uas/oauth2/authorization";
        _network = [[LinkedInNetworkManager alloc] sharedInstance];
        _oauthNetwork = [[LinkedInOAuthNetworkManager alloc] sharedInstance];
    }
    return self;
}

- (void)loginWithBlock:(LinkedInLoginBlock)linkedInLoginBlock {
    if (!_accessToken) {
        if (!_state) {
            [NSException raise:@"Invalid state" format:@"Invalid state"];
        }
        _linkedInLoginBlock = linkedInLoginBlock;
        NSString *path = [NSString stringWithFormat:@"%@?response_type=code&client_id=%@&redirect_uri=%@&state=%@",_authorizationURL,_clientID,_redirectURL,_state];
        if (_scope) [path stringByAppendingString:[NSString stringWithFormat:@"&scope=%@",_scope]];
        NSURL *url = [NSURL URLWithString:path];
        [[UIApplication sharedApplication] openURL:url];
    }else {
        linkedInLoginBlock(nil,nil,nil);
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSURL *appRedirectURL = [NSURL URLWithString:_redirectURI];
    
    if (![appRedirectURL.scheme isEqual:url.scheme] || ![appRedirectURL.host isEqual:url.host])
    {
        return NO;
    }
    
    NSDictionary *queryComponents = [self queryComponents:[url query]];
    NSString *code = [queryComponents objectForKey:@"code"];
    NSString *state = [queryComponents objectForKey:@"state"];
    if (code)
    {
        self.code = code;
        self.state = state;
        if (_linkedInLoginBlock) _linkedInLoginBlock(_code,_state,nil);
    }
    else if (_linkedInLoginBlock)
    {
        NSString *localizedDescription = NSLocalizedString(@"Authorization not granted.", @"Error notification to indicate LinkedIn OAuth token was not provided.");
        NSError *error = [NSError errorWithDomain:kLinkedInKitErrorDomain code:kLinkedInKitErrorCodeAccessNotGranted userInfo:@{ NSLocalizedDescriptionKey:localizedDescription }];
        _linkedInLoginBlock(nil,nil,error);
    }
    _linkedInLoginBlock = nil;
    return YES;
}

-(NSDictionary *)queryComponents:(NSString *)query {
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *component in components) {
        NSArray *subcomponents = [component componentsSeparatedByString:@"="];
        [parameters setObject:[[subcomponents objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                       forKey:[[subcomponents objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return parameters;
}

-(void)postRequestAccessToken:(NSDictionary *)parameters success:(LinkedInSuccessBlock)success failure:(LinkedInFailureBlock)failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [params setObject:_redirectURL forKey:@"redirect_uri"];
    [params setObject:_clientID forKey:@"client_id"];
    [params setObject:_clientSecret forKey:@"client_secret"];
    [_oauthNetwork POST:@"/uas/oauth2/accessToken" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _accessToken = [responseObject objectForKey:@"access_token"];
        _expiresIn = [responseObject objectForKey:@"expires_in"];
        _code = nil;
        _state = nil;
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(error);
    }];
}

-(void)getMyProfile:(NSDictionary *)parameters success:(LinkedInSuccessBlock)success failure:(LinkedInFailureBlock)failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [params setObject:_accessToken forKey:@"oauth2_access_token"];
    [_network GET:@"/v1/people/~" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}




@end
