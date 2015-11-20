//
//  HMGridButton.m
//  HPMosaic
//
//  Created by HP Inc. on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMGridButton.h"

@implementation HMGridButton

CGFloat const kHMGridStrokeWidth = 2.0;

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextSetLineWidth(context, kHMGridStrokeWidth);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0.0);
    if (self.right) {
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    } else {
        CGContextMoveToPoint(context, self.bounds.size.width, self.bounds.size.height);
    }
    if (self.bottom) {
        CGContextAddLineToPoint(context, 0.0, self.bounds.size.height);
    } else {
        CGContextMoveToPoint(context, 0.0, self.bounds.size.height);
    }
    CGContextAddLineToPoint(context, 0.0, 0.0);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)setIncluded:(BOOL)included
{
    _included = included;
    self.backgroundColor = included ? self.tintColor : [UIColor clearColor];
    [self setNeedsDisplay];
}

@end
