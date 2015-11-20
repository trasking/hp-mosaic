//
//  HMSettingsViewController.m
//  HPMosaic
//
//  Created by James Trask on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMSettingsViewController.h"

@interface HMSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *gridView;
@property (strong, nonatomic) NSMutableArray<UIButton *> *gridButtons;

@end

@implementation HMSettingsViewController

NSUInteger kHMTotalRows = 5;
NSUInteger kHMTotalColumns = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gridButtons = [NSMutableArray array];
    for (int row = 0; row < kHMTotalRows; row++) {
        for (int column = 0; column < kHMTotalColumns; column++) {
            [self addButtonRow:row column:column];
        }
    }
}

- (void)addButtonRow:(NSUInteger)row column:(NSUInteger)column
{
    UIButton *button = [[UIButton alloc] init];
    NSUInteger index = kHMTotalColumns * row + column;
    self.gridButtons[index] = button;
    [self.gridView addSubview:button];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.tag = index;
    CGFloat alpha = (float)index / ((float)kHMTotalColumns * (float)kHMTotalRows);
    button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    
    CGFloat widthPercent = 1.0 / (float)kHMTotalColumns;
    CGFloat widthMultiplier = ((float)column * widthPercent + 0.5 * widthPercent) / 0.5;
    
    CGFloat heightPercent = 1.0 / (float)kHMTotalRows;
    CGFloat heightMultiplier = ((float)row * heightPercent + 0.5 * heightPercent) / 0.5;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:button.superview
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:heightMultiplier
                                                                      constant:0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:button.superview
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:widthMultiplier
                                                                      constant:0];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:button.superview
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:widthPercent
                                                                      constant:0];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:button.superview
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:heightPercent
                                                                      constant:0];
    
    topConstraint.active = YES;
    leftConstraint.active = YES;
    widthConstraint.active = YES;
    heightConstraint.active = YES;
    
    [button addTarget:self action:@selector(handleGridButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleGridButtonTapped:(id)sender
{
    UIButton *button = sender;
    NSUInteger row = button.tag / kHMTotalColumns;
    NSUInteger column = button.tag - (row * kHMTotalColumns);
    NSLog(@"ROW: %d, COL: %d", row, column);
}

@end
