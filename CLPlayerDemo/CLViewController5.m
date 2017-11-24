//
//  CLViewController5.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLViewController5.h"
#import "CLPlayerView.h"
#import "UIView+CLSetRect.h"
@interface CLViewController5 ()
/**CLplayer*/
@property (nonatomic,weak) CLPlayerView *playerView;

@end

@implementation CLViewController5

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"presentViewController";
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 90, self.view.CLwidth, 300)];
    _playerView = playerView;
    [self.view addSubview:_playerView];
    
//    //重复播放，默认不播放
//    _playerView.repeatPlay = YES;
//    //当前控制器是否支持旋转，当前页面支持旋转的时候需要设置，告知播放器
    _playerView.isLandscape = YES;
//    //设置等比例全屏拉伸，多余部分会被剪切
//    _playerView.fillMode = ResizeAspectFill;
//    //设置进度条背景颜色
//    _playerView.progressBackgroundColor = [UIColor purpleColor];
//    //设置进度条缓冲颜色
//    _playerView.progressBufferColor = [UIColor redColor];
//    //设置进度条播放完成颜色
//    _playerView.progressPlayFinishColor = [UIColor greenColor];
//    //全屏是否隐藏状态栏
//    _playerView.fullStatusBarHidden = NO;
//    //转子颜色
//    _playerView.strokeColor = [UIColor redColor];
//    //工具条消失时间，默认10s
//    _playerView.toolBarDisappearTime = 15;
    //视频地址
    _playerView.url = [NSURL URLWithString:@"http://dvideo.spriteapp.cn/video/2017/0830/b0e248268d4b11e79e13842b2b4c75ab_wpd.mp4"];
    //播放
    [_playerView playVideo];
    //返回按钮点击事件回调,小屏状态才会调用，全屏默认变为小屏
    [_playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    //播放完成回调
    [_playerView endPlay:^{
        //销毁播放器
        [_playerView destroyPlayer];
        NSLog(@"播放完成");
    }];
    
    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(0, 450, 90, 90)];
    [but setTitle:@"退出" forState:UIControlStateNormal];
    but.backgroundColor = [UIColor lightGrayColor];
    but.CLcenterX = self.view.CLcenterX;
    [but addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
}
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [_playerView destroyPlayer];
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
