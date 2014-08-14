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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *identifier;
    switch (indexPath.row) {
        case 0:
            //Logo
            
            identifier = @"loginSegue";

            break;
        case 1:
            //My Tips
            NSLog(@"HERE NOW");
            if ([[defaults objectForKey:@"loggedIn"] isEqualToString:@"YES"]) {
                identifier = @"mytipsSegue";
            } else {
                identifier = @"loginSegue";
            }
            break;
        case 2:
            //Tips
            identifier = @"tipsSegue";

            break;
        case 3:
            //Contact Us
            identifier = @"contactUsSegue";

            break;
        case 4:
            //Info
            identifier = @"infoSegue";
            break;
        case 5:
            //Login
            identifier = @"loginSegue";
            break;
        case 6:
            //Register
            identifier = @"registerSegue";

            break;
        case 7:
            //Buy Tips
            if ([[defaults objectForKey:@"loggedIn"] isEqualToString:@"YES"]) {
                identifier = @"buyTipsSegue";
            } else {
                identifier = @"loginSegue";
            }
            break;
    }
    
    return identifier;
}

-(void)configureLeftMenuButton:(UIButton *)button
{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){40,40};
    button.frame = frame;
    
    [button setImage:[UIImage imageNamed:@"slideMenuIcon"] forState:UIControlStateNormal];
}



@end
