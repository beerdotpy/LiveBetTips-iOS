//
//  Tip.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 13/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tip : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *leagueType;
@property (nonatomic, strong) NSString *flagURL;
@property (nonatomic, strong) NSString *homeTeam;
@property (nonatomic, strong) NSString *awayTeam;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic, strong) NSNumber *tipDetail;
@property (nonatomic, strong) NSString *DateTimeCreated;
@property (nonatomic, strong) NSString *isPredictionVerified;

@end
