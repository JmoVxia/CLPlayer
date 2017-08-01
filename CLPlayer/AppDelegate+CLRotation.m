//
//  AppDelegate+CLRotation.m
//  CLControllerRotationToolsDemo
//
//  Created by JmoVxia on 2017/6/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "AppDelegate+CLRotation.h"

@implementation AppDelegate (CLRotation)

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    //获取方向数组
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePath];
    NSArray *InterfaceOrientationArray = [dict objectForKey:@"UISupportedInterfaceOrientations"];
    
    __block BOOL portrait = NO;
    __block BOOL landscapeLeft = NO;
    __block BOOL landscapeRight = NO;
    __block BOOL portraitUpsideDown = NO;
    [InterfaceOrientationArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"UIInterfaceOrientationPortrait"]) {
            //上
            portrait = YES;
        }else if ([obj isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]){
            //左
            landscapeLeft = YES;
        }else if ([obj isEqualToString:@"UIInterfaceOrientationLandscapeRight"]){
            //右
            landscapeRight = YES;
        }else if ([obj isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]){
            //下
            portraitUpsideDown = YES;
        }
    }];
    UIInterfaceOrientationMask InterfaceOrientation = UIInterfaceOrientationMaskAll;
    if (portrait && landscapeLeft && landscapeRight && portraitUpsideDown) {
        //全部
        InterfaceOrientation = UIInterfaceOrientationMaskAll;
    }else if (portrait && landscapeLeft && landscapeRight && !portraitUpsideDown){
        //上左右
        InterfaceOrientation = UIInterfaceOrientationMaskAllButUpsideDown;
    }else if (!portrait && landscapeLeft && landscapeRight && !portraitUpsideDown){
        //左右
        InterfaceOrientation = UIInterfaceOrientationMaskLandscape;
    }else if (portrait && !landscapeLeft && !landscapeRight && !portraitUpsideDown){
        //上
        InterfaceOrientation = UIInterfaceOrientationMaskPortrait;
    }else if (!portrait && landscapeLeft && !landscapeRight && !portraitUpsideDown){
        //左
        InterfaceOrientation = UIInterfaceOrientationMaskLandscapeLeft;
    }else if (!portrait && !landscapeLeft && landscapeRight && !portraitUpsideDown){
        //右
        InterfaceOrientation = UIInterfaceOrientationMaskLandscapeRight;
    }else if(!portrait && !landscapeLeft && !landscapeRight && portraitUpsideDown){
        //下
        InterfaceOrientation = UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return InterfaceOrientation;
}











@end
