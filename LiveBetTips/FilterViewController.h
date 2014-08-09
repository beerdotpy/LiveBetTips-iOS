//
//  FilterViewController.h
//  LiveBetTips
//
//  Created by Ishan Khanna on 23/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewControllerDelegate;

@interface FilterViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    
    IBOutlet UIPickerView *leagueNamePicker;
    
    IBOutlet UIPickerView *predictionNamePicker;
    
    id<FilterViewControllerDelegate> delegate;
}
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSArray *leagueTypes;
@property (nonatomic, strong) NSArray *predictionNames;

-(IBAction)handleUpdateButton:(id)sender;

@end

@protocol FilterViewControllerDelegate <NSObject>

-(void)filterViewController: (FilterViewController *)filterViewController
      choosenLeagueName:(NSString *)leageName
      choosenPredictionName:(NSString *)predictionName;

@end
