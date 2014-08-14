//
//  TipDetailViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 20/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "TipDetailViewController.h"
#import <RestKit.h>
#import "TipDetail.h"

@interface TipDetailViewController ()

@end

@implementation TipDetailViewController

@synthesize leagueType;
@synthesize homeVsAwayTeams;
@synthesize tipId;
@synthesize leagueTypeLabel;
@synthesize matchLabel;
@synthesize detailMessageLabel;
@synthesize predictionNameLabel;

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
    
    UIColor *oil = [[UIColor alloc] initWithRed:112.0/255.0 green:109.0/255.0 blue:42.0/255.0 alpha:1];
    [self.navigationController.navigationBar setBarTintColor:oil];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];

    leagueTypeLabel.text = leagueType;
    matchLabel.text = homeVsAwayTeams;
    
    [self loadTipDetail];
    
}

- (void) loadTipDetail
{
    RKObjectMapping *tipDetailMapping = [RKObjectMapping mappingForClass:[TipDetail class]];
    
    
    
    [tipDetailMapping addAttributeMappingsFromArray:@[@"id", @"name",
                                                 @"message"]];
    
    RKResponseDescriptor *tipFetchingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tipDetailMapping method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [[RKObjectManager sharedManager] addResponseDescriptor:tipFetchingDescriptor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *authToken = [defaults objectForKey:KEY_USER_AUTH_TOKEN];
    
    NSString *basicAuthString = [NSString stringWithFormat:@"Basic %@",authToken];
    
    NSString *tipDetailPath = [NSString stringWithFormat:@"api/user/%@/prediction/%@/", [defaults objectForKey:KEY_USER_ID], tipId];
    
    //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_AUTHORIZATON value:basicAuthString];
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
    //[[[RKObjectManager sharedManager] HTTPClient] setAuthorizationHeaderWithUsername:email password:pass];
    
    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    [[RKObjectManager sharedManager] getObjectsAtPath:tipDetailPath parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  TipDetail *tipDetail = [mappingResult.array objectAtIndex:0];
                                                  detailMessageLabel.text = tipDetail.message;
                                                  predictionNameLabel.text = tipDetail.name;
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  //Tip is paid please buy it and go back
                                                  int statusCode = operation.HTTPRequestOperation.response.statusCode;
                                                  
                                                  if (statusCode == 401) {
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please Purchase this Tip" delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil, nil];
                                                      [alert show];
                                                      
                                                  }
                                              }];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}



@end
