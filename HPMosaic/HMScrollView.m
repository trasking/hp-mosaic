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
@property (strong, nonatomic) CAShapeLayer *gridLayer;
@property (strong, nonatomic) UIView *gridView;

@end

@implementation HMScrollView

CGFloat kHMScrollViewGridStokeRatio = 0.01;
CGFloat kHMGridOpacity = 0.9;

- (void)drawRect:(CGRect)rect {

    if (!self.gridView) {
        self.gridView = [[UIView alloc] initWithFrame:CGRectZero];
        self.gridView.userInteractionEnabled = NO;
        [self.superview addSubview:self.gridView];
    }
    self.gridView.frame = self.frame;
    
    if (self.gridLayer) {
        [self.gridLayer removeFromSuperlayer];
    }
    
    CAShapeLayer *gridLayer = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat columnWidth = self.bounds.size.width / (float)self.gridSize.width;
    for (int column = 1; column < self.gridSize.width; column++) {
        CGFloat x = column * columnWidth;
        [path moveToPoint:CGPointMake(x, 0.0)];
        [path addLineToPoint:CGPointMake(x, self.bounds.size.height)];
    }
    
    CGFloat rowHeight = self.bounds.size.height / (float)self.gridSize.height;
    for (int row = 1; row < self.gridSize.height; row++) {
        CGFloat y = row * rowHeight;
        [path moveToPoint:CGPointMake(0.0, y)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width, y)];
    }
    
    CGFloat strokeWidth = fminf(self.superview.bounds.size.width, self.superview.bounds.size.height) * kHMScrollViewGridStokeRatio;
    gridLayer.lineWidth = strokeWidth;
    gridLayer.path = path.CGPath;
    gridLayer.strokeColor = [[UIColor whiteColor] CGColor];
    gridLayer.opacity = kHMGridOpacity;
    
    [self.gridView.layer addSublayer:gridLayer];
    self.gridLayer = gridLayer;
    
}

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
        [self needsUpdateConstraints];
        [self setNeedsDisplay];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateImageView];
    });
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self updateImageView];
}

- (void)updateImageView
{
    if (self.image) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        CGFloat xScale = self.bounds.size.width / self.image.size.width;
        CGFloat yScale = self.bounds.size.height / self.image.size.height;
        _imageScale = fmaxf(xScale, yScale);
        _paperScale = (self.bounds.size.width / self.gridSize.width) / self.paperSize.width;
        UIImageView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.image.size.width * _imageScale, self.image.size.height * _imageScale)];
        contentView.backgroundColor = [UIColor blackColor];
        contentView.contentMode = UIViewContentModeScaleAspectFit;
        contentView.image = self.image;
        [self addSubview:contentView];
        
        CGPoint contentCenter = CGPointMake(contentView.bounds.size.width * self.imageOffsetPercent.x, contentView.bounds.size.height * self.imageOffsetPercent.y);
        CGPoint scrollViewCenter = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        CGPoint offset = CGPointMake(fmaxf(contentCenter.x - scrollViewCenter.x, 0.0), fmaxf(contentCenter.y - scrollViewCenter.y, 0.0));
        
        self.contentOffset = offset;
        self.contentInset = UIEdgeInsetsZero;
        self.contentSize = contentView.bounds.size;
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}

- (void)updateLayout
{
    [self updateImageView];
}

- (void)captureImageLocation
{
    CGPoint centerPoint = CGPointMake(self.contentOffset.x + self.bounds.size.width / 2.0, self.contentOffset.y + self.bounds.size.height / 2.0);
    _imageOffsetPercent = CGPointMake(centerPoint.x / (self.image.size.width * self.imageScale), centerPoint.y / (self.image.size.height * self.imageScale));
}

@end
