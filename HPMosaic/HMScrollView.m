//
//  HMself.m
//  HPMosaic
//
//  Created by HP Inc. on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMScrollView.h"

@implementation HMScrollView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)setImage:(UIImage *)image
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat xScale = self.bounds.size.width / image.size.width;
    CGFloat yScale = self.bounds.size.height / image.size.height;
    CGFloat scale = fmaxf(xScale, yScale);
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)];
    contentView.backgroundColor = [UIColor blackColor];
    contentView.contentMode = UIViewContentModeScaleAspectFit;
    contentView.image = image;
    [self addSubview:contentView];
    self.contentOffset = CGPointZero;
    self.contentInset = UIEdgeInsetsZero;
    self.contentSize = contentView.bounds.size;
}

@end
