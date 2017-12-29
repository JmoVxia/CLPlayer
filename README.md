# 使用AVPlayer自定义支持全屏的播放器

# 功能
    本视频播放器主要自定义了带缓冲显示的进度条，可以拖动调节视频播放进度的播放条，具有当前播放时间和总时间的Label，全屏播放功能，定时消失的工具条，视频卡顿监听，视频加载失败处理，手势可以控制进度、声音、亮度。支持旋转屏幕自动全屏，可以添加到UItableView上。使用Masonry布局，工具条单独封装出来，方便大家修改。
# 接口与用法
+ 接口

```
/**重复播放,默认No*/
@property (nonatomic, assign) BOOL                    repeatPlay;
/**当前页面是否支持横屏,默认NO*/
@property (nonatomic, assign) BOOL                    isLandscape;
/**自动旋转，默认Yes*/
@property (nonatomic, assign) BOOL                    autoRotate;
/**静音,默认为NO*/
@property (nonatomic, assign) BOOL                    mute;
/**小屏手势控制,默认NO*/
@property (nonatomic, assign) BOOL                    smallGestureControl;
/**全屏手势控制,默认Yes*/
@property (nonatomic, assign) BOOL                    fullGestureControl;;
/**是否是全屏*/
@property (nonatomic, assign, readonly) BOOL          isFullScreen;
/**工具条消失时间，默认10s*/
@property (nonatomic, assign) NSInteger               toolBarDisappearTime;
/**拉伸方式，默认全屏填充*/
@property (nonatomic, assign) VideoFillMode           videoFillMode;
/**顶部工具条隐藏方式，默认不隐藏*/
@property (nonatomic, assign) TopToolBarHiddenType    topToolBarHiddenType;
/**全屏状态栏隐藏方式，默认不隐藏*/
@property (nonatomic, assign) FullStatusBarHiddenType fullStatusBarHiddenType;
/**视频url*/
@property (nonatomic, strong) NSURL                   *url;
/**进度条背景颜色*/
@property (nonatomic, strong) UIColor                 *progressBackgroundColor;
/**缓冲条缓冲进度颜色*/
@property (nonatomic, strong) UIColor                 *progressBufferColor;
/**进度条播放完成颜色*/
@property (nonatomic, strong) UIColor                 *progressPlayFinishColor;
/**转子线条颜色*/
@property (nonatomic, strong) UIColor                 *strokeColor;

/**播放*/
- (void)playVideo;
/**暂停*/
- (void)pausePlay;
/**返回按钮回调方法，只有小屏会调用，全屏点击默认回到小屏*/
- (void)backButton:(BackButtonBlock) backButton;
/**播放完成回调*/
- (void)endPlay:(EndBolck) end;
/**销毁播放器*/
- (void)destroyPlayer;

```

+ 使用方法
     
      cocoapods导入，`pod 'CLPlayer'`

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

![](https://github.com/JmoVxia/CLPlayer/blob/master/%E6%95%88%E6%9E%9C%E5%9B%BE.gif)




# 详细请看简书

http://www.jianshu.com/p/f9240b8a6e90
