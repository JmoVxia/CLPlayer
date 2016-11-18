//
//  ViewController.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "ViewController.h"
#import "CLPlayerView.h"
#import "UIView+CLSetRect.h"
#import "TableViewCell.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,VideoDelegate>

/**tableView*/
@property (nonatomic,strong) UITableView *tableView;

/**CLplayer*/
@property (nonatomic,strong) CLPlayerView *playerView;




@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Index = @"Cell";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Index];
    if (!cell)
    {
        cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Index];
    }
    cell.videoDelegate = self;
    cell.url = @"http://wvideo.spriteapp.cn/video/2016/0215/56c1809735217_wpd.mp4";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

- (void)PlayVideoWithCell:(TableViewCell *)cell;
{
    [_playerView destroyPlayer];
//    _playerView = nil;
    
    _playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, cell.width, cell.height)];
    [cell addSubview:_playerView];
    //根据旋转自动支持全屏，默认支持
    //    playerView.autoFullScreen = NO;
    //重复播放，默认不播放
    //    playerView.repeatPlay     = YES;
    //如果播放器所在页面支持横屏，需要设置为Yes，不支持不需要设置(默认不支持)
    //    playerView.isLandscape    = YES;
    
    //视频地址
    _playerView.url = [NSURL URLWithString:cell.url];
    
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
 
}

@end
