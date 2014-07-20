//
//  TipDetailViewController.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 20/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipDetailViewController : UIViewController<UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *leagueTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *matchLabel;
@property (strong, nonatomic) IBOutlet UITextView *detailMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *predictionNameLabel;
@property (nonatomic, strong) NSString *leagueType;
@property (nonatomic, strong) NSString *homeVsAwayTeams;
@property (nonatomic, weak) NSNumber *tipId;

@end
