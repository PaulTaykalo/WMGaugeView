//
//  WMGaugeViewStyleFlatThin.m
//  WMGaugeView
//
//  Created by Markezana, William on 25/10/15.
//  Copyright © 2015 Will™. All rights reserved.
//

#import "WMGaugeViewStyleFlatThin.h"

#define kNeedleWidth        0.012
#define kNeedleHeight       0.4
#define kNeedleScrewRadius  0.05

#define kCenterX            0.5
#define kCenterY            0.5

#define kNeedleColor        CGRGB(255, 104, 97)
#define kNeedleScrewColor   CGRGB(68, 84, 105)

@interface WMGaugeViewStyleFlatThinNeedleLayer : CAShapeLayer

@end

@implementation WMGaugeViewStyleFlatThinNeedleLayer

@end


@interface WMGaugeViewStyleFlatThin ()


@end

@implementation WMGaugeViewStyleFlatThin

- (void)drawNeedleOnLayer:(CALayer*)layer inRect:(CGRect)rect
{
    [self drawNeedleWithName:@"One needle" onLayer:layer inRect:rect];
}

- (void)drawNeedleWithName:(NSString *)needleName onLayer:(CALayer*)layer inRect:(CGRect)rect {
    CAShapeLayer *needleLayer = [WMGaugeViewStyleFlatThinNeedleLayer layer];
    UIBezierPath *needlePath = [UIBezierPath bezierPath];
    CGFloat additionalHeight = [self additionalHeightForNeedleWithName:needleName];
    [needlePath moveToPoint:CGPointMake(FULLSCALE(kCenterX - kNeedleWidth, kCenterY))];
    [needlePath addLineToPoint:CGPointMake(FULLSCALE(kCenterX + kNeedleWidth, kCenterY))];
    [needlePath addLineToPoint:CGPointMake(FULLSCALE(kCenterX, kCenterY - kNeedleHeight - additionalHeight))];
    [needlePath closePath];
    
    needleLayer.path = needlePath.CGPath;
    needleLayer.backgroundColor = [[UIColor clearColor] CGColor];

    UIColor * color = [self colorForNeedleWithName:needleName];
    needleLayer.fillColor = color.CGColor;
    needleLayer.strokeColor = color.CGColor;
    needleLayer.lineWidth = 1.2;
    
    // Needle shadow
    needleLayer.shadowColor = [[UIColor blackColor] CGColor];
    needleLayer.shadowOffset = CGSizeMake(-2.0, -2.0);
    needleLayer.shadowOpacity = 0.2;
    needleLayer.shadowRadius = 1.2;

    [layer addSublayer:needleLayer];
}

- (UIColor *)colorForNeedleWithName:(NSString *)name {
    static NSDictionary<NSString *, UIColor *> * colorsByName = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        colorsByName = @{
            @"red" : RGB(238,64,53),
            @"orange":RGB(243,119,54),
        	@"yellow":RGB(253,244,152),
        	@"green":RGB(123,192,67),
        	@"blue":RGB(3,146,207)
        };
    });
    UIColor * color = name ? colorsByName[name] : nil;
    return color ?: [UIColor colorWithCGColor:kNeedleColor];
}

- (CGFloat)additionalHeightForNeedleWithName:(NSString *)name {
    static NSDictionary<NSString *, NSNumber *> * heightsByName = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        heightsByName = @{
            @"red" : @(0.0),
            @"orange":@(-0.02),
            @"yellow":@(-0.03),
            @"green":@(-0.06),
            @"blue":@(-0.08)
        };
    });
    NSNumber * height = name ? heightsByName[name] : nil;
    return [height floatValue];
}

- (void)drawAdditionalItemsOnLayer:(CALayer *)layer inRect:(CGRect)rect {
    // Screw drawing
    CAShapeLayer *screwLayer = [CAShapeLayer layer];
    screwLayer.bounds = CGRectMake(FULLSCALE(kCenterX - kNeedleScrewRadius, kCenterY - kNeedleScrewRadius), FULLSCALE(kNeedleScrewRadius * 2.0, kNeedleScrewRadius * 2.0));
    screwLayer.position = CGPointMake(FULLSCALE(kCenterX, kCenterY));
    screwLayer.path = [UIBezierPath bezierPathWithOvalInRect:screwLayer.bounds].CGPath;
    screwLayer.fillColor = kNeedleScrewColor;

    // Screw shadow
    screwLayer.shadowColor = [[UIColor blackColor] CGColor];
    screwLayer.shadowOffset = CGSizeMake(0.0, 0.0);
    screwLayer.shadowOpacity = 0.2;
    screwLayer.shadowRadius = 2.0;

    [layer addSublayer:screwLayer];
}


- (void)drawFaceWithContext:(CGContextRef)context inRect:(CGRect)rect
{
#define EXTERNAL_RING_RADIUS    0.24
#define INTERNAL_RING_RADIUS    0.1
    
    // External circle
    CGContextAddEllipseInRect(context, CGRectMake(kCenterX - EXTERNAL_RING_RADIUS, kCenterY - EXTERNAL_RING_RADIUS, EXTERNAL_RING_RADIUS * 2.0, EXTERNAL_RING_RADIUS * 2.0));
    CGContextSetFillColorWithColor(context, CGRGB(255, 104, 97));
    CGContextFillPath(context);
    
    // Inner circle
    CGContextAddEllipseInRect(context, CGRectMake(kCenterX - INTERNAL_RING_RADIUS, kCenterY - INTERNAL_RING_RADIUS, INTERNAL_RING_RADIUS * 2.0, INTERNAL_RING_RADIUS * 2.0));
    CGContextSetFillColorWithColor(context, CGRGB(242, 99, 92));
    CGContextFillPath(context);
}

- (BOOL)needleLayer:(CALayer*)layer willMoveAnimated:(BOOL)animated duration:(NSTimeInterval)duration animation:(CAKeyframeAnimation*)animation
{
    for (CALayer * _needleLayer in layer.sublayers) {
        if ([_needleLayer isKindOfClass:[WMGaugeViewStyleFlatThinNeedleLayer class]]) {
            layer.transform = [[animation.values objectAtIndex:0] CATransform3DValue];
            CGAffineTransform affineTransform1 = [layer affineTransform];
            layer.transform = [[animation.values objectAtIndex:1] CATransform3DValue];
            CGAffineTransform affineTransform2 = [layer affineTransform];
            layer.transform = [[animation.values lastObject] CATransform3DValue];
            CGAffineTransform affineTransform3 = [layer affineTransform];

            _needleLayer.shadowOffset = CGSizeApplyAffineTransform(CGSizeMake(-2.0, -2.0), affineTransform3);

            [layer addAnimation:animation forKey:kCATransition];

            CAKeyframeAnimation * animationShadowOffset = [CAKeyframeAnimation animationWithKeyPath:@"shadowOffset"];
            animationShadowOffset.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animationShadowOffset.removedOnCompletion = YES;
            animationShadowOffset.duration = animated ? duration : 0.0;
            animationShadowOffset.values = @[[NSValue valueWithCGSize:CGSizeApplyAffineTransform(CGSizeMake(-2.0, -2.0), affineTransform1)],
                [NSValue valueWithCGSize:CGSizeApplyAffineTransform(CGSizeMake(-2.0, -2.0), affineTransform2)],
                [NSValue valueWithCGSize:CGSizeApplyAffineTransform(CGSizeMake(-2.0, -2.0), affineTransform3)]];
            [_needleLayer addAnimation:animationShadowOffset forKey:kCATransition];
        };
    }

    return YES;
}

@end
