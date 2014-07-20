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

@interface TipsTableViewController ()

@end

@implementation TipsTableViewController

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

    NSLog(@"Configuring Rest Kit for Tip Fetching");
    NSLog(@"Tips will Load");
    [self loadTips];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // Configure the cell...
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Tip *tip = _tips[rowNumber];
    TipDetailViewController* destinationViewController = segue.destinationViewController;
    destinationViewController.leagueType = tip.leagueType;
    destinationViewController.homeVsAwayTeams = [NSString stringWithFormat:@"%@ vs %@", tip.homeTeam, tip.awayTeam];
    destinationViewController.tipId = tip.id;
    

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    rowNumber = indexPath.row;
    [self performSegueWithIdentifier:@"predictionDetailSegue" sender:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) loadTips
{
    RKObjectMapping *tipsMapping = [RKObjectMapping mappingForClass:[Tip class]];
    
    
    
    [tipsMapping addAttributeMappingsFromArray:@[@"id", @"leagueType",
                                                 @"flagURL", @"homeTeam", @"awayTeam", @"isCompleted",
                                                 @"tipDetail", @"DateTimeCreated",
                                                 @"isPredictionVerified"]];
    
    RKResponseDescriptor *tipFetchingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tipsMapping method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [[RKObjectManager sharedManager] addResponseDescriptor:tipFetchingDescriptor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *authToken = [defaults objectForKey:KEY_USER_AUTH_TOKEN];
    
    NSString *basicAuthString = [NSString stringWithFormat:@"Basic %@",authToken];
    
    NSDictionary *params = @{@"isPushed":@"True"};

    
    //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_AUTHORIZATON value:basicAuthString];
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
    //[[[RKObjectManager sharedManager] HTTPClient] setAuthorizationHeaderWithUsername:email password:pass];

    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"api/predictions/" parameters:params
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  _tips = mappingResult.array;
                                                  Tip *tip = [_tips objectAtIndex:0];
                                                  NSLog(@"Tip LeagueType = %@", tip.leagueType);
                                                  [self.tableView reloadData];
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"WTF");
                                              }];
    
    
}

@end
