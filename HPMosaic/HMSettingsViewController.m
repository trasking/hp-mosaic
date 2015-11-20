//
//  HMSettingsViewController.m
//  HPMosaic
//
//  Created by James Trask on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMSettingsViewController.h"
#import "HMGridButton.h"

@interface HMSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *gridView;
@property (strong, nonatomic) NSMutableArray<HMGridButton *> *gridButtons;
@property (assign, nonatomic) CGSize selectedSize;

@end

@implementation HMSettingsViewController

NSUInteger kHMTotalRows = 5;
NSUInteger kHMTotalColumns = 5;

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gridButtons = [NSMutableArray array];
    for (int row = 0; row < kHMTotalRows; row++) {
        for (int column = 0; column < kHMTotalColumns; column++) {
            [self addButtonRow:row column:column];
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        [self refreshButtons];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        [self refreshButtons];
    }];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Buttons

- (void)addButtonRow:(NSUInteger)row column:(NSUInteger)column
{
    HMGridButton *button = [[HMGridButton alloc] init];
    NSUInteger index = kHMTotalColumns * row + column;
    self.gridButtons[index] = button;
    [self.gridView addSubview:button];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.tag = index;
    button.right = (column == kHMTotalColumns - 1);
    button.bottom = (row == kHMTotalRows - 1);
    
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
    
    [button addTarget:self action:@selector(handleGridButtonTapped:) forControlEvents:UIControlEventTouchDragEnter + UIControlEventTouchDown];
    button.included = NO;
}

- (void)handleGridButtonTapped:(id)sender
{
    UIButton *button = sender;
    NSUInteger selectedRow = button.tag / kHMTotalColumns;
    NSUInteger selectedColumn = button.tag - (selectedRow * kHMTotalColumns);
    self.selectedSize = CGSizeMake(selectedColumn + 1, selectedRow + 1);
    [self refreshButtons];
}

- (void)refreshButtons
{
    for (int row = 0; row < kHMTotalRows; row++) {
        for (int column = 0; column < kHMTotalColumns; column++) {
            BOOL included = row <= self.selectedSize.height - 1 && column <= self.selectedSize.width - 1;
            self.gridButtons[kHMTotalColumns * row + column].included = included;
        }
    }
}

@end
