//
//  CLNavigationViewController.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/3.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLNavigationViewController.h"

@interface CLNavigationViewController ()

@end

@implementation CLNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 重写自定义的UINavigationController中的push方法
// 处理tabbar的显示隐藏
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count==1) {
        viewController.hidesBottomBarWhenPushed = YES; //viewController是将要被push的控制器
    }
    [super pushViewController:viewController animated:animated];
}
@end
