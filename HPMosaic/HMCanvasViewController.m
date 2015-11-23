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
#import <Photos/Photos.h>

@interface HMCanvasViewController () <HMSettingsViewControllerDelegate, UIScrollViewDelegate, MPPrintDelegate, MPPrintPaperDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet HMScrollContainerView *scrollViewContainer;

@property (strong, nonatomic) UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *chooseBarButtonItem;
@property (weak, nonatomic) IBOutlet HMScrollView *scrollView;
@property (strong, nonatomic) NSURL *photoURL;

@end

@implementation HMCanvasViewController

NSString * const kHMGridWidthKey = @"kHMGridWidthKey";
NSString * const kHMGridHeightKey = @"kHMGridHeightKey";
NSString * const kHMPaperWidthKey = @"kHMPaperWidthKey";
NSString * const kHMPaperHeightKey = @"kHMPaperHeightKey";
NSString * const kHMImageOffsetPercentXKey = @"kHMImageOffsetPercentXKey";
NSString * const kHMImageOffsetPercentYKey = @"kHMImageOffsetPercentYKey";
NSString * const kHMPhotoURLKey = @"kHMPhotoURLKey";

NSUInteger const kHMDefaultGridHeight = 1;
NSUInteger const kHMDefaultGridWidth = 3;
MPPaperSize const kHMDefaultPaperSize = MPPaperSize4x6;
CGFloat const kHMDefaultImageOffsetPercentX = 0.5;
CGFloat const kHMDefaultImageOffsetPercentY = 0.5;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMobilePrint];
    [self loadFromUserDefaults];
    [self prepareBarButtonItems];
    self.scrollView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updateSubviews];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updateSubviews];
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

#pragma mark - User Defaults

- (void)loadFromUserDefaults
{
    NSNumber *gridWidth = [[NSUserDefaults standardUserDefaults] objectForKey:kHMGridWidthKey];
    NSNumber *gridHeight = [[NSUserDefaults standardUserDefaults] objectForKey:kHMGridHeightKey];
    NSNumber *paperWidth = [[NSUserDefaults standardUserDefaults] objectForKey:kHMPaperWidthKey];
    NSNumber *paperHeight = [[NSUserDefaults standardUserDefaults] objectForKey:kHMPaperHeightKey];
    NSNumber *offsetX = [[NSUserDefaults standardUserDefaults] objectForKey:kHMImageOffsetPercentXKey];
    NSNumber *offsetY = [[NSUserDefaults standardUserDefaults] objectForKey:kHMImageOffsetPercentYKey];
    NSURL *photoURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kHMPhotoURLKey]];
    
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
        self.scrollView.imageOffsetPercent = CGPointMake(kHMDefaultImageOffsetPercentX, kHMDefaultImageOffsetPercentY);
    }
    
    self.photoURL = photoURL;
    PHFetchResult<PHAsset *> *result = photoURL ? [PHAsset fetchAssetsWithALAssetURLs:@[ photoURL] options:nil] : nil;
    if (result && result.count > 0) {
        [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.synchronous = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    self.scrollView.image = result;
                }];
            });
        }];
    } else {
        self.scrollView.image = [UIImage imageNamed:@"Sample Image"];
    }
}

- (void)saveToUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.gridSize.width] forKey:kHMGridWidthKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.gridSize.height] forKey:kHMGridHeightKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.paperSize.width] forKey:kHMPaperWidthKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.paperSize.height] forKey:kHMPaperHeightKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.imageOffsetPercent.x] forKey:kHMImageOffsetPercentXKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.scrollView.imageOffsetPercent.y] forKey:kHMImageOffsetPercentYKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.photoURL.absoluteString forKey:kHMPhotoURLKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Choose Photo

- (void)showChoosePhoto
{
    //    UIAlertControllerStyle style = phone ? UIAlertControllerStyleActionSheet : UIAlertControllerStyleAlert;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose a Photo" message:@"Pick a photo source from one of the following options." preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseFromPhotoLibrary];
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

- (void)chooseFromPhotoLibrary
{
    [self verifyPhotoAccess];
}

- (void)chooseFromDropbox
{
    NSLog(@"DROPBOX");
}

- (BOOL)iPhone
{
    return UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom];
}

#pragma mark - Photo access


- (void)verifyPhotoAccess
{
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    if (PHAuthorizationStatusAuthorized == authorizationStatus) {
        [self showPhotoSelection];
    } else if (PHAuthorizationStatusNotDetermined == authorizationStatus) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self verifyPhotoAccess];
        }];
    } else if (PHAuthorizationStatusDenied == authorizationStatus) {
        [self noAccessWithCaption:@"No Access" andMessage:@"Access to photos has been denied on this device."];
    } else if (PHAuthorizationStatusRestricted == authorizationStatus) {
        [self noAccessWithCaption:@"Restricted Access" andMessage:@"Access to photos is restricted by a policy on this device."];
    }
}

- (void)noAccessWithCaption:(NSString *)caption andMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:caption
                                                                   message:[NSString stringWithFormat:@"%@ The HP Mosaic app must be given access to your Photo Library before you can choose a photo from this device. Please check your settings.\n\nSettings → HP Mosaic → Photos", message]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openSettings];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)openSettings
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    });
}

- (IBAction)authorizeButtonTapped:(id)sender {
    [self openSettings];
}

- (void)showPhotoSelection
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.scrollView.imageOffsetPercent = CGPointMake(kHMDefaultImageOffsetPercentX, kHMDefaultImageOffsetPercentY);
    self.photoURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    self.scrollView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self saveToUserDefaults];
//    [self.scrollView updateLayout];
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


#pragma mark - HMSettingsViewControllerDelegate

- (void)settingsDidChange:(HMSettingsViewController *)settingsController
{
    self.scrollView.gridSize = settingsController.selectedGridSize;
    self.scrollView.paperSize = settingsController.selectedPaperSize;
    [self saveToUserDefaults];
    [self updateSubviews];
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
    [self showChoosePhoto];
}

- (void)printButtonTapped:(id)sender
{
    [self showPrint];
}

- (void)settingsButtonTapped:(id)sender {
    [self showSettings];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        HMScrollView *sv = (HMScrollView *)scrollView;
        [sv captureImageLocation];
        [self saveToUserDefaults];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    HMScrollView *sv = (HMScrollView *)scrollView;
    [sv captureImageLocation];
    [self saveToUserDefaults];
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
