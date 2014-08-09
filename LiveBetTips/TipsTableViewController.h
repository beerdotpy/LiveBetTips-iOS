//
//  TipsTableViewController.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 07/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterViewController.h"

@interface TipsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FilterViewControllerDelegate>

@property NSArray *tips;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id <FilterViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *creditsLabel;
@property (strong, nonatomic) IBOutlet UILabel *unitsLabel;

@end
