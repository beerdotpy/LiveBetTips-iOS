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
    [self loginUser];
    [indicator stopAnimating];
}

- (void) configureRestKit
{
    
    NSURL *baseURL = [NSURL URLWithString:DOMAIN_NAME];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    //initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    //setup object mappings
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[User class]];
    [userMapping addAttributeMappingsFromArray:@[@"id",@"username", @"authToken"]];
    
    RKResponseDescriptor *loginResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:@"api/user/login/" keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [objectManager addResponseDescriptor:loginResponseDescriptor];
    
}

- (void) loginUser
{
    
    NSDictionary *loginRequestData = @{@"email":@"sarthakmeh03@gmail.com",
                                       @"password":@"sarthak",
                                       };
    NSString *jsonRequestData = [loginRequestData bv_jsonStringWithPrettyPrint:true];
    NSLog(@"Json Data = %@", jsonRequestData);
    
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:@"Content-Type" value:@"application/json"];
    
    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    
    [[RKObjectManager sharedManager] postObject:jsonRequestData path:@"api/user/login/"
                                     parameters: loginRequestData
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            
                                            _users = mappingResult.array ;
                                            User *loggedInUser = [_users objectAtIndex:0];
                                            NSLog(@"id = %@, username = %@, authToken = %@", loggedInUser.id,
                                                  loggedInUser.username, loggedInUser.authToken );
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            NSLog(@"Request Failed");
                                        }
     ];
    
}





@end
