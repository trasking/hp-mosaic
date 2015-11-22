//
//  HMScrollContainerView.m
//  HPMosaic
//
//  Created by HP Inc. on 11/22/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMScrollContainerView.h"

@interface HMScrollContainerView()

@property (strong, nonatomic) CAShapeLayer *overlay;

@end

@implementation HMScrollContainerView

CGFloat kHMScrollContainerOverlayAlpha = 0.8;

- (void)drawRect:(CGRect)rect {
    
    UIView *scrollView = [self.subviews firstObject];

    if (self.overlay) {
        [self.overlay removeFromSuperlayer];
    }
    
    self.overlay = [CAShapeLayer layer];
    
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRect:self.frame];
    outerPath.usesEvenOddFillRule = YES;
    
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRect:scrollView.frame];
    [outerPath appendPath:innerPath];
    
    self.overlay.path = [outerPath CGPath];
    self.overlay.fillRule = kCAFillRuleEvenOdd;
    self.overlay.fillColor = [[UIColor whiteColor] CGColor];
    self.overlay.opacity = kHMScrollContainerOverlayAlpha;
    
    [self.layer addSublayer:self.overlay];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self pointInside:point withEvent:event] ? [self.subviews firstObject] : nil;
}

@end
