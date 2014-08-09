//
//  MyTipsTableViewController.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 22/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterViewController.h"

@interface MyTipsTableViewController : UITableViewController<FilterViewControllerDelegate>

@property NSArray *tips;

@property (strong, nonatomic) IBOutlet UILabel *creditsLabel;

@property (nonatomic, weak) id <FilterViewControllerDelegate> delegate;


@end
