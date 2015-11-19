//
//  ViewController.m
//  HPMosaic
//
//  Created by James Trask on 11/18/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *launchImageViewNarrowWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *launchImageViewNarrowAspectConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *launchImageView;

@end

@implementation ViewController

CGFloat kLaunchAnimationDelay = 0.5; // seconds
CGFloat kLaunchAnimationDuration = 1.0; // seconds
CGFloat kLaunchConstraintWidthMultiplier = 0.75;
CGFloat kLaunchConstraintAspectRatioMultiplier = 2400.0 / 635.0;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kLaunchAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
        [self adjustConstraintsAfterLaunch];
        [UIView animateWithDuration:kLaunchAnimationDuration animations:^{
            self.titleLabel.alpha = 0.0;
            [self.view layoutIfNeeded];
        }];
    });
}

- (void)adjustConstraintsAfterLaunch
{
    NSLayoutConstraint *wideWidthConstraint = [NSLayoutConstraint constraintWithItem:self.launchImageView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.launchImageView.superview
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:kLaunchConstraintWidthMultiplier
                                                                            constant:0 ];
    
    
    NSLayoutConstraint *wideAspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self.launchImageView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.launchImageView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:kLaunchConstraintAspectRatioMultiplier
                                                                            constant:0 ];
    
    
    self.launchImageViewNarrowWidthConstraint.active = NO;
    self.launchImageViewNarrowAspectConstraint.active = NO;
    wideWidthConstraint.active = YES;
    wideAspectRatioConstraint.active = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
