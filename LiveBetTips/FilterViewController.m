//
//  FilterViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 23/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#define kPREDICTIONNAMEPICKERTAG 20
#define kLEAGUENAMEPICKERTAG 21

#import "FilterViewController.h"
#import <RestKit/RestKit.h>
#import "Filter.h"
#import "FilterPredictionName.h"
#import "FilterLeagueType.h"

@interface FilterViewController ()

@property RKObjectManager *objectManager;
@property RKResponseDescriptor *loginResponseDescriptor;
@property NSString *predictionName;
@property NSString *leagueName;


@end

@implementation FilterViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *oil = [[UIColor alloc] initWithRed:112.0/255.0 green:109.0/255.0 blue:42.0/255.0 alpha:1];
    [self.navigationController.navigationBar setBarTintColor:oil];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    [self configureRestKit];
    [self setupFilterOptions];
}

-(IBAction)handleUpdateButton:(id)sender
{
//    if ([strongDelegate respondsToSelector:@selector(filterViewController:choosenLeagueName:choosenPredictionName:)]) {
//        [strongDelegate filterViewController:self choosenLeagueName:@"" choosenPredictionName:@""];
//    }
    
    NSLog(@"%@ , %@", _leagueName, _predictionName);
    
    [delegate filterViewController:self choosenLeagueName:_leagueName choosenPredictionName:_predictionName];
}

-(void)setupFilterOptions{
    
    
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);


    [_objectManager getObjectsAtPath:@"api/filter/" parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSLog(@"Count = %ld", [_leagueTypes count]);
                                                  _leagueTypes = [[mappingResult.array objectAtIndex:0] leagueType];
                                                  _predictionNames = [[mappingResult.array objectAtIndex:0] predictionName];
                                                  
                                                  predictionNamePicker.delegate = self;
                                                  
                                                  predictionNamePicker.tag = 20;
                                                  predictionNamePicker.showsSelectionIndicator = TRUE;
 
                                                  
                                                  [predictionNamePicker reloadAllComponents];
                                                  
                                                  leagueNamePicker.delegate = self;
                                                  leagueNamePicker.tag = 21;
                                                  leagueNamePicker.showsSelectionIndicator = TRUE;
                                                  
                                                  [leagueNamePicker reloadAllComponents];
                                                  
                                                  
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
    
    RKObjectMapping *pnMappting = [RKObjectMapping mappingForClass:[Filter class]];
    [pnMappting addAttributeMappingsFromArray:@[@"predictionName", @"leagueType",@"units"]];
    
    _loginResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:pnMappting method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [_objectManager addResponseDescriptor:_loginResponseDescriptor];
    
}

#pragma mark -
#pragma mark picker methods


- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
    
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView == predictionNamePicker) {
        return [_predictionNames count];
    } else {
        return [_leagueTypes count];
    }
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerView == predictionNamePicker) {
        return [_predictionNames objectAtIndex:row];
    } else {
        return [_leagueTypes objectAtIndex:row];
    }
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView == predictionNamePicker) {
       _predictionName = [_predictionNames objectAtIndex:[pickerView selectedRowInComponent:0]];
    } else {
       _leagueName = [_leagueTypes objectAtIndex:[pickerView selectedRowInComponent:0]];
    }
    
}


@end
