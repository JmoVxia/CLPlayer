//
//  UIImage+TintColor.m
//  ckd
//
//  Created by JmoVxia on 2016/10/21.
//  Copyright © 2016年 David Zheng. All rights reserved.
//

#import "UIImage+TintColor.h"

@implementation UIImage (TintColor)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor

{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
    
}

- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor

{
    
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
    
}

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode

{
    
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    [tintColor setFill];
    
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tintedImage;
    
}


@end
