//
//  CLViewController3.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLViewController3.h"
#import "UIView+CLSetRect.h"
@interface CLViewController3 ()


@end

@implementation CLViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"presentViewController";
    
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 90, self.view.CLwidth, 300)];
    
    _playerView = playerView;
    [self.view addSubview:_playerView];
    
    //根据旋转自动支持全屏，默认支持
    //        _playerView.autoFullScreen = NO;
    //重复播放，默认不播放
    //    _playerView.repeatPlay     = YES;
    //设置等比例全屏拉伸，多余部分会被剪切
    //    _playerView.fillMode = ResizeAspectFill;
    //设置进度条背景颜色
    //    _playerView.progressBackgroundColor = [UIColor purpleColor];
    //    //设置进度条缓冲颜色
    //    _playerView.progressBufferColor = [UIColor redColor];
    //    //设置进度条播放完成颜色
    //    _playerView.progressPlayFinishColor = [UIColor greenColor];
    //全屏是否隐藏状态栏
    //    _playerView.fullStatusBarHidden = NO;
    //视频地址
    _playerView.url = [NSURL URLWithString:@"http://dvideo.spriteapp.cn/video/2016/1117/582db0698584d_wpd.mp4"];
    //播放
    [_playerView playVideo];
    
    //返回按钮点击事件回调
    [_playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    //播放完成回调
    [_playerView endPlay:^{
        //销毁播放器
        [_playerView destroyPlayer];
        _playerView = nil;
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
    _playerView = nil;
}


@end
