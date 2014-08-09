//
//  User.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 05/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSNumber* id;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* authToken;
@property (nonatomic, strong) NSNumber* usercredit;

@end
