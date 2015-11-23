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
#import "HMScrollContainerView.h"
#import <MobilePrintSDK/MP.h>
#import <MobilePrintSDK/MPPrintItemFactory.h>
#import <MobilePrintSDK/MPLayoutFactory.h>

@interface HMCanvasViewController () <HMSettingsViewControllerDelegate, UIScrollViewDelegate, MPPrintDelegate, MPPrintPaperDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet HMScrollContainerView *scrollViewContainer;

@property (strong, nonatomic) UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *chooseBarButtonItem;
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
MPPaperSize const kHMDefaultPaperSize = MPPaperSize4x6;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMobilePrint];
    [self loadFromUserDefaults];
    [self prepareBarButtonItems];
    self.rotating = NO;
    self.scrollView.delegate = self;
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
        [self updateSubviews];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updateSubviews];
        self.rotating = NO;
    }];
}

- (void)updateSubviews
{
    [self.scrollView updateLayout];
    [self.scrollViewContainer setNeedsDisplay];
}

- (void)configureMobilePrint
{
    MPPaper *paper = [[MPPaper alloc] initWithPaperSize:kHMDefaultPaperSize paperType:MPPaperTypePhoto];
    [MP sharedInstance].defaultPaper = paper;
    [MP sharedInstance].supportedPapers = @[ paper ];
    [MP sharedInstance].hidePaperSizeOption = YES;
    [MP sharedInstance].hidePaperTypeOption = YES;
}

#pragma mark - HMSettingsViewControllerDelegate

- (void)settingsDidChange:(HMSettingsViewController *)settingsController
{
    self.scrollView.gridSize = settingsController.selectedGridSize;
    self.scrollView.paperSize = settingsController.selectedPaperSize;
    [self saveToUserDefaults];
    [self updateSubviews];
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
        self.scrollView.paperSize = CGSizeMake([MP sharedInstance].defaultPaper.width, [MP sharedInstance].defaultPaper.height);
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
//    UIAlertControllerStyle style = phone ? UIAlertControllerStyleActionSheet : UIAlertControllerStyleAlert;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose a Photo" message:@"Pick a photo source from one of the following options." preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseFromCameraRoll];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dropbox" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseFromDropbox];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

   if ([self iPhone]) {
        [self presentViewController:alert animated: YES completion:nil];
    } else {
        alert.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:alert animated: YES completion:nil];
        UIPopoverPresentationController *presentationController = [alert popoverPresentationController];
        presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        presentationController.barButtonItem = self.chooseBarButtonItem;
    }
}

- (void)chooseFromCameraRoll
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([self iPhone]) {
        [self presentViewController:picker animated: YES completion:nil];
    } else {
        picker.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:picker animated: YES completion:nil];
        UIPopoverPresentationController *presentationController = [picker popoverPresentationController];
        presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        presentationController.barButtonItem = self.chooseBarButtonItem;
    }
}

- (void)chooseFromDropbox
{
    NSLog(@"DROPBOX");
}

- (BOOL)iPhone
{
    return UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Print

- (void)showPrint
{
    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:[UIImage imageNamed:@"Sample Image"]];
    MPLayoutOrientation orientation = MPLayoutOrientationPortrait;
    if (self.scrollView.paperSize.width > self.scrollView.paperSize.height) {
        orientation = MPLayoutOrientationLandscape;
    }
    printItem.layout = [MPLayoutFactory layoutWithType:[MPLayoutFill layoutType] orientation:orientation assetPosition:[MPLayout completeFillRectangle]];
    UIViewController *vc = [[MP sharedInstance] printViewControllerWithDelegate:self dataSource:nil printItem:printItem fromQueue:NO settingsOnly:NO];
    [self presentViewController:vc animated:YES completion:nil];
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
    
    self.chooseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStylePlain target:self action:@selector(chooseButtonTapped:)];
    UIBarButtonItem *printButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Print Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(printButtonTapped:)];
    self.navigationItem.rightBarButtonItems = @[ self.chooseBarButtonItem, printButton ];
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
    }
}

#pragma mark - MPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - MPPrintPaperDelegate

- (MPPaper *)defaultPaperForPrintSettings:(MPPrintSettings *)printSettings
{
    MPPaperSize size = MPPaperSize4x6;
    if (5.0 == fminf(self.scrollView.paperSize.width, self.scrollView.paperSize.height)) {
        size = MPPaperSize5x7;
    }
    return [[MPPaper alloc] initWithPaperSize:size paperType:MPPaperTypePhoto];;
}

- (NSArray *)supportedPapersForPrintSettings:(MPPrintSettings *)printSettings
{
    return @[ [self defaultPaperForPrintSettings:printSettings] ];
}

@end
