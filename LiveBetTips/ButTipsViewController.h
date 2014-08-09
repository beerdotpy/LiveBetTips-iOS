//
//  ButTipsViewController.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 28/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@interface ButTipsViewController : UIViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
    
    int credit;
    
}

@end
