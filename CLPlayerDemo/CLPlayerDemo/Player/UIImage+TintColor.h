//
//  UIImage+TintColor.h
//  ckd
//
//  Created by JmoVxia on 2016/10/21.
//  Copyright © 2016年 David Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TintColor)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;

- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;

@end
