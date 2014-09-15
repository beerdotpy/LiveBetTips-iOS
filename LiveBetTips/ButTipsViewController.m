//
//  ButTipsViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 28/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "ButTipsViewController.h"
#import <RestKit/RestKit.h>
@interface ButTipsViewController ()

@property RKObjectManager *objectManager;
@property RKResponseDescriptor *responseDescriptor;

@end

@interface NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@implementation ButTipsViewController

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

-(IBAction)buyCredit25:(id)sender
{
    
    credit = 5;
    NSSet *productIdentifiers = [NSSet setWithObject:@"fiveCredits"];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

-(IBAction)buyCredit50:(id)sender
{
    
    credit = 1;
    NSSet *productIdentifiers = [NSSet setWithObject:@"oneCredit"];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}



#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Invalid product id: %@" , response.description);
    if ([response.products count]==0) {
        UIAlertView	*alertmsg = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Sorry you cannot download" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertmsg show];
    }else {
		[self purchaseProUpgrade];
	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}


#pragma -
#pragma Public methods
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}
- (void)purchaseProUpgrade
{
    SKPayment *payment;
    if (credit==25) {
		payment=[SKPayment paymentWithProductIdentifier:@"fiveCredits"];
        
	}
    
    if (credit==50) {
		payment=[SKPayment paymentWithProductIdentifier:@"oneCredit"];
        
	}
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}
#pragma -
#pragma Purchase helpers
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"trans = %@",transaction.transactionReceipt);
}
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    NSLog(@"userInfo = %@",userInfo);
    if (wasSuccessful)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
        
        if ([transaction.payment.productIdentifier  isEqual: @"fiveCredits"]) {
            NSNumber* purchaseType = [[NSNumber alloc] initWithInt:5];
            NSNumber* cid = [[NSNumber alloc] initWithInt:2];
            [self postTransactionToServerWithCredit:purchaseType andCreditId:cid];

        } else if ([transaction.payment.productIdentifier  isEqual: @"oneCredit"]) {
            
            NSNumber* purchaseType = [[NSNumber alloc] initWithInt:1];
            NSNumber* cid = [[NSNumber alloc] initWithInt:1];
            [self postTransactionToServerWithCredit:purchaseType andCreditId:cid];
        }
        
        
    }
    else
    {
        NSLog([transaction.error description]);
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (void)provideContent:(NSString *)productId
{
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
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

-(void)postTransactionToServerWithCredit:(NSNumber*) creditPurchased andCreditId:(NSNumber *) creditID
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *id = [defaults objectForKey:KEY_USER_ID];
    NSDictionary *contactUsData;
    contactUsData = @{@"userID":id,
                      @"credit":creditPurchased,
                      @"creditID":creditID};
    
    //Convert Dictionary into JSON String
    NSString *jsonRequestData = [contactUsData bv_jsonStringWithPrettyPrint:true];
    NSLog(@"Json Data = %@", jsonRequestData);
    
    
    //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
    
    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    
    [[RKObjectManager sharedManager] postObject:nil path:@"api/user/credit/buy/"
                                     parameters:contactUsData
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            
                                            
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            
                                            int statusCode = operation.HTTPRequestOperation.response.statusCode;
                                            NSLog(@"Status Code = %d", statusCode);
                                            
                                        }
     ];
}

- (void) configureRestKit
{
    
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    //initialize RestKit
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    _responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:nil method:RKRequestMethodPOST pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [_objectManager addResponseDescriptor:_responseDescriptor];
    
}


@end
