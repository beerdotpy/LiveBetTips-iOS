//
//  FilterViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 23/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "FilterViewController.h"
#import <RestKit/RestKit.h>
#import "Filter.h"
@interface FilterViewController ()

@property RKObjectManager *objectManager;
@property RKResponseDescriptor *loginResponseDescriptor;

@end

@implementation FilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction)handleUpdateButton:(id)sender
{
    id<FilterViewControllerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(filterViewController:choosenLeagueName:choosenPredictionName:)]) {
        [strongDelegate filterViewController:self choosenLeagueName:@"" choosenPredictionName:@""];
    }
}

-(void)setupFilterOptions{
    

    [[RKObjectManager sharedManager] getObjectsAtPath:@"api/filter/" parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  _leagueTypes = [[mappingResult.array objectAtIndex:0] leagueType];
                                                  _predictionNames = [[mappingResult.array objectAtIndex:0] predictionName];
                                                  
                                                  
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"WTF");
                                              }];
    
    
    
}

- (void) configureRestKit
{
    
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    //initialize RestKit
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    //setup object mappings
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[Filter class]];
    [userMapping addAttributeMappingsFromArray:@[@"predictionName",@"leagueType"]];
    
    _loginResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [_objectManager addResponseDescriptor:_loginResponseDescriptor];
    
}



@end
