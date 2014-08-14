//
//  ContactUsViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 20/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "ContactUsViewController.h"
#import <RestKit.h>
@interface ContactUsViewController ()

@end

@implementation ContactUsViewController

@synthesize subjectOutlet;
@synthesize messageOutlet;

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)sendButtonClicked:(id)sender {
    
    if ([subjectOutlet.text length]>0) {
        if ([messageOutlet.text length]>0) {
            
            [self sendMessageWithSubject:subjectOutlet.text andMessage:messageOutlet.text];
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Message cannot be blank" delegate:nil cancelButtonTitle:@"Ok!" otherButtonTitles:nil, nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Subject Cannot Be Blank" delegate:nil cancelButtonTitle:@"Ok!" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(void)sendMessageWithSubject:(NSString *)subject andMessage:(NSString *)message {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:KEY_USER_NAME];
    NSLog(@"%@", email);
    NSDictionary *contactUsData;
    contactUsData = @{KEY_EMAIL:email,
                              @"content":message,
                            @"subject":subject};
    
    //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
    
    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    
    [[RKObjectManager sharedManager] postObject:nil path:@"api/user/contactUs/"
                                     parameters:contactUsData
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            
                                            
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            
                                            int statusCode = operation.HTTPRequestOperation.response.statusCode;
                                            NSLog(@"Status Code = %d", statusCode);
                                            
                                        }
     ];
    
}



@end
