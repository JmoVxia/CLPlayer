//
//  CLImageHelper.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2020/4/30.
//  Copyright © 2020 JmoVxia. All rights reserved.
//

#import "CLImageHelper.h"

@implementation CLImageHelper

+ (UIImage *)imageWithName:(NSString *)name {
    int scale = (int)UIScreen.mainScreen.scale;
    scale = MIN(MAX(scale, 2), 3);
    NSString *imageName = [NSString stringWithFormat:@"%@@%dx", name, scale];
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:imageName ofType:@"png"];
    return [[UIImage imageWithContentsOfFile:path] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


@end
