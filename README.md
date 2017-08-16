# 使用AVPlayer自定义支持全屏的播放器

# 功能
    本视频播放器主要自定义了带缓冲显示的进度条，可以拖动调节视频播放进度的播放条，具有当前播放时间和总时间的Label，全屏播放功能，定时消失的工具条，视频卡顿监听，视频加载失败处理。支持旋转屏幕自动全屏，可以添加到UItableView上。使用Masonry布局，工具条单独封装出来，方便大家修改。
# 接口与用法
+ 接口

```
/**重复播放，默认No*/
@property (nonatomic, assign) BOOL           repeatPlay;
/**是否支持横屏,默认NO*/
@property (nonatomic, assign) BOOL           isLandscape;
/**全屏是否隐藏状态栏，默认YES*/
@property (nonatomic, assign) BOOL           fullStatusBarHidden;
/** 静音（默认为NO）*/
@property (nonatomic, assign) BOOL           mute;
/**是否是全屏*/
@property (nonatomic, assign, readonly) BOOL isFullScreen;
/**拉伸方式，默认全屏填充*/
@property (nonatomic, assign) VideoFillMode  fillMode;
/**视频url*/
@property (nonatomic, strong) NSURL          *url;
/**进度条背景颜色*/
@property (nonatomic, strong) UIColor        *progressBackgroundColor;
/**缓冲条缓冲进度颜色*/
@property (nonatomic, strong) UIColor        *progressBufferColor;
/**进度条播放完成颜色*/
@property (nonatomic, strong) UIColor        *progressPlayFinishColor;
/**转子线条颜色*/
@property (nonatomic, strong) UIColor        *strokeColor;

/**播放*/
- (void)playVideo;
/**暂停*/
- (void)pausePlay;
/**返回按钮回调方法*/
- (void)backButton:(BackButtonBlock) backButton;
/**播放完成回调*/
- (void)endPlay:(EndBolck) end;
/**销毁播放器*/
- (void)destroyPlayer;

```

+ 使用方法

      直接使用cocoapods导入，`pod 'CLPlayer'`

+ TableView使用方法

```
#pragma mark - 点击播放代理
- (void)cl_tableViewCellPlayVideoWithCell:(CLTableViewCell *)cell{
    //记录被点击的Cell
    _cell = cell;
    //销毁播放器
    [_playerView destroyPlayer];
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, cell.CLwidth, cell.CLheight)];
    _playerView = playerView;
    [cell.contentView addSubview:_playerView];
    //视频地址
    _playerView.url = [NSURL URLWithString:cell.model.videoUrl];
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
        _cell = nil;
        NSLog(@"播放完成");
    }];
}

```
    在`tableView`滑动代理中，需要在`- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath`方法中判断当前cell时候滑出，滑出后需要销毁播放器。

```
//cell离开tableView时调用
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //因为复用，同一个cell可能会走多次
    if ([_cell isEqual:cell]) {
        //区分是否是播放器所在cell,销毁时将指针置空
        [_playerView destroyPlayer];
        _cell = nil;
    }
}
```
# 播放器效果图

![](https://github.com/JmoVxia/CLPlayer/blob/master/%E6%95%88%E6%9E%9C%E5%9B%BE1.gif)




# 详细请看简书

http://www.jianshu.com/p/f9240b8a6e90
