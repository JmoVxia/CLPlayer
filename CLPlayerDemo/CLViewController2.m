//
//  CLViewController2.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLViewController2.h"
#import "CLPlayerView.h"
#import "UIView+CLSetRect.h"
@interface CLViewController2 ()
/**CLplayer*/
@property (nonatomic,weak) CLPlayerView *playerView;
@end

@implementation CLViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"pushViewController";
    
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 90, self.view.CLwidth, 300)];
    
    _playerView = playerView;
    [self.view addSubview:_playerView];
    
//    //重复播放，默认不播放
//    _playerView.repeatPlay = YES;
//    //当前控制器是否支持旋转，当前页面支持旋转的时候需要设置，告知播放器
//    _playerView.isLandscape = YES;
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
//    //是否静音，默认NO
//    _playerView.mute = YES;
//    //转子颜色
//    _playerView.strokeColor = [UIColor redColor];
    //视频地址
    _playerView.url = [NSURL URLWithString:@"http://baobab.wdjcdn.com/14587093851044544c.mp4"];
    //播放
    [_playerView playVideo];
    //返回按钮点击事件回调
    [_playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
        //查询是否是全屏状态
        NSLog(@"%d",_playerView.isFullScreen);
    }];
    //播放完成回调
    [_playerView endPlay:^{
        //销毁播放器
//        [_playerView destroyPlayer];
//        _playerView = nil;
        NSLog(@"播放完成");
    }];

    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(0, 450, 90, 90)];
    [but setTitle:@"切换视频" forState:UIControlStateNormal];
    but.backgroundColor = [UIColor lightGrayColor];
    but.CLcenterX = self.view.CLcenterX;
    [but addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
}
- (void)next{
    _playerView.url = [NSURL URLWithString:@"http://baobab.wdjcdn.com/1458715233692shouwang_x264.mp4"];
    [_playerView playVideo];
}
-(void)viewDidDisappear:(BOOL)animated{
    [_playerView destroyPlayer];
    _playerView = nil;
}







@end
