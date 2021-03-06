//
//  HMScrollView.h
//  HPMosaic
//
//  Created by HP Inc. on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMScrollView : UIScrollView

@property (assign, nonatomic, readonly) CGFloat imageScale;
@property (assign, nonatomic, readonly) CGFloat paperScale;
@property (assign, nonatomic) CGPoint imageOffsetPercent;
@property (assign, nonatomic) CGSize gridSize;
@property (assign, nonatomic) CGSize paperSize;
@property (strong, nonatomic) UIImage *image;

- (void)updateLayout;
- (void)captureImageLocation;

@end
