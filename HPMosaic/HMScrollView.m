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

CGFloat kHMScrollViewGridStokeWidth = 10.0;

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
    for (int column = 0; column <= self.gridSize.width; column++) {
        CGFloat x = column * columnWidth;
        [path moveToPoint:CGPointMake(x, 0.0)];
        [path addLineToPoint:CGPointMake(x, self.bounds.size.height)];
    }
    
    CGFloat rowHeight = self.bounds.size.height / (float)self.gridSize.height;
    for (int row = 0; row <= self.gridSize.height; row++) {
        CGFloat y = row * rowHeight;
        [path moveToPoint:CGPointMake(0.0, y)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width, y)];
    }
    
    gridLayer.lineWidth = kHMScrollViewGridStokeWidth;
    gridLayer.path = path.CGPath;
    gridLayer.strokeColor = [[UIColor whiteColor] CGColor];
    
    [self.gridView.layer addSublayer:gridLayer];
    self.gridLayer = gridLayer;
    
    //     CGContextRef context = UIGraphicsGetCurrentContext();
    //     CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    //     CGContextSetLineWidth(context, kHMScrollViewGridStokeWidth);
    //
    //     CGFloat columnWidth = self.bounds.size.width / (float)self.gridSize.width;
    //     for (int column = 0; column <= self.gridSize.width; column++) {
    //         CGFloat x = column * columnWidth;
    //         CGContextMoveToPoint(context, x, 0.0);
    //         CGContextAddLineToPoint(context, x, self.bounds.size.height);
    //     }
    //
    //     CGFloat rowHeight = self.bounds.size.height / (float)self.gridSize.height;
    //     for (int row = 0; row <= self.gridSize.height; row++) {
    //         CGFloat y = row * rowHeight;
    //         CGContextMoveToPoint(context, 0.0, y);
    //         CGContextAddLineToPoint(context, self.bounds.size.width, y);
    //     }
    //
    //     CGContextDrawPath(context, kCGPathStroke);
    
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
    }
    
    [self needsUpdateConstraints];
    [self setNeedsDisplay];
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
    [self setNeedsDisplay];
}

@end
