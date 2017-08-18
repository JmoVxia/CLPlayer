//
//  PlayerView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "CLPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "CLPlayerMaskView.h"
/**UIScreen width*/
#define  CLscreenWidth   [UIScreen mainScreen].bounds.size.width
/**UIScreen height*/
#define  CLscreenHeight  [UIScreen mainScreen].bounds.size.height
// 播放器的几种状态
typedef NS_ENUM(NSInteger, CLPlayerState) {
    CLPlayerStateFailed,     // 播放失败
    CLPlayerStateBuffering,  // 缓冲中
    CLPlayerStatePlaying,    // 播放中
    CLPlayerStateStopped,    // 停止播放
    CLPlayerStatePause       // 暂停播放
};

@interface CLPlayerView ()<CLPlayerMaskViewDelegate>

/** 播发器的几种状态 */
@property (nonatomic, assign) CLPlayerState    state;
/**控件原始Farme*/
@property (nonatomic, assign) CGRect           customFarme;
/**父类控件*/
@property (nonatomic, strong) UIView           *fatherView;
/**视频拉伸模式*/
@property (nonatomic, copy) NSString           *videoFillMode;
/**状态栏*/
@property (nonatomic, strong) UIView           *statusBar;
/**全屏标记*/
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
/**轻拍定时器*/
@property (nonatomic, strong) NSTimer          *timer;
/**slider定时器*/
@property (nonatomic, strong) NSTimer          *sliderTimer;

/**返回按钮回调*/
@property (nonatomic, copy) void (^BackBlock) (UIButton *backButton);
/**播放完成回调*/
@property (nonatomic, copy) void (^EndBlock) ();

@end

@implementation CLPlayerView

#pragma mark - 懒加载
//遮罩
- (CLPlayerMaskView *) maskView{
    if (_maskView == nil){
        _maskView                         = [[CLPlayerMaskView alloc] init];
        _maskView.progressBackgroundColor = _progressBackgroundColor;
        _maskView.progressBufferColor     = _progressBufferColor;
        _maskView.progressPlayFinishColor = _progressPlayFinishColor;
        _maskView.delegate                = self;
        [_maskView addTarget:self
                      action:@selector(disappearAction:)
            forControlEvents:UIControlEventTouchUpInside];
        //计时器，循环执行
        _sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                      selector:@selector(timeStack)
                                                      userInfo:nil
                                                       repeats:YES];
        //定时器，工具条消失
        _timer       = [NSTimer scheduledTimerWithTimeInterval:_toolBarDisappearTime
                                                        target:self
                                                      selector:@selector(disappear)
                                                      userInfo:nil
                                                       repeats:NO];
    }
    return _maskView;
}
/**statusBar*/
- (UIView *) statusBar{
    if (_statusBar == nil){
        _statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    return _statusBar;
}
#pragma mark - 视频拉伸方式
-(void)setFillMode:(VideoFillMode)fillMode{
    switch (fillMode){
        case ResizeAspectFill:
            //原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分会被剪切
            _videoFillMode = AVLayerVideoGravityResizeAspectFill;
            break;
        case ResizeAspect:
            //按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
            _videoFillMode = AVLayerVideoGravityResizeAspect;
            break;
        case Resize:
            //拉伸视频内容达到边框占满，但不按原比例拉伸
            _videoFillMode = AVLayerVideoGravityResize;
            break;
    }
}
#pragma mark - 进度条背景颜色
-(void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor{
    _progressBackgroundColor              = progressBackgroundColor;
    self.maskView.progressBackgroundColor = progressBackgroundColor;
}
#pragma mark - 进度条缓冲颜色
-(void)setProgressBufferColor:(UIColor *)progressBufferColor{
    _progressBufferColor              = progressBufferColor;
    self.maskView.progressBufferColor = progressBufferColor;
}
#pragma mark - 进度条播放完成颜色
-(void)setProgressPlayFinishColor:(UIColor *)progressPlayFinishColor{
    _progressPlayFinishColor              = progressPlayFinishColor;
    self.maskView.progressPlayFinishColor = progressPlayFinishColor;
}
#pragma mark - 转子颜色
-(void)setStrokeColor:(UIColor *)strokeColor{
    _strokeColor                       = strokeColor;
    self.maskView.activity.strokeColor = strokeColor;
}
#pragma mark - 是否支持横屏
-(void)setIsLandscape:(BOOL)isLandscape{
    _isLandscape = isLandscape;
}
#pragma mark - 全屏状态栏是否隐藏
-(void)setFullStatusBarHidden:(BOOL)fullStatusBarHidden{
    _fullStatusBarHidden = fullStatusBarHidden;
}
#pragma mark - 重复播放
- (void)setRepeatPlay:(BOOL)repeatPlay{
    _repeatPlay = repeatPlay;
}
#pragma mark - 静音
-(void)setMute:(BOOL)mute{
    _mute = mute;
    self.player.muted = _mute;
}
#pragma mark - 工具条消失时间
-(void)setToolBarDisappearTime:(NSInteger)toolBarDisappearTime{
    _toolBarDisappearTime = toolBarDisappearTime;
    [self destroyTimer];
    //定时器，工具条消失
    _timer         = [NSTimer scheduledTimerWithTimeInterval:_toolBarDisappearTime
                                                    target:self
                                                  selector:@selector(disappear)
                                                  userInfo:nil
                                                   repeats:NO];
}
#pragma mark - 传入播放地址
- (void)setUrl:(NSURL *)url{
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
    if (_videoFillMode){
        _playerLayer.videoGravity = _videoFillMode;
    }
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
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        //重置播放器
        [self resetPlayer];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status"
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
        [playerItem addObserver:self
                     forKeyPath:@"playbackLikelyToKeepUp"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
    }
}
- (void)setState:(CLPlayerState)state{
    _state = state;
    if (state == CLPlayerStateBuffering) {
        [self.maskView.activity starAnimation];
    }else if (state == CLPlayerStateFailed){
        [self.maskView.activity stopAnimation];
        self.maskView.failButton.hidden   = NO;
        self.maskView.playButton.selected = NO;
#ifdef DEBUG
        NSLog(@"加载失败");
#endif
    }else{
        [self.maskView.activity stopAnimation];
        if (_isUserPlay) {
            [self playVideo];
        }
    }
}
#pragma mark - 隐藏或者显示状态栏方法
- (void)setStatusBarHidden:(BOOL)hidden{
    //设置是否隐藏
    self.statusBar.hidden = hidden;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        //初始值
        _isFullScreen            = NO;
        _isDisappear             = NO;
        _isUserPlay              = NO;
        _isUserTapMaxButton      = NO;
        _fullStatusBarHidden     = YES;
        _isEnd                   = NO;
        _repeatPlay              = NO;
        _mute                    = NO;
        //查询控制器是否支持全屏
        _isLandscape             = NO;
        _statusBarHiddenState    = self.statusBar.isHidden;
        _toolBarDisappearTime    = 10;
        _progressBackgroundColor = [UIColor colorWithRed:0.54118 green:0.51373 blue:0.50980 alpha:1.00000];
        _progressPlayFinishColor = [UIColor whiteColor];
        _progressBufferColor     = [UIColor colorWithRed:0.84118 green:0.81373 blue:0.80980 alpha:1.00000];
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
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        [self creatUI];
    }
    return self;
}
#pragma mark - 创建播放器UI
- (void)creatUI{
    self.backgroundColor = [UIColor blackColor];
    //最上面的View
    [self addSubview:self.maskView];
}
#pragma mark - 监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            self.state = CLPlayerStatePlaying;
            self.player.muted = self.mute;
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
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // 当缓冲好的时候
        if (self.playerItem.isPlaybackLikelyToKeepUp && self.state == CLPlayerStateBuffering){
            self.state = CLPlayerStatePlaying;
        }
    }
}
#pragma mark - 缓冲较差时候
//卡顿时会走这里
- (void)bufferingSomeSecond{
    self.state = CLPlayerStateBuffering;
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self pausePlay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playVideo];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
    });
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
#pragma mark - 拖动进度条
//开始
-(void)cl_progressSliderTouchBegan:(CLSlider *)slider{
    //暂停
    [self pausePlay];
    //销毁定时消失工具条定时器
    [self destroyTimer];
}
//结束
-(void)cl_progressSliderTouchEnded:(CLSlider *)slider{
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingSomeSecond];
    }else{
        //继续播放
        [self playVideo];
    }
    //重新添加工具条定时消失定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:_toolBarDisappearTime
                                              target:self
                                            selector:@selector(disappear)
                                            userInfo:nil
                                             repeats:NO];
}
//拖拽中
-(void)cl_progressSliderValueChanged:(CLSlider *)slider{
    //计算出拖动的当前秒数
    CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    NSInteger dragedSeconds = floorf(total * slider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime];
}
#pragma mark - 计时器事件
- (void)timeStack{
    if (_playerItem.duration.timescale != 0){
        //总共时长
        self.maskView.slider.maximumValue   = 1;
        //当前进度
        self.maskView.slider.value          = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);
        //当前时长进度progress
        NSInteger proMin                    = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec                    = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)proMin, (long)proSec];
        //duration 总时长
        NSInteger durMin                    = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总分钟
        NSInteger durSec                    = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总秒
        self.maskView.totalTimeLabel.text   = [NSString stringWithFormat:@"%02ld:%02ld", (long)durMin, (long)durSec];
    }
}
#pragma mark - 播放暂停按钮方法
-(void)cl_playButtonAction:(UIButton *)button{
    if (button.selected == NO){
        [self pausePlay];
    }else{
        [self playVideo];
    }
}
#pragma mark - 全屏按钮响应事件
-(void)cl_fullButtonAction:(UIButton *)button{
    if (_isFullScreen == NO){
        _isUserTapMaxButton = YES;
        [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
    }else{
        [self originalscreen];
    }
}
#pragma mark - 播放失败按钮点击事件
-(void)cl_failButtonAction:(UIButton *)button{
    [self.maskView.activity starAnimation];
    self.maskView.playButton.selected = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setUrl:_url];
        [self playVideo];
    });
}
#pragma mark - 点击响应
- (void)disappearAction:(UIButton *)button{
    //取消定时消失
    [self destroyTimer];
    if (_isDisappear == NO){
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topToolBar.alpha    = 0;
            self.maskView.bottomToolBar.alpha = 0;
        }];
    }else{
        //添加定时消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:_toolBarDisappearTime
                                                  target:self
                                                selector:@selector(disappear)
                                                userInfo:nil
                                                 repeats:NO];
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topToolBar.alpha    = 1.0;
            self.maskView.bottomToolBar.alpha = 1.0;
        }];
    }
    _isDisappear = !_isDisappear;
}
#pragma mark - 定时消失
- (void)disappear{
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.topToolBar.alpha    = 0;
        self.maskView.bottomToolBar.alpha = 0;
    }];
    _isDisappear = YES;
}
#pragma mark - 播放完成
- (void)moviePlayDidEnd:(id)sender{
    _isEnd = YES;
    if (_repeatPlay == NO){
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
#pragma mark - 返回按钮
-(void)cl_backButtonAction:(UIButton *)button{
    if (self.BackBlock){
        self.BackBlock(button);
    }
}
- (void)backButton:(BackButtonBlock) backButton;{
    self.BackBlock = backButton;
}
#pragma mark - 暂停播放
- (void)pausePlay{
    self.maskView.playButton.selected = NO;
    [_player pause];
}
#pragma mark - 播放
- (void)playVideo{
    _isUserPlay = YES;
    self.maskView.playButton.selected = YES;
    if (_isEnd) {
        [self resetPlay];
    }else{
        [_player play];
    }
}
#pragma mark - 重新开始播放
- (void)resetPlay{
    _isEnd = NO;
    [_player seekToTime:CMTimeMake(0, 1)];
    [self playVideo];
}
#pragma mark - 销毁播放器
- (void)destroyPlayer{
    //销毁定时器
    [self pausePlay];
    [self destroyAllTimer];
    [self.playerLayer removeFromSuperlayer];
    [self removeFromSuperview];
    self.playerLayer = nil;
    self.player      = nil;
    self.maskView    = nil;
}
#pragma mark - 重置播放器
- (void)resetPlayer{
    _isUserPlay  = NO;
    _isDisappear = NO;
    [self pausePlay];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.player      = nil;
    self.maskView.slider.value = 0.0;
    [self.maskView.progress setProgress:0.0];
    self.maskView.currentTimeLabel.text = @"00:00";
    self.maskView.totalTimeLabel.text   = @"00:00";
    //重置工具条
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.topToolBar.alpha    = 1.0;
        self.maskView.bottomToolBar.alpha = 1.0;
    }];
    [self destroyTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_toolBarDisappearTime
                                              target:self
                                            selector:@selector(disappear)
                                            userInfo:nil
                                             repeats:NO];
    [self.maskView.activity starAnimation];
}
#pragma mark - 取消定时器
//销毁所有定时器
- (void)destroyAllTimer{
    [_sliderTimer invalidate];
    [_timer invalidate];
    _sliderTimer = nil;
    _timer       = nil;
}
//销毁定时消失定时器
- (void)destroyTimer{
    [_timer invalidate];
    _timer = nil;
}
#pragma mark - 屏幕旋转通知
- (void)orientChange:(NSNotification *)notification{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft){
        if (_isFullScreen == NO){
            if (_isLandscape) {
                //播放器所在控制器页面支持旋转情况下，和正常情况是相反的
                [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
            }else{
                [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
            }
        }
    }
    else if (orientation == UIDeviceOrientationLandscapeRight){
        if (_isFullScreen == NO){
            if (_isLandscape) {
                [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
            }else{
                [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
            }
        }
    }
    else if (orientation == UIDeviceOrientationPortrait){
        if (_isFullScreen == YES){
            [self originalscreen];
        }
    }
}
#pragma mark - 全屏
- (void)fullScreenWithDirection:(UIInterfaceOrientation)direction{
    //记录播放器父类
    _fatherView   = self.superview;
    //记录原始大小
    _customFarme  = self.frame;
    _isFullScreen = YES;
    [self setStatusBarHidden:_fullStatusBarHidden];
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    if (_isLandscape == YES){
        //手动点击需要旋转方向
        if (_isUserTapMaxButton) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        }
        if (keyWindow.frame.size.width < keyWindow.frame.size.height) {
            self.frame = CGRectMake(0, 0, CLscreenHeight, CLscreenWidth);
        }else{
            self.frame = CGRectMake(0, 0, CLscreenWidth, CLscreenHeight);
        }
    }else{
        //播放器所在控制器不支持旋转，采用旋转view的方式实现
        if (direction == UIInterfaceOrientationLandscapeLeft){
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        }else if (direction == UIInterfaceOrientationLandscapeRight) {
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation( - M_PI / 2);
            }];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
        }
        self.frame = CGRectMake(0, 0, CLscreenHeight, CLscreenWidth);
    }
    self.maskView.fullButton.selected = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
#pragma mark - 原始大小
- (void)originalscreen{
    _isFullScreen = NO;
    _isUserTapMaxButton = NO;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [self setStatusBarHidden:_statusBarHiddenState];
    if (_isLandscape) {
        //还原为竖屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }else{
        //还原
        [UIView animateWithDuration:0.25 animations:^{
            self.transform = CGAffineTransformMakeRotation(0);
        }];
    }
    self.frame = _customFarme;
    //还原到原有父类上
    [_fatherView addSubview:self];
    self.maskView.fullButton.selected = NO;
}
#pragma mark - APP活动通知
- (void)appDidEnterBackground:(NSNotification *)note{
    //将要挂起，停止播放
    [self pausePlay];
}
- (void)appDidEnterPlayground:(NSNotification *)note{
    //继续播放
    if (_isUserPlay) {
        [self playVideo];
    }
}
#pragma mark - 获取资源图片
- (UIImage *)getPictureWithName:(NSString *)name{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}
#pragma mark - layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.maskView.frame    = self.bounds;
}
#pragma mark - dealloc
- (void)dealloc{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
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
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    //恢复默认状态栏显示与否
    [self setStatusBarHidden:_statusBarHiddenState];
#ifdef DEBUG
    NSLog(@"播放器被销毁了");
#endif
}

@end
