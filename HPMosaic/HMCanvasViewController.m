//
//  HMCanvasViewController.m
//  HPMosaic
//
//  Created by HP Inc. on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMCanvasViewController.h"
#import "HMSettingsViewController.h"
#import "HMScrollView.h"

@interface HMCanvasViewController () <HMSettingsViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *settingsBarButtonItem;
@property (weak, nonatomic) IBOutlet HMScrollView *scrollView;
@property (assign, nonatomic) BOOL rotating;

@end

@implementation HMCanvasViewController

NSString * const kHMGridWidthKey = @"kHMGridWidthKey";
NSString * const kHMGridHeightKey = @"kHMGridHeightKey";
NSString * const kHMPaperWidthKey = @"kHMPaperWidthKey";
NSString * const kHMPaperHeightKey = @"kHMPaperHeightKey";
NSString * const kHMContentOffsetHorizontalKey = @"kHMContentOffsetHorizontalKey";
NSString * const kHMContentOffsetVerticalKey = @"kHMContentOffsetVerticalKey";

NSUInteger const kHMDefaultGridHeight = 1;
NSUInteger const kHMDefaultGridWidth = 3;
CGFloat const kHMDefaultPaperWidth = 4.0;
CGFloat const kHMDefaultPaperHeight = 6.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    [self loadFromUserDefaults];
    [self prepareBarButtonItems];
    self.rotating = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollView.image = [UIImage imageNamed:@"Sample Image"];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.rotating = YES;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.scrollView updateLayout];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.scrollView updateLayout];
        self.rotating = NO;
    }];
}

#pragma mark - HMSettingsViewControllerDelegate

- (void)settingsDidChange:(HMSettingsViewController *)settingsController
{
    self.scrollView.gridSize = settingsController.selectedGridSize;
    self.scrollView.paperSize = settingsController.selectedPaperSize;
    [self saveToUserDefaults];
}

#pragma mark - User Defaults

- (void)loadFromUserDefaults
{
    NSNumber *gridWidth = [[NSUserDefaults standardUserDefaults] objectForKey:kHMGridWidthKey];
    NSNumber *gridHeight = [[NSUserDefaults standardUserDefaults] objectForKey:kHMGridHeightKey];
    NSNumber *paperWidth = [[NSUserDefaults standardUserDefaults] objectForKey:kHMPaperWidthKey];
    NSNumber *paperHeight = [[NSUserDefaults standardUserDefaults] objectForKey:kHMPaperHeightKey];
    NSNumber *offsetX = [[NSUserDefaults standardUserDefaults] objectForKey:kHMContentOffsetHorizontalKey];
    NSNumber *offsetY = [[NSUserDefaults standardUserDefaults] objectForKey:kHMContentOffsetVerticalKey];
    
    if (gridWidth && gridHeight) {
        self.scrollView.gridSize = CGSizeMake([gridWidth floatValue], [gridHeight floatValue]);
    } else {
        self.scrollView.gridSize = CGSizeMake(kHMDefaultGridWidth, kHMDefaultGridHeight);
    }
    
    if (paperWidth && paperHeight) {
        self.scrollView.paperSize = CGSizeMake([paperWidth floatValue], [paperHeight floatValue]);
    } else {
        self.scrollView.paperSize = CGSizeMake(kHMDefaultPaperWidth, kHMDefaultPaperHeight);
    }
    
    if (offsetX && offsetY) {
        self.scrollView.imageOffsetPercent = CGPointMake([offsetX floatValue], [offsetY floatValue]);
    } else {
        self.scrollView.imageOffsetPercent = CGPointZero;
    }
}

- (void)saveToUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.gridSize.width] forKey:kHMGridWidthKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.gridSize.height] forKey:kHMGridHeightKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.paperSize.width] forKey:kHMPaperWidthKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.paperSize.height] forKey:kHMPaperHeightKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.imageOffsetPercent.x] forKey:kHMContentOffsetHorizontalKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.imageOffsetPercent.y] forKey:kHMContentOffsetVerticalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Choose Photo

- (void)showPhotoSelection
{
    // TO DO
}

#pragma mark - Print

- (void)showPrint
{
    // TO DO
}

#pragma mark - Settings

- (void)showSettings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    HMSettingsViewController *vc = (HMSettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HMSettingsViewController"];
    vc.delegate = self;
    vc.selectedGridSize = self.scrollView.gridSize;
    vc.selectedPaperSize = self.scrollView.paperSize;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:vc animated: YES completion:nil];
    UIPopoverPresentationController *presentationController = [vc popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.barButtonItem = self.settingsBarButtonItem;
}

#pragma mark - Bar Button Items

- (void)prepareBarButtonItems
{
    self.settingsBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTapped:)];
    self.navigationItem.leftBarButtonItem = self.settingsBarButtonItem;
    
    UIBarButtonItem *chooseButton = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStylePlain target:self action:@selector(chooseButtonTapped:)];
    UIBarButtonItem *printButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Print Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(printButtonTapped:)];
    self.navigationItem.rightBarButtonItems = @[ chooseButton, printButton ];
}

- (void)chooseButtonTapped:(id)sender
{
    [self showPhotoSelection];
}

- (void)printButtonTapped:(id)sender
{
    [self showPrint];
}

- (void)settingsButtonTapped:(id)sender {
    [self showSettings];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.rotating) {
        HMScrollView *sv = (HMScrollView *)scrollView;
        [sv captureImageLocation];
        [self saveToUserDefaults];
        NSLog(@"OFFSET PERCENT:  %.3f, %.3f", sv.imageOffsetPercent.x, sv.imageOffsetPercent.y);
    }
}

@end
