# 使用AVPlayer自定义支持全屏的播放器

#功能
    本视频播放器主要自定义了带缓冲显示的进度条，可以拖动调节视频播放进度的播放条，具有当前播放时间和总时间的Label，全屏播放功能，定时消失的工具条。支持旋转屏幕自动全屏，可以添加到UItableView上。

#接口与用法
+ 接口

```
/**视频url*/
@property (nonatomic,strong) NSURL *url;
/**旋转自动全屏，默认Yes*/
@property (nonatomic,assign) BOOL autoFullScreen;
/**重复播放，默认No*/
@property (nonatomic,assign) BOOL repeatPlay;
/**是否支持横屏，默认No*/
@property (nonatomic,assign) BOOL isLandscape;
/**播放*/
- (void)playVideo;
/**暂停*/
- (void)pausePlay;
/**返回按钮回调方法*/
- (void)backButton:(BackButtonBlock) backButton;
/**播放完成回调*/
- (void)endPlay:(EndBolck) end;

```

+ 使用方法

      直接使用cocoapods导入，`pod 'CLPlayer', '~> 1.0.0'`

+ 具体使用代码

```
PlayerView *playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 90, ScreenWidth, 300)];
[self.view addSubview:playerView];
//根据旋转自动支持全屏，默认支持
//    playerView.autoFullScreen = NO;
//重复播放，默认不播放
//    playerView.repeatPlay     = YES;
//如果播放器所在页面支持横屏，需要设置为Yes，不支持不需要设置(默认不支持)
//    playerView.isLandscape    = YES;

//视频地址
playerView.url = [NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0215/56c1809735217_wpd.mp4"];

//播放
[playerView playVideo];

//返回按钮点击事件回调
[playerView backButton:^(UIButton *button) {
NSLog(@"返回按钮被点击");
}];

//播放完成回调
[playerView endPlay:^{
NSLog(@"播放完成");
}];


```
#播放器效果图

![](http://upload-images.jianshu.io/upload_images/1979970-6bf88743bcaf8ff4.gif?imageMogr2/auto-orient/strip)

#详细请看简书

http://www.jianshu.com/p/b9659492d064
