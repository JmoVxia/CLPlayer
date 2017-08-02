//
//  CLViewController1.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLViewController1.h"

@interface CLViewController1 ()
/**imageView*/
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation CLViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"本页面支持多个方向";
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rotation"]];
    _imageView.center = self.view.center;
    [self.view addSubview:_imageView];
}
-(void)viewDidLayoutSubviews{
    _imageView.center = self.view.center;
}
#pragma mark -- 需要设置全局支持旋转方向，然后重写下面三个方法可以让当前页面支持多个方向
// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return YES;
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
