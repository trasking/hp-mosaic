//
//  HMself.m
//  HPMosaic
//
//  Created by HP Inc. on 11/19/15.
//  Copyright © 2015 Pilots & Incubation. All rights reserved.
//

#import "HMScrollView.h"

@interface HMScrollView()

@property (strong, nonatomic) NSLayoutConstraint *aspectRatioConstraint;

@end

@implementation HMScrollView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)setGridSize:(CGSize)gridSize
{
    _gridSize = gridSize;
    [self setAspectRatio];
}

- (void)setPaperSize:(CGSize)paperSize
{
    _paperSize = paperSize;
    [self setAspectRatio];
}

- (void)setAspectRatio
{
    if (self.aspectRatioConstraint) {
        self.aspectRatioConstraint.active = NO;
    }
    
    if (!CGSizeEqualToSize(CGSizeZero, self.gridSize) && !CGSizeEqualToSize(CGSizeZero, self.paperSize)) {
        CGFloat aspectRatio = (self.gridSize.width * self.paperSize.width) / (self.gridSize.height * self.paperSize.height);
        self.aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:aspectRatio constant:0];
        self.aspectRatioConstraint.active = YES;
    }
    
    [self needsUpdateConstraints];
}

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
