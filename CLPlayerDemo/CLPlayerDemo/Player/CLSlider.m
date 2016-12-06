//
//  Slider.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/2.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "CLSlider.h"

@implementation CLSlider

// 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    [super trackRectForBounds:bounds];
    return CGRectMake(-2, (self.frame.size.height - 3)/2.0, CGRectGetWidth(bounds) + 4, 3);
}

//- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
//{
//    
//}


@end
