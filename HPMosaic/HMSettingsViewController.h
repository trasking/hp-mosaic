//
//  HMSettingsViewController.h
//  HPMosaic
//
//  Created by HP Inc. on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HMSettingsViewControllerDelegate;

@interface HMSettingsViewController : UIViewController

@property (assign, nonatomic) CGSize selectedGridSize;
@property (assign, nonatomic) CGSize selectedPaperSize;
@property (weak, nonatomic) id<HMSettingsViewControllerDelegate>delegate;

@end

@protocol HMSettingsViewControllerDelegate <NSObject>

- (void)settingsDidChange:(HMSettingsViewController *)settingsController;

@end