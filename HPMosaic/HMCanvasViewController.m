//
//  HMCanvasViewController.m
//  HPMosaic
//
//  Created by James Trask on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMCanvasViewController.h"

@interface HMCanvasViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;

@end

@implementation HMCanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)editButtonTapped:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HMSettingsViewController"];

    vc.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:vc animated: YES completion:nil];

    UIPopoverPresentationController *presentationController = [vc popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.barButtonItem = self.editBarButtonItem;
}

@end
