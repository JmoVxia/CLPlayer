//
//  PlayerView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "CLPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CLPlayerMaskView.h"
#import "CLGCDTimerManager.h"

// 播放器的几种状态
typedef NS_ENUM(NSInteger, CLPlayerState) {
    CLPlayerStateFailed,     ///< 播放失败
    CLPlayerStateBuffering,  ///< 缓冲中
    CLPlayerStatePlaying,    ///< 播放中
    CLPlayerStateStopped,    ///< 停止播放
};
// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, CLPanDirection){
    CLPanDirectionHorizontalMoved, ///< 横向移动
    CLPanDirectionVerticalMoved,   ///< 纵向移动
};

@implementation CLPlayerViewConfig


+ (instancetype)defaultConfig {
    CLPlayerViewConfig *config = [[CLPlayerViewConfig alloc] init];
    config.repeatPlay              = NO;
    config.mute                    = NO;
    config.isLandscape             = NO;
    config.smallGestureControl     = NO;
    config.autoRotate              = YES;
    config.fullGestureControl      = YES;
    config.backPlay                = YES;
    config.progressBackgroundColor = [UIColor colorWithRed:0.54118
                                               green:0.51373
                                                blue:0.50980
                                               alpha:1.00000];
    config.progressPlayFinishColor = [UIColor whiteColor];
    config.progressBufferColor     = [UIColor colorWithRed:0.84118
                                               green:0.81373
                                                blue:0.80980
                                               alpha:1.00000];
    config.videoFillMode           = VideoFillModeResize;
    config.topToolBarHiddenType    = TopToolBarHiddenNever;
    config.fullStatusBarHiddenType = FullStatusBarHiddenNever;
    config.toolBarDisappearTime    = 10;
    return config;
}

@end



@interface CLPlayerView ()<CLPlayerMaskViewDelegate,UIGestureRecognizerDelegate>

/** 播发器的几种状态 */
@property (nonatomic, assign) CLPlayerState    state;
/**控件原始Farme*/
@property (nonatomic, assign) CGRect           customFarme;
/**父类控件*/
@property (nonatomic, strong) UIView           *fatherView;
/**视频拉伸模式*/
@property (nonatomic, copy) NSString           *fillMode;
/**状态栏*/
@property (nonatomic, strong) UIView           *statusBar;
/**是否是全屏*/
@property (nonatomic, assign) BOOL             isFullScreen;
/**工具条隐藏标记*/
@property (nonatomic, assign) BOOL             isDisappear;
/**用户点击播放标记*/
@property (nonatomic, assign) BOOL             isUserPlay;
/**记录控制器状态栏状态*/
@property (nonatomic, assign) BOOL             statusBarHiddenState;
/**点击最大化标记*/
@property (nonatomic, assign) BOOL             isUserTapMaxButton;
/**播放完成标记*/
@property (nonatomic, assign) BOOL             isEnd;
/**播放器*/
@property (nonatomic, strong) AVPlayer         *player;
/**playerLayer*/
@property (nonatomic, strong) AVPlayerLayer    *playerLayer;
/**播放器item*/
@property (nonatomic, strong) AVPlayerItem     *playerItem;
/**遮罩*/
@property (nonatomic, strong) CLPlayerMaskView *maskView;
/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat          sumTime;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) CLPanDirection   panDirection;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL             isVolume;
/** 是否正在拖拽 */
@property (nonatomic, assign) BOOL             isDragged;
/**缓冲判断*/
@property (nonatomic, assign) BOOL             isBuffering;
/**音量滑杆*/
@property (nonatomic, strong) UISlider         *volumeViewSlider;
/*进度条定时器*/
@property (nonatomic, strong) CLGCDTimer       *sliderTimer;
/*点击定时器*/
@property (nonatomic, strong) CLGCDTimer       *tapTimer;
/*配置*/
@property (nonatomic, strong) CLPlayerViewConfig *config;

/**返回按钮回调*/
@property (nonatomic, copy) void (^BackBlock) (UIButton *backButton);
/**播放完成回调*/
@property (nonatomic, copy) void (^EndBlock) (void);

@end

@implementation CLPlayerView

//MARK:JmoVxia---更新配置
- (void)updateWithConfig:(void(^)(CLPlayerViewConfig *config))configBlock {
    if (configBlock) {
        configBlock(self.config);
    }
    switch (self.config.videoFillMode){
        case VideoFillModeResize:
            //拉伸视频内容达到边框占满，但不按原比例拉伸
            _fillMode = AVLayerVideoGravityResize;
            break;
        case VideoFillModeResizeAspect:
            //按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
            _fillMode = AVLayerVideoGravityResizeAspect;
            break;
        case VideoFillModeResizeAspectFill:
            //原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分会被剪切
            _fillMode = AVLayerVideoGravityResizeAspectFill;
            break;
    }
    self.maskView.progressBackgroundColor = self.config.progressBackgroundColor;
    self.maskView.progressBufferColor     = self.config.progressBufferColor;
    self.maskView.progressPlayFinishColor = self.config.progressPlayFinishColor;
    self.maskView.loadingView.strokeColor = self.config.strokeColor;
    self.player.muted                     = self.config.mute;
    [self resetToolBarDisappearTime];
    [self resetTopToolBarHiddenType];
}

//MARK:JmoVxia---重置工具条时间
-(void)resetToolBarDisappearTime{
    [self destroyToolBarTimer];
    [self.tapTimer startTimer];
}
//MARK:JmoVxia---重置顶部工具条隐藏方式
-(void)resetTopToolBarHiddenType{
    switch (self.config.topToolBarHiddenType) {
        case TopToolBarHiddenNever:
            //不隐藏
            self.maskView.topToolBar.hidden = NO;
            break;
        case TopToolBarHiddenAlways:
            //小屏和全屏都隐藏
            self.maskView.topToolBar.hidden = YES;
            break;
        case TopToolBarHiddenSmall:
            //小屏隐藏，全屏不隐藏
            self.maskView.topToolBar.hidden = !self.isFullScreen;
            break;
    }
}
//MARK:JmoVxia---播放地址
- (void)setUrl:(NSURL *)url{
    [self resetPlayer];
    _url                      = url;
    self.playerItem           = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:_url]];
    //创建
    _player                   = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer              = [AVPlayerLayer playerLayerWithPlayer:_player];
    //全屏拉伸
    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    //设置静音模式播放声音
    AVAudioSession * session  = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    _playerLayer.videoGravity = _fillMode;
    //放到最下面，防止遮挡
    [self.layer insertSublayer:_playerLayer atIndex:0];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
-(void)setPlayerItem:(AVPlayerItem *)playerItem{
    if (_playerItem == playerItem){
        return;
    }
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        //重置播放器
        [self resetPlayer];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
        [playerItem addObserver:self
                     forKeyPath:@"status"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        [playerItem addObserver:self
                     forKeyPath:@"loadedTimeRanges"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        [playerItem addObserver:self
                     forKeyPath:@"playbackBufferEmpty"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
    }
}
- (void)setState:(CLPlayerState)state{
    if (_state == state) {
        return;
    }
    _state = state;
    if (state == CLPlayerStateBuffering) {
        [self.maskView.loadingView starAnimation];
    }else if (state == CLPlayerStateFailed){
        [self.maskView.loadingView stopAnimation];
        self.maskView.failButton.hidden   = NO;
        self.maskView.playButton.selected = NO;
#ifdef DEBUG
        NSLog(@"加载失败");
#endif
    }else{
        [self.maskView.loadingView stopAnimation];
        if (_isUserPlay) {
            [self playVideo];
        }
    }
}
//MARK:JmoVxia---隐藏或者显示状态栏方法
- (void)setStatusBarHidden:(BOOL)hidden{
    //设置是否隐藏
    self.statusBar.hidden = hidden;
}
//MARK:JmoVxia---初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        //初始值
        _isFullScreen            = NO;
        _isDisappear             = NO;
        _isUserTapMaxButton      = NO;
        _isEnd                   = NO;
        _isUserPlay              = YES;
        _statusBarHiddenState    = self.statusBar.isHidden;
        //开启
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        //注册屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
        //APP运行状态通知，将要被挂起
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        // app进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterPlayground:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [self creatUI];
    }
    return self;
}
//MARK:JmoVxia---创建播放器UI
- (void)creatUI{
    self.backgroundColor = [UIColor blackColor];
    // 获取系统音量
    [self configureVolume];
    //最上面的View
    [self addSubview:self.maskView];
}
//MARK:JmoVxia---监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            // 加载完成后，再添加平移手势
            // 添加平移手势，用来控制音量、亮度、快进快退
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
            panRecognizer.delegate                = self;
            [panRecognizer setMaximumNumberOfTouches:1];
            [panRecognizer setDelaysTouchesBegan:YES];
            [panRecognizer setDelaysTouchesEnded:YES];
            [panRecognizer setCancelsTouchesInView:YES];
            [self.maskView addGestureRecognizer:panRecognizer];
            self.player.muted = self.config.mute;
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
            self.state = CLPlayerStateFailed;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = self.playerItem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        [self.maskView.progress setProgress:timeInterval / totalDuration animated:NO];
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        // 当缓冲是空的时候
        if (self.playerItem.isPlaybackBufferEmpty) {
            [self bufferingSomeSecond];
        }
    }
}
//MARK:JmoVxia---UIPanGestureRecognizer手势方法
- (void)panDirection:(UIPanGestureRecognizer *)pan {
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint  = [pan velocityInView:self];
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                [self cl_progressSliderTouchBegan:nil];
                //显示遮罩
                [UIView animateWithDuration:0.5 animations:^{
                    self.maskView.topToolBar.alpha    = 1.0;
                    self.maskView.bottomToolBar.alpha = 1.0;
                }];
                if (self.config.fullStatusBarHiddenType == FullStatusBarHiddenFollowToolBar && _isFullScreen) {
                    [self setStatusBarHidden:NO];
                }
                // 取消隐藏
                self.panDirection = CLPanDirectionHorizontalMoved;
                // 给sumTime初值
                CMTime time       = self.player.currentTime;
                self.sumTime      = time.value/time.timescale;
            }
            else if (x < y){ // 垂直移动
                self.panDirection = CLPanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case CLPanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case CLPanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case CLPanDirectionHorizontalMoved:{
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    [self cl_progressSliderTouchEnded:nil];
                    break;
                }
                case CLPanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
//MARK:JmoVxia---滑动调节音量和亮度
- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}
//MARK:JmoVxia---水平移动调节进度
- (void)horizontalMoved:(CGFloat)value {
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    // 需要限定sumTime的范围
    CMTime totalTime           = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration){
        self.sumTime = totalMovieDuration;
    }
    if (self.sumTime < 0) {
        self.sumTime = 0;
    }
    BOOL style = false;
    if (value > 0) {
        style = YES;
    }
    if (value < 0) {
        style = NO;
    }
    if (value == 0) {
        return;
    }
    self.isDragged             = YES;
    //计算出拖动的当前秒数
    CGFloat dragedSeconds      = self.sumTime;
    //滑杆进度
    CGFloat sliderValue        = dragedSeconds / totalMovieDuration;
    //设置滑杆
    self.maskView.slider.value = sliderValue;
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime        = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    NSInteger proMin                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
    NSInteger proSec                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
    self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)proMin, (long)proSec];
}
//MARK:JmoVxia---手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ((!self.config.smallGestureControl && !_isFullScreen) || (!self.config.fullGestureControl && _isFullScreen)) {
        return NO;
    }
    if ([touch.view isDescendantOfView:self.maskView.bottomToolBar]) {
        return NO;
    }
    return YES;
}
//MARK:JmoVxia---获取系统音量
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider        = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}
//MARK:JmoVxia---缓冲较差时候
//卡顿缓冲几秒
- (void)bufferingSomeSecond{
    self.state   = CLPlayerStateBuffering;
    _isBuffering = NO;
    if (_isBuffering){
        return;
    }
    _isBuffering = YES;
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self pausePlay];
    //延迟执行
    [self performSelector:@selector(bufferingSomeSecondEnd)
               withObject:@"Buffering"
               afterDelay:5];
}
//卡顿缓冲结束
- (void)bufferingSomeSecondEnd{
    [self playVideo];
    // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
    _isBuffering = NO;
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingSomeSecond];
    }
}
//计算缓冲进度
- (NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
//MARK:JmoVxia---拖动进度条
//开始
-(void)cl_progressSliderTouchBegan:(CLSlider *)slider{
    //暂停
    [self pausePlay];
    //销毁定时消失工具条定时器
    [self destroyToolBarTimer];
}
//结束
-(void)cl_progressSliderTouchEnded:(CLSlider *)slider{
    if (slider.value != 1) {
        _isEnd = NO;
    }
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingSomeSecond];
    }else{
        //继续播放
        [self playVideo];
    }
    //重新添加工具条定时消失定时器
    [self resetToolBarDisappearTime];
}
//拖拽中
-(void)cl_progressSliderValueChanged:(CLSlider *)slider{
    //计算出拖动的当前秒数
    CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    CGFloat dragedSeconds   = total * slider.value;
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    NSInteger proMin                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
    NSInteger proSec                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
    self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)proMin, (long)proSec];
}
//MARK:JmoVxia---计时器事件
- (void)timeStack{
    if (_playerItem.duration.timescale != 0){
        //设置进度条
        self.maskView.slider.maximumValue   = 1;
        self.maskView.slider.value          = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);
        //判断是否真正的在播放
        if (self.playerItem.isPlaybackLikelyToKeepUp && self.maskView.slider.value > 0) {
            self.state = CLPlayerStatePlaying;
        }
        //当前时长
        NSInteger proMin                    = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec                    = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)proMin, (long)proSec];
        //总时长
        NSInteger durMin                    = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总分钟
        NSInteger durSec                    = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总秒
        self.maskView.totalTimeLabel.text   = [NSString stringWithFormat:@"%02ld:%02ld", (long)durMin, (long)durSec];
    }
}
//MARK:JmoVxia---播放暂停按钮方法
-(void)cl_playButtonAction:(UIButton *)button{
    if (!button.selected){
        _isUserPlay = NO;
        [self pausePlay];
    }else{
        _isUserPlay = YES;
        [self playVideo];
    }
    //重新添加工具条定时消失定时器
    [self resetToolBarDisappearTime];
}
//MARK:JmoVxia---全屏按钮响应事件
-(void)cl_fullButtonAction:(UIButton *)button{
    if (!_isFullScreen){
        _isUserTapMaxButton = YES;
        [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
    }else{
        [self originalscreen];
    }
    //重新添加工具条定时消失定时器
    [self resetToolBarDisappearTime];
}
//MARK:JmoVxia---播放失败按钮点击事件
-(void)cl_failButtonAction:(UIButton *)button{
    [self setUrl:_url];
    [self playVideo];
}
//MARK:JmoVxia---点击响应
- (void)disappearAction:(UIButton *)button{
    //取消定时消失
    [self destroyToolBarTimer];
    if (!_isDisappear){
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topToolBar.alpha    = 0;
            self.maskView.bottomToolBar.alpha = 0;
        }];
    }else{
        //重新添加工具条定时消失定时器
        [self resetToolBarDisappearTime];
        //重置定时消失
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topToolBar.alpha    = 1.0;
            self.maskView.bottomToolBar.alpha = 1.0;
        }];
    }
    if (self.config.fullStatusBarHiddenType == FullStatusBarHiddenFollowToolBar && _isFullScreen) {
        [self setStatusBarHidden:!_isDisappear];
    }
    _isDisappear = !_isDisappear;
}
//MARK:JmoVxia---定时消失
- (void)disappear{
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.topToolBar.alpha    = 0;
        self.maskView.bottomToolBar.alpha = 0;
    }];
    if (self.config.fullStatusBarHiddenType == FullStatusBarHiddenFollowToolBar && _isFullScreen) {
        [self setStatusBarHidden:YES];
    }
    _isDisappear = YES;
}
//MARK:JmoVxia---播放完成
- (void)moviePlayDidEnd:(id)sender{
    _isEnd = YES;
    if (!self.config.repeatPlay){
        [self pausePlay];
    }else{
        [self resetPlay];
    }
    if (self.EndBlock){
        self.EndBlock();
    }
}
- (void)endPlay:(EndBolck) end{
    self.EndBlock = end;
}
//MARK:JmoVxia---返回按钮
-(void)cl_backButtonAction:(UIButton *)button{
    if (_isFullScreen) {
        [self originalscreen];
    }else{
        if (self.BackBlock){
            self.BackBlock(button);
        }
    }
    //重新添加工具条定时消失定时器
    [self resetToolBarDisappearTime];
}
- (void)backButton:(BackButtonBlock) backButton;{
    self.BackBlock = backButton;
}
//MARK:JmoVxia---暂停播放
- (void)pausePlay{
    self.maskView.playButton.selected = NO;
    [_player pause];
    [self.sliderTimer suspendTimer];
}
//MARK:JmoVxia---播放
- (void)playVideo{
    self.maskView.playButton.selected = YES;
    if (_isEnd && self.maskView.slider.value == 1) {
        [self resetPlay];
    }else{
        [_player play];
        [self.sliderTimer resumeTimer];
    }
}
//MARK:JmoVxia---重新开始播放
- (void)resetPlay{
    _isEnd = NO;
    [_player seekToTime:CMTimeMake(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self playVideo];
}
//MARK:JmoVxia---销毁播放器
- (void)destroyPlayer{
    [self pausePlay];
    //销毁定时器
    [self destroyAllTimer];
    //取消延迟执行的缓冲结束代码
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(bufferingSomeSecondEnd)
                                               object:@"Buffering"];
    //销毁转子动画
    [self.maskView.loadingView destroyAnimation];
    //移除
    [self.playerLayer removeFromSuperlayer];
    [self removeFromSuperview];
    self.maskView.loadingView = nil;
    self.playerLayer = nil;
    self.player      = nil;
    self.maskView    = nil;
}
//MARK:JmoVxia---重置播放器
- (void)resetPlayer{
    //重置状态
    self.state   = CLPlayerStateStopped;
    _isUserPlay  = YES;
    _isDisappear = NO;
    //移除之前的
    [self pausePlay];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer           = nil;
    self.player                = nil;
    //还原进度条和缓冲条
    self.maskView.slider.value = 0.0;
    [self.maskView.progress setProgress:0.0];
    //重置时间
    self.maskView.currentTimeLabel.text = @"00:00";
    self.maskView.totalTimeLabel.text   = @"00:00";
    [self.sliderTimer resumeTimer];
    //销毁定时消失工具条
    [self destroyToolBarTimer];
    //重置定时消失
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.topToolBar.alpha    = 1.0;
        self.maskView.bottomToolBar.alpha = 1.0;
    }];
    //重新添加工具条定时消失定时器
    [self resetToolBarDisappearTime];
    self.maskView.failButton.hidden = YES;
    //开始转子
    [self.maskView.loadingView starAnimation];
}
//MARK:JmoVxia---取消定时器
//销毁所有定时器
- (void)destroyAllTimer{
    [self.sliderTimer cancelTimer];
    [self.tapTimer cancelTimer];
    self.sliderTimer = nil;
    self.tapTimer    = nil;
}
//销毁定时消失定时器
- (void)destroyToolBarTimer{
    [self.tapTimer cancelTimer];
    self.tapTimer = nil;
}
//MARK:JmoVxia---屏幕旋转通知
- (void)orientChange:(NSNotification *)notification{
    if (self.config.autoRotate) {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeLeft){
            if (!_isFullScreen){
                if (self.config.isLandscape) {
                    //播放器所在控制器页面支持旋转情况下，和正常情况是相反的
                    [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
                }else{
                    [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
                }
            }
        }
        else if (orientation == UIDeviceOrientationLandscapeRight){
            if (!_isFullScreen){
                if (self.config.isLandscape) {
                    [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
                }else{
                    [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
                }
            }
        }
        else if (orientation == UIDeviceOrientationPortrait){
            if (_isFullScreen){
                [self originalscreen];
            }
        }
    }
}
//MARK:JmoVxia---全屏
- (void)fullScreenWithDirection:(UIInterfaceOrientation)direction{
    //记录播放器父类
    _fatherView               = self.superview;
    //记录原始大小
    _customFarme              = self.frame;
    _isFullScreen             = YES;
    [self resetTopToolBarHiddenType];
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    if (self.config.isLandscape){
        //手动点击需要旋转方向
        if (_isUserTapMaxButton) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        }
        [self hiddenStatusBarWithFullStatusBarHiddenType];
    }else{
        //播放器所在控制器不支持旋转，采用旋转view的方式实现
        [self setStatusBarHidden:YES];
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        if (direction == UIInterfaceOrientationLandscapeLeft){
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }completion:^(BOOL finished) {
                [self hiddenStatusBarWithFullStatusBarHiddenType];
            }];
        }else if (direction == UIInterfaceOrientationLandscapeRight) {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformMakeRotation( - M_PI / 2);
            }completion:^(BOOL finished) {
                [self hiddenStatusBarWithFullStatusBarHiddenType];
            }];
        }
    }
    self.maskView.fullButton.selected     = YES;
    self.frame                            = keyWindow.bounds;
    self.statusBar.userInteractionEnabled = NO;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
//MARK:JmoVxia---根据状态隐藏状态栏
- (void)hiddenStatusBarWithFullStatusBarHiddenType{
    switch (self.config.fullStatusBarHiddenType) {
        case FullStatusBarHiddenNever:
            [self setStatusBarHidden:NO];
            break;
        case FullStatusBarHiddenAlways:
            [self setStatusBarHidden:YES];
            break;
        case FullStatusBarHiddenFollowToolBar:
            [self setStatusBarHidden:_isDisappear];
            break;
    }
}
//MARK:JmoVxia---原始大小
- (void)originalscreen{
    _isFullScreen             = NO;
    _isUserTapMaxButton       = NO;
    [self resetTopToolBarHiddenType];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    if (self.config.isLandscape) {
        //还原为竖屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        [self setStatusBarHidden:_statusBarHiddenState];
    }else{
        //还原
        [self setStatusBarHidden:YES];
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformMakeRotation(0);
        }completion:^(BOOL finished) {
            [self setStatusBarHidden:self->_statusBarHiddenState];
        }];
    }
    self.frame = _customFarme;
    //还原到原有父类上
    [_fatherView addSubview:self];
    self.maskView.fullButton.selected     = NO;
    self.statusBar.userInteractionEnabled = YES;
}
//MARK:JmoVxia---APP活动通知
- (void)appDidEnterBackground:(NSNotification *)note{
    //将要挂起，停止播放
    [self pausePlay];
}
- (void)appDidEnterPlayground:(NSNotification *)note{
    //继续播放
    if (_isUserPlay && self.config.backPlay) {
        [self playVideo];
    }
}
//MARK:JmoVxia---layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.maskView.frame    = self.bounds;
}
//MARK:JmoVxia---dealloc
- (void)dealloc{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    //回到竖屏
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    //重置状态条
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    //恢复默认状态栏显示与否
    [self setStatusBarHidden:_statusBarHiddenState];
#ifdef DEBUG
    NSLog(@"播放器被销毁了");
#endif
}
//MARK:JmoVxia---懒加载
//遮罩
- (CLPlayerMaskView *) maskView{
    if (_maskView == nil){
        _maskView                         = [[CLPlayerMaskView alloc] init];
        _maskView.progressBackgroundColor = self.config.progressBackgroundColor;
        _maskView.progressBufferColor     = self.config.progressBufferColor;
        _maskView.progressPlayFinishColor = self.config.progressPlayFinishColor;
        _maskView.delegate                = self;
        //创建并添加点击手势（点击事件、添加手势）
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disappearAction:)];
        [_maskView addGestureRecognizer:tap];
        //计时器，循环执行
        [self.sliderTimer startTimer];
    }
    return _maskView;
}
//进度条定时器
- (CLGCDTimer *) sliderTimer{
    if (_sliderTimer == nil){
        __weak __typeof(self) weakSelf = self;
        _sliderTimer = [[CLGCDTimer alloc] initDispatchTimerWithTimeInterval:1.0f
                                                                   delaySecs:0 queue:dispatch_get_main_queue()
                                                                     repeats:YES
                                                                      action:^{
                                                                          __typeof(&*weakSelf) strongSelf = weakSelf;
                                                                          [strongSelf timeStack];
                                                                      }];
    }
    return _sliderTimer;
}
//手势定时器
- (CLGCDTimer *) tapTimer{
    if (_tapTimer == nil){
        __weak __typeof(self) weakSelf = self;
        _tapTimer = [[CLGCDTimer alloc] initDispatchTimerWithTimeInterval:self.config.toolBarDisappearTime
                                                                delaySecs:self.config.toolBarDisappearTime
                                                                    queue:dispatch_get_main_queue()
                                                                  repeats:YES
                                                                   action:^{
                                                                       __typeof(&*weakSelf) strongSelf = weakSelf;
                                                                       [strongSelf disappear];
                                                                   }];
        
    }
    return _tapTimer;
}
/**状态栏*/
- (UIView *) statusBar{
    if (_statusBar == nil){
        _statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    return _statusBar;
}
/**配置*/
- (CLPlayerViewConfig *) config{
    if (_config == nil){
        _config = [CLPlayerViewConfig defaultConfig];
    }
    return _config;
}
@end

