//
//  HMSettingsViewController.m
//  HPMosaic
//
//  Created by HP Inc. on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMSettingsViewController.h"
#import "HMGridButton.h"

@interface HMSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *gridView;
@property (strong, nonatomic) NSMutableArray<HMGridButton *> *gridButtons;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *paperSizeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *orientationSegmentedControl;

@end

@implementation HMSettingsViewController

NSUInteger const kHMTotalRows = 5;
NSUInteger const kHMTotalColumns = 5;

NSUInteger const kHMPaper4x6SegmentIndex = 0;
NSUInteger const kHMPaper5x7SegmentIndex = 1;

NSUInteger const kHMPaperPortraitSegmentIndex = 0;
NSUInteger const kHMPaperLandscapeSegmentIndex = 1;

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGrid];
    [self setupPaper];
    [self refreshSettings:NO];
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

- (void)setupGrid
{
    self.gridButtons = [NSMutableArray array];
    for (int row = 0; row < kHMTotalRows; row++) {
        for (int column = 0; column < kHMTotalColumns; column++) {
            [self addButtonRow:row column:column];
        }
    }
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGridPan:)];
    [self.gridView addGestureRecognizer:panRecognizer];
}

- (void)setupPaper
{
    self.orientationSegmentedControl.selectedSegmentIndex = self.selectedPaperSize.width > self.selectedPaperSize.height ? kHMPaperLandscapeSegmentIndex : kHMPaperPortraitSegmentIndex;
    self.paperSizeSegmentedControl.selectedSegmentIndex = 4.0 == fminf(self.selectedPaperSize.width, self.selectedPaperSize.height) ? kHMPaper4x6SegmentIndex : kHMPaper5x7SegmentIndex;
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
    self.selectedGridSize = CGSizeMake(selectedColumn + 1, selectedRow + 1);
    [self refreshSettings:YES];
}

- (IBAction)paperSegmentValueChanged:(id)sender {
    self.selectedPaperSize = [self paperSize];
    [self refreshSettings:YES];
}

- (IBAction)orientationSegmentValueChanged:(id)sender {
    self.selectedPaperSize = [self paperSize];
    [self refreshSettings:YES];
}

#pragma mark - Refresh

- (void)refreshSettings:(BOOL)notify
{
    [self refreshButtons];
    [self refreshSizeLabel];
    if (notify && self.delegate && [self.delegate respondsToSelector:@selector(settingsDidChange:)]) {
        [self.delegate settingsDidChange:self];
    }
}

- (void)refreshButtons
{
    for (int row = 0; row < kHMTotalRows; row++) {
        for (int column = 0; column < kHMTotalColumns; column++) {
            BOOL included = row <= self.selectedGridSize.height - 1 && column <= self.selectedGridSize.width - 1;
            self.gridButtons[kHMTotalColumns * row + column].included = included;
        }
    }
}

- (void)refreshSizeLabel
{
    NSString *rowLabel = [NSString stringWithFormat:@"%.0f row%@", self.selectedGridSize.height, self.selectedGridSize.height > 1 ? @"s" : @""];
    NSString *columnLabel = [NSString stringWithFormat:@"%.0f column%@", self.selectedGridSize.width, self.selectedGridSize.width > 1 ? @"s" : @""];
    CGFloat width = self.selectedPaperSize.width * self.selectedGridSize.width;
    CGFloat height = self.selectedPaperSize.height * self.selectedGridSize.height;
    self.sizeLabel.text = [NSString stringWithFormat:@"%@ x %@ (%.0f\" x %.0f\")", columnLabel, rowLabel, width, height];
}

- (CGSize)paperSize
{
    CGFloat width = 4.0;
    CGFloat height = 6.0;
    if (kHMPaper4x6SegmentIndex == self.paperSizeSegmentedControl.selectedSegmentIndex &&
        kHMPaperLandscapeSegmentIndex == self.orientationSegmentedControl.selectedSegmentIndex) {
        width = 6.0;
        height = 4.0;
    } else if (kHMPaper5x7SegmentIndex == self.paperSizeSegmentedControl.selectedSegmentIndex &&
               kHMPaperPortraitSegmentIndex == self.orientationSegmentedControl.selectedSegmentIndex) {
        width = 5.0;
        height = 7.0;
    } else if (kHMPaper5x7SegmentIndex == self.paperSizeSegmentedControl.selectedSegmentIndex &&
               kHMPaperLandscapeSegmentIndex == self.orientationSegmentedControl.selectedSegmentIndex) {
        width = 7.0;
        height = 5.0;
    }
    return CGSizeMake(width, height);
}

#pragma mark - Gestures

- (void)handleGridPan:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.gridView];
    CGFloat rowHeight = self.gridView.bounds.size.height / kHMTotalRows;
    CGFloat columnWidth = self.gridView.bounds.size.width / kHMTotalColumns;
    NSUInteger row = location.y / rowHeight;
    NSUInteger column = location.x / columnWidth;
    
    if (UIGestureRecognizerStateChanged == gestureRecognizer.state) {
        self.selectedGridSize = CGSizeMake(column + 1, row + 1);
        [self refreshSettings:NO];
    } else if (UIGestureRecognizerStateEnded == gestureRecognizer.state) {
        self.selectedGridSize = CGSizeMake(column + 1, row + 1);
        [self refreshSettings:YES];
    }
}

@end
