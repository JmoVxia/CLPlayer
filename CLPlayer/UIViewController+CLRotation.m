//
//  UIViewController+CLRotation.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/1.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "UIViewController+CLRotation.h"
#import <objc/message.h>
#import "AppDelegate.h"

@implementation UIViewController (CLRotation)

- (void)isNeedRotation:(BOOL)needRotation{
    __weak typeof(UIViewController *) weakVC = self;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    IMP originalIMP = method_getImplementation(class_getInstanceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:)));
    IMP newIMP = imp_implementationWithBlock(^(id obj, UIApplication *application, UIWindow *window){
        if (!weakVC) {
            class_replaceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:), originalIMP, method_getTypeEncoding(class_getInstanceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:))));
        }
        return needRotation ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    });
    class_replaceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:), newIMP, method_getTypeEncoding(class_getInstanceMethod([appDelegate class], @selector(application:supportedInterfaceOrientationsForWindow:))));
}


@end
