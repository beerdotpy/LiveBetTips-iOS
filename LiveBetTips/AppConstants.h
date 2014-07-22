//
//  AppConstants.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 07/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConstants : NSObject

extern NSString* const BASE_URL;
extern NSString* const KEY_USER_NAME;
extern NSString* const KEY_USER_ID;
extern NSString* const KEY_USER_AUTH_TOKEN;
extern NSString* const KEY_EMAIL;
extern NSString* const KEY_PASSWORD;
extern NSString* const KEY_APNS_TOKEN;

extern NSString* const HEADER_AUTHORIZATON;
extern NSString* const HEADER_CONTENT_TYPE;

extern NSString* const PATH_LOGIN;
extern NSString* const PATH_USER_CREATE;
extern NSString* const PATH_GET_PREDICTIONS;
@end
