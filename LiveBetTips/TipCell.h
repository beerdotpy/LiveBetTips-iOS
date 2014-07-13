//
//  TipCell.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 13/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *leagueNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *homeTeamLabel;
@property (strong, nonatomic) IBOutlet UILabel *awayTeamLabel;
@property (strong, nonatomic) IBOutlet UILabel *isVerifiedLabel;

@end
