//
//  LoginViewController.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 04/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface LoginViewController : UIViewController

@property NSArray *users;
@property (strong, nonatomic) IBOutlet UITextField *tf_email;
@property (strong, nonatomic) IBOutlet UITextField *tf_password;
@property (weak, nonatomic) IBOutlet UIButton *bt_signUp;
@property (weak, nonatomic) IBOutlet UIButton *bt_forgotPassword;
@property (weak, nonatomic) IBOutlet UIButton *bt_login;

@end
