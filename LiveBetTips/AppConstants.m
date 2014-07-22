//
//  AppConstants.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 07/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "AppConstants.h"

@implementation AppConstants

NSString* const BASE_URL = @"http://178.21.172.107/";
NSString* const KEY_USER_NAME = @"username";
NSString* const KEY_USER_ID = @"id";
NSString* const KEY_USER_AUTH_TOKEN = @"authToken";
NSString* const KEY_EMAIL = @"email";
NSString* const KEY_PASSWORD = @"password";
NSString* const KEY_APNS_TOKEN = @"APNS TOKEN";

NSString* const HEADER_AUTHORIZATON = @"Authorization";
NSString* const HEADER_CONTENT_TYPE = @"Content-Type";

NSString* const PATH_LOGIN = @"api/user/login/";
NSString* const PATH_USER_CREATE = @"api/user/";
NSString* const PATH_GET_PREDICTIONS = @"api/predictions/";

@end
