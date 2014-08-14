//
//  SignupViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 04/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "SignupViewController.h"
#import <Toast+UIView.h>
#import <RestKit.h>
#import "User.h"
@interface SignupViewController ()


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


@implementation SignupViewController

BOOL termsAccepted = NO;

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
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [_checkBtn setTitle:@"◻️" forState:UIControlStateNormal];
    
    [self configureRestKit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpButtonClicked:(id)sender {
    
    
    if (![self.emailTextField.text length] > 0) {
        
        [self kickUsersAssForNotFilling:@"Email"];
        
    } else if (![self.passwordTextField.text length] > 0) {
        
        [self kickUsersAssForNotFilling:@"Password"];
        
    } else if (![self.confirmPasswordTextField.text length] > 0) {
        
        [self kickUsersAssForNotFilling:@"Confirm Password"];

    } else {
       
        /*
            ALL inputs are presents lets now validate them
        */
        
        if (![self.passwordTextField.text isEqualToString: self.confirmPasswordTextField.text]) {
            NSLog(@"Pass = %@ , ConfirmPass = %@", self.passwordTextField.text, self.confirmPasswordTextField.text);
            [self.view makeToast:@"Passwords Don't Match!" duration:1.0 position:@"center"];
            
            return;
        } else if (![self NSStringIsValidEmail:self.emailTextField.text]) {
            [self.view makeToast:@"Invalid Email!" duration:1.0 position:@"center"];
            
            return;
        } else if (!termsAccepted) {
            [self kickUsersAssForNotFilling:@"Agree To Terms"];
        }else {
            
            //Everything is valid on client side
            //Time to make a request
            
            NSString *email = self.emailTextField.text;
            NSString *password = self.passwordTextField.text;
            
            
            NSDictionary *createUserRequestData;
            createUserRequestData = @{KEY_EMAIL:email,
                                      KEY_PASSWORD:password,};

            NSString *jsonRequestData = [createUserRequestData bv_jsonStringWithPrettyPrint:true];
            NSLog(@"Json Data = %@", jsonRequestData);

            
            //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
            [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
            
            NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
            
            [[RKObjectManager sharedManager] postObject:nil path:@"api/user/"
                                             parameters:createUserRequestData
                                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                    
                                                    
                                                }
                                                failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                    
                                                    int statusCode = operation.HTTPRequestOperation.response.statusCode;
                                                    NSLog(@"Status Code = %d", statusCode);
                                                    
                                                    if (statusCode == 201) {
                                                        [self notifyUserWithCreate:@"Please Check Your Email and Click on the Verification Link to Verify the Account"];
                                                    } else if (statusCode == 409) {
                                                        [self notifyUserWithCreate:@"An Account with this Email Already Exists!"];
                                                    } else {
                                                        [self notifyUserWithCreate:@"There was some problem!"];
                                                    }
                                                    
                                                }
             ];

        }
        
        
        
        
        
        
    }
}

- (IBAction)termsButtonClicked:(id)sender {
    
    
    [self performSegueWithIdentifier:@"termsSegue" sender:sender];
    
    
}




- (IBAction)checkButtonTapped:(UIButton*)sender {
    
    //sender.selected = !sender.selected;    // toggle button's selected state
    [self.view endEditing:YES];
    
    if (!termsAccepted) {
        [_checkBtn setTitle:@"☑️" forState:UIControlStateNormal];
        termsAccepted = YES;
    } else {
        [_checkBtn setTitle:@"◻️" forState:UIControlStateNormal];
        termsAccepted = NO;
    }
    
    
}

- (void) notifyUserWithCreate: (NSString *)response
{
    [self.view makeToast:response
                duration:2.0 position:@"center"];
}


- (void) kickUsersAssForNotFilling:(NSString *)field {
    
    NSString *constructedMessage = [NSString stringWithFormat:@"%@ cannot be blank!", field];
    
    //Show Alert Dialog
    UIAlertView *uiAlertView = [[UIAlertView alloc] initWithTitle:@"Bummer !" message:constructedMessage delegate:nil cancelButtonTitle:@"Got it!" otherButtonTitles:nil, nil];
    [uiAlertView show];
    
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (void) configureRestKit
{

    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    //initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    //setup object mappings
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[User class]];
    [userMapping addAttributeMappingsFromArray:@[KEY_USER_ID,KEY_EMAIL]];
    
    RKResponseDescriptor *createUserDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    [objectManager addResponseDescriptor:createUserDescriptor];
    
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


@end
