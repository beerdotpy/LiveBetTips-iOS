//
//  Filter.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 24/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filter : NSObject

@property (nonatomic, strong) NSString *units;
@property (nonatomic, strong) NSArray *predictionName;
@property (nonatomic, strong) NSArray *leagueType;

@end
