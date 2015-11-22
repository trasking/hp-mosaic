//
//  HMScrollContainerView.m
//  HPMosaic
//
//  Created by HP Inc. on 11/22/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMScrollContainerView.h"

@implementation HMScrollContainerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self pointInside:point withEvent:event] ? [self.subviews firstObject] : nil;
}

@end
