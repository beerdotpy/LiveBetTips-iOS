//
//  ForgotPasswordViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 23/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import <Toast+UIView.h>

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *oil = [[UIColor alloc] initWithRed:112.0/255.0 green:109.0/255.0 blue:42.0/255.0 alpha:1];
    [self.navigationController.navigationBar setBarTintColor:oil];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

}

- (IBAction)resetbuttonclicked:(id)sender {
    
    NSString *email = self.emailTextField.text;
    
    if ([email length]>0) {
        NSDictionary *resetRequestData;

        //Construct Dictionary Here
        resetRequestData = @{KEY_EMAIL:email};

        //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
        [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
        
        NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
        
        //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
        [[RKObjectManager sharedManager] postObject: nil path:@"api/user/resetpassword/"
                                         parameters: resetRequestData
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                
                                                [self notifyUserWithLogin:@"Mail Sent"];
                                                
                                            }
                                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                [self notifyUserWithLogin:@"There was a problem"];
                                            }
         ];
        
        
    }else {
        UIAlertView *uiAlertView = [[UIAlertView alloc] initWithTitle:@"Bummer !"
                                                              message:@"Email Cannot be blank"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Got it!"
                                                    otherButtonTitles:nil, nil];
        [uiAlertView show];
    }
    
}

- (void) notifyUserWithLogin: (NSString *)response
{
    [self.view makeToast:response
                duration:2.0 position:@"center"];
}

@end
