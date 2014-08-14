//
//  MyTipsTableViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 22/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "MyTipsTableViewController.h"
#import <RestKit.h>
#import "Tip.h"
#import "TipCell.h"
#import "TipDetailViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface MyTipsTableViewController ()

@end

@implementation MyTipsTableViewController

int rowNumber;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *oil = [[UIColor alloc] initWithRed:112.0/255.0 green:109.0/255.0 blue:42.0/255.0 alpha:1];
    [self.navigationController.navigationBar setBarTintColor:oil];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"usercredit"] == NULL) {
        _creditsLabel.text = [[NSString alloc] initWithFormat:@"Credits : %@", @"0"];
    } else {
        _creditsLabel.text = [[NSString alloc] initWithFormat:@"Credits : %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"usercredit"]];
    }
    
    
    
    [self loadTips];

}
- (IBAction)filterButtonClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"filterSegue" sender:sender];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _tips.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TipCell" forIndexPath:indexPath];
    Tip *tip = _tips[indexPath.row];
    cell.leagueNameLabel.text = tip.leagueType;
    cell.homeTeamLabel.text = tip.homeTeam;
    cell.awayTeamLabel.text = tip.awayTeam;
    cell.isVerifiedLabel.text = tip.isPredictionVerified;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?:2|1)\\d{3}(?:-|\\/)(?:(?:0[1-9])|(?:1[0-2]))(?:-|\\/)(?:(?:0[1-9])|(?:[1-2][0-9])|(?:3[0-1]))(?:T|\\s)(?:(?:[0-1][0-9])|(?:2[0-3])):(?:[0-5][0-9]):(?:[0-5][0-9]))" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:tip.DateTimeCreated options:0 range:NSMakeRange(0, [tip.DateTimeCreated length])];
    cell.dateLabel.text = [tip.DateTimeCreated substringWithRange:[match rangeAtIndex:1]];
    // Configure the cell...
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"%ld Sender Id = ", (long)[sender tag]);
    
    if ([sender tag] == 1001) {
        
        FilterViewController *fvc = (FilterViewController *)segue.destinationViewController;
        [fvc setDelegate:self];
        
    } else {
        Tip *tip = _tips[rowNumber];
        TipDetailViewController* destinationViewController = segue.destinationViewController;
        destinationViewController.leagueType = tip.leagueType;
        destinationViewController.homeVsAwayTeams = [NSString stringWithFormat:@"%@ vs %@", tip.homeTeam, tip.awayTeam];
        destinationViewController.tipId = tip.id;
    }
    

    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    rowNumber = indexPath.row;
    [self performSegueWithIdentifier:@"predictionDetailSegue" sender:nil];
}


- (void) loadTips
{
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.labelText = @"Loading...";
    [HUD show:YES];
    
    RKObjectMapping *tipsMapping = [RKObjectMapping mappingForClass:[Tip class]];
    
    
    
    [tipsMapping addAttributeMappingsFromArray:@[@"id", @"leagueType",
                                                 @"flagURL", @"homeTeam", @"awayTeam", @"isCompleted",
                                                 @"tipDetail", @"DateTimeCreated",
                                                 @"isPredictionVerified"]];
    
    RKResponseDescriptor *tipFetchingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tipsMapping method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [[RKObjectManager sharedManager] addResponseDescriptor:tipFetchingDescriptor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *authToken = [defaults objectForKey:KEY_USER_AUTH_TOKEN];
    NSString *email = [defaults objectForKey:KEY_USER_NAME];
    NSLog(@"%@", email);
    NSString *basicAuthString = [NSString stringWithFormat:@"Basic %@",authToken];
    
    NSDictionary *params = @{@"isPushed":@"True"};
    
    NSString *mytipsPath = [NSString stringWithFormat:@"api/user/%@/predictions/", [defaults objectForKey:KEY_USER_ID]];

    
    //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_AUTHORIZATON value:basicAuthString];
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
    //[[[RKObjectManager sharedManager] HTTPClient] setAuthorizationHeaderWithUsername:email password:pass];
    
    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    [[RKObjectManager sharedManager] getObjectsAtPath:mytipsPath parameters:params
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  _tips = [[mappingResult.array reverseObjectEnumerator] allObjects];
                                                  [self.tableView reloadData];
                                                  [HUD hide:YES];
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"WTF");
                                                  [HUD hide:YES];
                                              }];
    
    [[RKObjectManager sharedManager] removeResponseDescriptor:tipFetchingDescriptor];
}


-(void)filterViewController:(FilterViewController *)filterViewController choosenLeagueName:(NSString *)leageName choosenPredictionName:(NSString *)predictionName {
    
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.labelText = @"Loading...";
    [HUD show:YES];
    NSString *path = [[NSString alloc] initWithFormat:@"api/predictions/filter/?predictionName=%@&league=%@", predictionName, leageName];
    
    NSString *urlString = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    RKObjectMapping *tipsMapping = [RKObjectMapping mappingForClass:[Tip class]];
    
    
    
    [tipsMapping addAttributeMappingsFromArray:@[@"id", @"leagueType",
                                                 @"flagURL", @"homeTeam", @"awayTeam", @"isCompleted",
                                                 @"tipDetail", @"DateTimeCreated",
                                                 @"isPredictionVerified"]];
    
    RKResponseDescriptor *tipFetchingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tipsMapping method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [[RKObjectManager sharedManager] addResponseDescriptor:tipFetchingDescriptor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *authToken = [defaults objectForKey:KEY_USER_AUTH_TOKEN];
    NSString *email = [defaults objectForKey:KEY_USER_NAME];
    NSLog(@"%@", email);
    //NSString *basicAuthString = [NSString stringWithFormat:@"Basic %@",authToken];
    
    //NSDictionary *params = @{@"isPushed":@"True"};
    
    
    //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
    //[[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_AUTHORIZATON value:basicAuthString];
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
    //[[[RKObjectManager sharedManager] HTTPClient] setAuthorizationHeaderWithUsername:email password:pass];
    
    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    [[RKObjectManager sharedManager] getObjectsAtPath:urlString parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  _tips = [[mappingResult.array reverseObjectEnumerator] allObjects];
                                                  [self.tableView reloadData];
                                                  [HUD hide:YES];
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"WTF");
                                                  [HUD hide:YES];
                                              }];
    
    [[RKObjectManager sharedManager] removeResponseDescriptor:tipFetchingDescriptor];
    
    [self.navigationController popViewControllerAnimated:YES];

}

@end
