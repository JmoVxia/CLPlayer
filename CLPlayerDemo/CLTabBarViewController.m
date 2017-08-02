//
//  CLTabBarViewController.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLTabBarViewController.h"
#import "CLTableViewViewController.h"
#import "CLViewController.h"

@interface CLTabBarViewController ()

@end

@implementation CLTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addOneChildVC:[CLViewController new] title:@"View" imageName:@"search" selImageName:@"nosearch"];
    [self addOneChildVC:[CLTableViewViewController new] title:@"TableView" imageName:@"personal" selImageName:@"nopersonal"];
    self.selectedIndex = 0;

}
/**
 *  添加自控制器
 *
 *  @param chilidVC     自控制器
 *  @param title        标题
 *  @param imageName    正常图片
 *  @param selImageName 被选中图片
 */
-(void)addOneChildVC:(UIViewController*)chilidVC title:(NSString*)title imageName:(NSString*)imageName selImageName:(NSString*)selImageName{
    //设置标题
    chilidVC.title = title;
    //设置正常文字颜色
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    dictM[NSForegroundColorAttributeName] = [UIColor blackColor];
    [chilidVC.tabBarItem setTitleTextAttributes:dictM forState:(UIControlStateNormal)];
    //设置被选中文字颜色
    NSMutableDictionary *seldictM = [NSMutableDictionary dictionary];
    seldictM[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    seldictM[NSForegroundColorAttributeName] = [UIColor blackColor];
    [chilidVC.tabBarItem setTitleTextAttributes:seldictM forState:(UIControlStateSelected)];
    //设置正常图片
    chilidVC.tabBarItem.image = [[UIImage imageNamed:imageName]imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    //被选中的图片
    UIImage *selImage = [[UIImage imageNamed:selImageName]imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    chilidVC.tabBarItem.selectedImage = selImage;
    //添加导航控制器
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:chilidVC];
    [self addChildViewController:navVC];
}





@end
