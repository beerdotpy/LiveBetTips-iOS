//
//  TipsTableViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 07/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "TipsTableViewController.h"
#import <RestKit.h>
#import "Tip.h"
#import "TipCell.h"
#import "TipDetailViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Filter.h"
@interface TipsTableViewController ()

@property RKObjectManager *objectManager;
@property RKResponseDescriptor *loginResponseDescriptor;

@end

@implementation TipsTableViewController

int rowNumber;


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
    [self configureRestKitForUnits];
    [self fetchUnits];
    [self loadTips];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [cell.leagueNameLabel sizeToFit];
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
    
    if ([sender tag] == 1005) {
        
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
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"loggedIn"] isEqualToString:@"YES"]) {
        UIAlertView *uiAlertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Login is Required to view this tip" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [uiAlertView show];
        return;
    }
    
    rowNumber = indexPath.row;
    Tip *tip = _tips[rowNumber];
    if (tip.isCompleted) {
        [self performSegueWithIdentifier:@"predictionDetailSegue" sender:nil];
    } else {
    NSNumber* userid = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USER_ID];
    
    NSString* path = [[NSString alloc] initWithFormat:@"api/user/%@/prediction/%@/", userid, tip.id];
    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self performSegueWithIdentifier:@"predictionDetailSegue" sender:nil];
        
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        UIAlertView *uiAlertView = [[UIAlertView alloc] initWithTitle:@"Purchase Tip?" message:@"This is a paid tip. Want to buy?" delegate:self cancelButtonTitle:@"Buy Now!" otherButtonTitles:@"No Thanks!", nil];
        [uiAlertView show];
        
    }];
    
    
    }
    
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        Tip *tip = _tips[rowNumber];
        
        NSDictionary *requestData = @{@"userID": [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USER_ID],
                                      @"predictionID": tip.id};
        
        [[[RKObjectManager sharedManager] HTTPClient] postPath:@"api/user/prediction/buy/" parameters:requestData
                                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                       
                                                           [self performSegueWithIdentifier:@"predictionDetailSegue" sender:nil];
                                                       
                                                       }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       
                                                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                           NSString *identifier;
                                                           if ([[defaults objectForKey:@"loggedIn"] isEqualToString:@"YES"]) {
                                                               identifier = @"buyTipsSegue";
                                                           } else {
                                                               identifier = @"loginSegue";
                                                           }
                                                           
                                                           [self.mainSlideMenu.leftMenu performSegueWithIdentifier:identifier sender:nil];
                                                           
                                                       }];
        
    } else if(buttonIndex == 1) {

        return;
    }
    
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

    
    //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
    if (authToken != NULL || authToken != nil) {
        [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_AUTHORIZATON value:basicAuthString];
    }
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
    //[[[RKObjectManager sharedManager] HTTPClient] setAuthorizationHeaderWithUsername:email password:pass];

    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"api/predictions/" parameters:params
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

- (void) configureRestKitForUnits
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

-(void)fetchUnits{
    
    
    //    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    
    [_objectManager getObjectsAtPath:@"api/filter/" parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 _unitsLabel.text = [[NSString alloc] initWithFormat:@"Units : %@",
                                 [[mappingResult.array objectAtIndex:0] units]];
                                 [_unitsLabel sizeToFit];
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 NSLog(@"WTF");
                             }];
    
    
    
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
   // NSString *basicAuthString = [NSString stringWithFormat:@"Basic %@",authToken];
    
  //  NSDictionary *params = @{@"isPushed":@"True"};
    
    
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
