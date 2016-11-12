//
//  ViewController.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "ViewController.h"
#import "PlayerView.h"
#import "UIView+SetRect.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    PlayerView *playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 90, ScreenWidth, 300)];
    //视频地址
    playerView.url         = [NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0215/56c1809735217_wpd.mp4"];
    [self.view addSubview:playerView];
    
    //播放
    [playerView playVideo];
    
    //根据旋转自动支持全屏，默认不支持
    playerView.autoFullScreen = YES;
    
    //重复播放，默认不播放
    playerView.repeatPlay = YES;
    
    //返回按钮点击事件回调
    [playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    
    //播放完成回调
    [playerView endPlay:^{
        NSLog(@"播放完成");
    }];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
