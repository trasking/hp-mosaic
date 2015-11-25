//
//  ViewController.m
//  HPMosaic
//
//  Created by HP Inc. on 11/18/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMLaunchViewController.h"

@interface HMLaunchViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *launchImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *launchImageView;

@end

@implementation HMLaunchViewController

CGFloat const kHMLaunchAnimationDelay = 0.5; // seconds
CGFloat const kHMLaunchAnimationDuration = 0.61803399; // seconds
CGFloat const kHMLaunchConstraintWidthMultiplier = 0.01;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kHMLaunchAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:kHMLaunchAnimationDuration * 0.25 animations:^{
            self.titleLabel.alpha = 0.0;
        }];
        
        [self adjustConstraintsAfterLaunch];
        [UIView animateWithDuration:kHMLaunchAnimationDuration animations:^{
            self.launchImageView.alpha = 0.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self performSegueWithIdentifier:@"Show Canvas" sender:self];
        }];
        
    });
}

- (void)adjustConstraintsAfterLaunch
{
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.launchImageView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.launchImageView.superview
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:kHMLaunchConstraintWidthMultiplier
                                                                        constant:0 ];
    
    self.launchImageViewWidthConstraint.active = NO;
    widthConstraint.active = YES;
}

@end
