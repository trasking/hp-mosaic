//
//  ViewController.m
//  HPMosaic
//
//  Created by HP Inc. on 11/18/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *launchImageViewNarrowWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *launchImageViewNarrowAspectConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *launchImageView;

@property (strong, nonatomic)  NSLayoutConstraint *launchImageViewWidthConstraint;
@property (strong, nonatomic)  NSLayoutConstraint *launchImageViewHeightConstraint;
@property (strong, nonatomic)  NSLayoutConstraint *launchImageViewAspectConstraint;

@end

@implementation LaunchViewController

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
        } completion:^(BOOL finished) {
            [self.view layoutIfNeeded];
            [self adjustConstraintsForFullWidth];
            [UIView animateWithDuration:kLaunchAnimationDuration animations:^{
                self.launchImageView.alpha = 0.0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                // animations complete
            }];
        }];
    });
}

- (void)adjustConstraintsAfterLaunch
{
    self.launchImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.launchImageView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.launchImageView.superview
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:kLaunchConstraintWidthMultiplier
                                                                            constant:0 ];
    
    
    self.launchImageViewAspectConstraint = [NSLayoutConstraint constraintWithItem:self.launchImageView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.launchImageView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:kLaunchConstraintAspectRatioMultiplier
                                                                            constant:0 ];
    
    
    self.launchImageViewNarrowWidthConstraint.active = NO;
    self.launchImageViewNarrowAspectConstraint.active = NO;
    self.launchImageViewWidthConstraint.active = YES;
    self.launchImageViewAspectConstraint.active = YES;
}

- (void)adjustConstraintsForFullWidth
{
    self.launchImageViewWidthConstraint.active = NO;
    self.launchImageViewAspectConstraint.active = NO;

    self.launchImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.launchImageView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.launchImageView.superview
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:0 ];
    self.launchImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.launchImageView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.launchImageView.superview
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0 ];
    self.launchImageViewWidthConstraint.active = YES;
    self.launchImageViewHeightConstraint.active = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
