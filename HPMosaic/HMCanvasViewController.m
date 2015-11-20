//
//  HMCanvasViewController.m
//  HPMosaic
//
//  Created by James Trask on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMCanvasViewController.h"
#import "HMSettingsViewController.h"

@interface HMCanvasViewController () <HMSettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;
@property (assign, nonatomic) CGSize gridSize;
@property (assign, nonatomic) CGSize paperSize;

@end

@implementation HMCanvasViewController

NSString * const kHMGridWidthKey = @"kHMGridWidthKey";
NSString * const kHMGridHeightKey = @"kHMGridHeightKey";
NSString * const kHMPaperWidthKey = @"kHMPaperWidthKey";
NSString * const kHMPaperHeightKey = @"kHMPaperHeightKey";

NSUInteger const kHMDefaultRows = 1;
NSUInteger const kHMDefaultColumns = 3;
CGFloat const kHMDefaultPaperWidth = 4.0;
CGFloat const kHMDefaultPaperHeight = 6.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFromUserDefaults];
}

- (IBAction)settingsButtonTapped:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    HMSettingsViewController *vc = (HMSettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HMSettingsViewController"];
    vc.delegate = self;
    vc.selectedGridSize = self.gridSize;
    vc.selectedPaperSize = self.paperSize;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:vc animated: YES completion:nil];
    UIPopoverPresentationController *presentationController = [vc popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.barButtonItem = self.editBarButtonItem;
}

#pragma mark - HMSettingsViewControllerDelegate

- (void)settingsDidChange:(HMSettingsViewController *)settingsController
{
    self.gridSize = settingsController.selectedGridSize;
    self.paperSize = settingsController.selectedPaperSize;
    [self saveToUserDefaults];
}

#pragma mark - User Defaults

- (void)loadFromUserDefaults
{
    NSNumber *gridWidth = [[NSUserDefaults standardUserDefaults] objectForKey:kHMGridWidthKey];
    NSNumber *gridHeight = [[NSUserDefaults standardUserDefaults] objectForKey:kHMGridHeightKey];
    NSNumber *paperWidth = [[NSUserDefaults standardUserDefaults] objectForKey:kHMPaperWidthKey];
    NSNumber *paperHeight = [[NSUserDefaults standardUserDefaults] objectForKey:kHMPaperHeightKey];
    if (gridWidth && gridHeight) {
        self.gridSize = CGSizeMake([gridWidth floatValue], [gridHeight floatValue]);
    } else {
        self.gridSize = CGSizeMake(kHMDefaultColumns, kHMDefaultRows);
    }
    if (paperWidth && paperHeight) {
        self.paperSize = CGSizeMake([paperWidth floatValue], [paperHeight floatValue]);
    } else {
        self.paperSize = CGSizeMake(kHMDefaultPaperWidth, kHMDefaultPaperHeight);
    }
}

- (void)saveToUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.gridSize.width] forKey:kHMGridWidthKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.gridSize.height] forKey:kHMGridHeightKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.paperSize.width] forKey:kHMPaperWidthKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.paperSize.height] forKey:kHMPaperHeightKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
