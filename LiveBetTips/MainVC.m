//
//  MainVC.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 18/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *) segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath
{
    NSString *identifier;
    switch (indexPath.row) {
        case 0:
            //Logo
            identifier = @"loginSegue";

            break;
        case 1:
            //My Tips
            identifier = @"loginSegue";

            break;
        case 2:
            //Contact Us
            identifier = @"contactUsSegue";

            break;
        case 3:
            //Info
            identifier = @"loginSegue";

            break;
        case 4:
            //Login
            identifier = @"loginSegue";
            break;
        case 5:
            //Register
            identifier = @"registerSegue";
            break;
        case 6:
            //Buy Tips
            identifier = @"loginSegue";

            break;
        case 7:
            //Settings
            identifier = @"loginSegue";

            break;
    }
    
    return identifier;
}


@end
