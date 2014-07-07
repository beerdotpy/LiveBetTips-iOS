//
//  LoginViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 04/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "LoginViewController.h"
#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import "User.h"
#import <Toast+UIView.h>

@interface LoginViewController ()

@end

@interface NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@implementation NSDictionary (BVJSONString)

-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@implementation LoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureRestKit];
    //[self loginUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpButtonClicked:(id)sender {
    
    NSLog(@"Sign Up Clicked on Login Screen");
    //Open Registration Screen
    [self performSegueWithIdentifier:@"loginToSignUpSegue" sender:sender];
}


- (IBAction)loginButtonClicked:(id)sender {
    
    //Start Displaying Progress Dialog
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [indicator startAnimating];
    [self loginUser:sender];
    [indicator stopAnimating];
}

- (void) configureRestKit
{
    
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    //initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    //setup object mappings
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[User class]];
    [userMapping addAttributeMappingsFromArray:@[KEY_USER_ID,KEY_USER_NAME, KEY_USER_AUTH_TOKEN]];
    
    RKResponseDescriptor *loginResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:@"api/user/login/" keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [objectManager addResponseDescriptor:loginResponseDescriptor];
    
}

- (void) loginUser:(id)sender
{
    
    NSString *email = self.tf_email.text;
    NSString *password = self.tf_password.text;
    NSDictionary *loginRequestData;
    
    NSLog(@"Email = %@ & Password = %@", email, password);
    if (![email length]>0) {
        //Check if EMail Field is Blank
        //Show Alert Dialog
        UIAlertView *uiAlertView = [[UIAlertView alloc] initWithTitle:@"Bummer !"
                                                        message:@"Email Cannot be blank"
                                                        delegate:nil
                                                        cancelButtonTitle:@"Got it!"
                                                        otherButtonTitles:nil, nil];
        [uiAlertView show];
    } else if (![password length] > 0) {
        //Check if Password Field is Blank
        //Show Alert Dialog
        UIAlertView *uiAlertView = [[UIAlertView alloc] initWithTitle:@"Bummer !" message:@"Password Cannot be blank" delegate:nil cancelButtonTitle:@"Got it!" otherButtonTitles:nil, nil];
        [uiAlertView show];
        
    } else {
        //Construct Dictionary Here
        loginRequestData = @{KEY_EMAIL:email,
                             KEY_PASSWORD:password,};
        
        //Convert Dictionary into JSON String
        NSString *jsonRequestData = [loginRequestData bv_jsonStringWithPrettyPrint:true];
        NSLog(@"Json Data = %@", jsonRequestData);
        
        //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
        [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
        
        NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
        
        [[RKObjectManager sharedManager] postObject:jsonRequestData path:@"api/user/login/"
                                         parameters: loginRequestData
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                
                                                _users = mappingResult.array ;
                                                User *loggedInUser = [_users objectAtIndex:0];
                                                NSLog(@"id = %@, username = %@, authToken = %@", loggedInUser.id,
                                                      loggedInUser.username, loggedInUser.authToken );
                                                [self preserveUser:loggedInUser];
                                                [self notifyUserWithLogin:@"Logged In Successfully"];
                                                [self performSegueWithIdentifier:@"loginToTipsSegue" sender:sender];
                                                
                                            }
                                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                [self notifyUserWithLogin:@"Email/Password Invalid, Please Try Again"];
                                            }
         ];
    }
    

    
}
- (IBAction)forgotPasswordClicked:(id)sender {
    NSLog(@"I forgot");
}

- (void) notifyUserWithLogin: (NSString *)response
{
    [self.view makeToast:response
     duration:2.0 position:@"center"];
}


// Save Userdata in NSUserDefaults
- (void) preserveUser:(User *) user
{
    //Prepare Data
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:user.id forKey:KEY_USER_ID];
    [defaults setObject:user.username forKey:KEY_USER_NAME];
    [defaults setObject:user.authToken forKey:KEY_USER_AUTH_TOKEN];
    
    [defaults synchronize];
    
    NSLog(@"Data Saved Successfully");
    
}


@end
