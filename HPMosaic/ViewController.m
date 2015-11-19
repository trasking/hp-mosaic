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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *launchImageViewWideWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *launchImageViewNarrowAspectConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *launchImageViewWideAspectConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:1.0 animations:^{
        self.launchImageViewNarrowWidthConstraint.active = NO;
        self.launchImageViewNarrowAspectConstraint.active = NO;
        self.launchImageViewWideWidthConstraint.active = YES;
        self.launchImageViewWideAspectConstraint.active = YES;
        self.titleLabel.alpha = 0.0;
        [self.view layoutIfNeeded];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
