//
//  SignupViewController.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 04/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController

@property NSArray *users;


@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

@end
//But my dad said he will get me insured separately from a Govt. 